import 'dart:async';
import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/prepared_image.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/socket/socket.dart';
import 'package:fanari_v2/socket/socket_events.dart';
import 'package:fanari_v2/sqlite/conversation_cache.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/media.dart' as media_utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation.g.dart';

@Riverpod(keepAlive: true)
class ConversationNotifier extends _$ConversationNotifier {
  static const int _texts_per_page = 20;

  final _cache = ConversationCache.instance;

  @override
  FutureOr<List<ConversationModel>> build() async {
    // 1. Load from cache first for instant UI
    final my_id = await LocalStorage.user_id.get();
    if (my_id != null) {
      final cached = await _cache.get_conversations();
      if (cached.isNotEmpty) {
        final cached_models = cached
            .map((item) => ConversationModel.fromJson(item, my_id: my_id))
            .toList();
        state = AsyncValue.data(cached_models);

        // 2. Refresh from API in background
        _refresh_from_api(my_id);
        return cached_models;
      }
    }

    // No cache, load from API directly
    return await _load() ?? [];
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Future<void> _refresh_from_api(String my_id) async {
    final fresh = await _load();
    if (fresh == null) return;

    // Preserve runtime state (texts, typing, etc.) from current in-memory data
    final current = state.value ?? [];
    final current_map = {for (final c in current) c.core.uuid: c};

    for (var i = 0; i < fresh.length; i++) {
      final existing = current_map[fresh[i].core.uuid];
      if (existing != null) {
        fresh[i] = fresh[i].copyWith(
          texts: existing.texts,
          control: existing.control.copyWith(
            initial_text_loaded: existing.control.initial_text_loaded,
            typing: existing.control.typing,
          ),
        );
      }
    }

    state = AsyncValue.data(fresh);
  }

  Future<List<ConversationModel>?> _load() async {
    final response = await utils.CustomHttp.get(endpoint: '/conversation/list');

    if (!response.ok) {
      printLine('Failed to load conversations');
      return null;
    }

    final my_id = await LocalStorage.user_id.get();
    final conversations = ConversationModel.fromJsonList(
      response.data,
      my_id: my_id!,
    );

    // Cache the API response
    _cache_conversations(conversations);

    return conversations;
  }

  /// Writes conversations to SQLite cache in background.
  void _cache_conversations(List<ConversationModel> conversations) {
    Future.microtask(() async {
      try {
        await _cache.save_conversations(conversations);
      } catch (e) {
        printLine('Failed to cache conversations: $e');
      }
    });
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _load() ?? []);
  }

  // ── Load texts for a conversation ──────────────────────────────────────────

  Future<void> load_initial_texts(String conversation_id) async {
    final conversations = state.value;
    if (conversations == null) return;

    final index = conversations.indexWhere(
      (c) => c.core.uuid == conversation_id,
    );
    if (index == -1) return;

    // Already loaded
    if (conversations[index].control.initial_text_loaded) return;

    final my_id = await LocalStorage.user_id.get();
    if (my_id == null) return;

    // 1. Load from cache first for instant display
    final cached_texts = await _cache.get_texts(
      conversation_id: conversation_id,
      limit: _texts_per_page,
      offset: 0,
    );

    if (cached_texts.isNotEmpty) {
      final texts = cached_texts
          .map((item) => TextModel.fromJson(item, my_id: my_id))
          .toList();

      final current = state.value ?? [];
      final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
      if (idx != -1) {
        current[idx] = current[idx].copyWith(
          texts: texts,
          control: current[idx].control.copyWith(
            initial_text_loaded: true,
            texts_loading: true, // still loading from API
            has_more_texts: texts.length >= _texts_per_page,
          ),
        );
        state = AsyncValue.data([...current]);
      }
    } else {
      // No cache, show loading skeleton
      conversations[index] = conversations[index].copyWith(
        control: conversations[index].control.copyWith(texts_loading: true),
      );
      state = AsyncValue.data([...conversations]);
    }

    // 2. Fetch from API to get latest data
    final response = await utils.CustomHttp.get(
      endpoint: '/conversation/text/list',
      queries: {
        'conversation_id': conversation_id,
        'limit': _texts_per_page,
        'offset': 0,
      },
    );

    if (!response.ok) {
      printLine(
        'Failed to load texts for conversation $conversation_id, code: ${response.status_code}',
      );
      final current = state.value ?? [];
      final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
      if (idx != -1) {
        // If we had cache, keep showing it; just stop loading
        current[idx] = current[idx].copyWith(
          control: current[idx].control.copyWith(texts_loading: false),
        );
        state = AsyncValue.data([...current]);
      }
      return;
    }

    final texts = TextModel.fromJsonList(response.data as List, my_id: my_id);

    // Cache the fresh texts
    _cache_texts(texts);

    final current = state.value ?? [];
    final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
    if (idx == -1) return;

    current[idx] = current[idx].copyWith(
      texts: texts,
      control: current[idx].control.copyWith(
        initial_text_loaded: true,
        texts_loading: false,
        has_more_texts: texts.length >= _texts_per_page,
      ),
    );
    state = AsyncValue.data([...current]);
  }

  Future<void> load_more_texts(String conversation_id) async {
    final conversations = state.value;
    if (conversations == null) return;

    final index = conversations.indexWhere(
      (c) => c.core.uuid == conversation_id,
    );
    if (index == -1) return;

    final conv = conversations[index];
    if (conv.control.texts_loading || !conv.control.has_more_texts) return;

    // Mark as loading
    conversations[index] = conv.copyWith(
      control: conv.control.copyWith(texts_loading: true),
    );
    state = AsyncValue.data([...conversations]);

    final my_id = await LocalStorage.user_id.get();
    final response = await utils.CustomHttp.get(
      endpoint: '/conversation/text/list',
      queries: {
        'conversation_id': conversation_id,
        'limit': _texts_per_page,
        'offset': conv.texts.length,
      },
    );

    if (!response.ok || my_id == null) {
      printLine('Failed to load more texts for conversation $conversation_id');
      final current = state.value ?? [];
      final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
      if (idx != -1) {
        current[idx] = current[idx].copyWith(
          control: current[idx].control.copyWith(texts_loading: false),
        );
        state = AsyncValue.data([...current]);
      }
      return;
    }

    final older_texts = TextModel.fromJsonList(
      response.data as List,
      my_id: my_id,
    );

    // Cache older texts
    _cache_texts(older_texts);

    final current = state.value ?? [];
    final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
    if (idx == -1) return;

    current[idx] = current[idx].copyWith(
      texts: [...current[idx].texts, ...older_texts],
      control: current[idx].control.copyWith(
        texts_loading: false,
        has_more_texts: older_texts.length >= _texts_per_page,
      ),
    );
    state = AsyncValue.data([...current]);
  }

  /// Writes texts to SQLite cache in background.
  void _cache_texts(List<TextModel> texts) {
    Future.microtask(() async {
      try {
        await _cache.save_texts(texts);
      } catch (e) {
        printLine('Failed to cache texts: $e');
      }
    });
  }

  // ── Create conversation ────────────────────────────────────────────────────

  Future<String?> create_single_conversation({
    required String target_user,
  }) async {
    var existing = state.value;

    if (existing == null) {
      final loaded = await _load();
      if (loaded == null) return null;
      state = AsyncValue.data(loaded);
      existing = loaded;
    }

    for (final conv in existing) {
      if (conv.core.type == ConversationType.Group) continue;
      if (conv.single_metadata?.user_id == target_user) {
        return conv.core.uuid;
      }
    }

    final response = await utils.CustomHttp.post(
      endpoint: '/conversation/single',
      body: {'other_user': target_user},
    );

    if (!response.ok) return null;

    final user_id = await LocalStorage.user_id.get();
    final conv = ConversationModel.fromJson(response.data, my_id: user_id!);
    state = AsyncValue.data([conv, ...state.value!]);
    return conv.core.uuid;
  }

  Future<String?> create_group_conversation({
    required String group_name,
    required List<String> members,
    required PreparedImage? group_image,
  }) async {
    var existing = state.value;

    if (existing == null) {
      final loaded = await _load();
      if (loaded == null) return null;
      state = AsyncValue.data(loaded);
      existing = loaded;
    }

    String? image_id;

    if (group_image != null) {
      final image_ids = await media_utils.upload_images(
        images: [group_image],
        used_at: media_utils.AssetUsedAt.Chat,
      );

      if (image_ids == null) {
        throw Exception('Failed to upload group image');
      }

      image_id = image_ids.first;
    }

    final body = {'name': group_name, 'members': members, 'image': image_id};

    final response = await utils.CustomHttp.post(
      endpoint: '/conversation/group',
      body: body,
    );

    if (!response.ok) return null;

    final user_id = await LocalStorage.user_id.get();
    final conv = ConversationModel.fromJson(response.data, my_id: user_id!);
    state = AsyncValue.data([conv, ...state.value!]);
    return conv.core.uuid;
  }

  // ── Incoming message ───────────────────────────────────────────────────────

  Future<void> add_message({
    required String conversation_id,
    required TextModel message_input,
  }) async {
    var message = message_input;
    final is_temp = message.uuid.startsWith('temp_');

    ConversationModel? updated_conv;
    final others = <ConversationModel>[];

    for (final conv in state.value!) {
      if (conv.core.uuid != conversation_id) {
        others.add(conv);
        continue;
      }

      List<TextModel> new_texts;

      if (!is_temp) {
        final temp_index = conv.texts.indexWhere(
          (t) => t.uuid.startsWith('temp_') && t.type == message.type,
        );

        if (temp_index != -1) {
          new_texts = List.from(conv.texts);
          new_texts[temp_index] = message;
        } else {
          new_texts = [message, ...conv.texts];
        }
      } else {
        new_texts = [message, ...conv.texts];
      }

      // Increment unread if the message is from someone else and
      // the user is not currently viewing this conversation.
      final is_viewing =
          CustomSocket.instance.opened_conversation_id == conversation_id;
      final increment_unread = !is_temp && !message.my_text && !is_viewing;

      // If viewing, auto-mark the incoming message as read
      if (is_viewing && !is_temp && !message.my_text) {
        _my_user_id ??= await LocalStorage.user_id.get();
        final my_id = _my_user_id!;
        if (!message.seen_by.contains(my_id)) {
          message = message.copyWith(seen_by: [...message.seen_by, my_id]);

          // Update the message in new_texts too
          final msg_index = new_texts.indexWhere((t) => t.uuid == message.uuid);
          if (msg_index != -1) {
            new_texts[msg_index] = message;
          }

          // Notify server
          CustomSocket.instance.send_message_seen(
            conversation_id: conversation_id,
            text_ids: [message.uuid],
          );
        }
      }

      updated_conv = conv.copyWith(
        texts: new_texts,
        last_text: is_temp ? conv.last_text : message,
        core: conv.core.copyWith(last_message_at: message.created_at),
        unread_count: increment_unread
            ? conv.unread_count + 1
            : conv.unread_count,
      );
    }

    // Move the conversation to the top of the list
    if (updated_conv != null) {
      state = AsyncValue.data([updated_conv, ...others]);
    }

    if (!is_temp) {
      // Cache the message and update conversation
      Future.microtask(() async {
        try {
          await _cache.save_text(message);
          await _cache.update_conversation(
            uuid: conversation_id,
            last_message_at: message.created_at,
            last_text: message,
          );
        } catch (e) {
          printLine('Failed to cache message: $e');
        }

        final loaded = await message.load_third_party_infos();
        if (loaded == null) return;

        final refreshed = state.value!.map((conv) {
          if (conv.core.uuid != conversation_id) return conv;
          final new_texts = conv.texts
              .map((t) => t.uuid == message.uuid ? loaded : t)
              .toList();
          return conv.copyWith(texts: new_texts);
        }).toList();

        state = AsyncValue.data(refreshed);
      });
    }
  }

  // ── Mark as read ─────────────────────────────────────────────────────────

  Future<void> mark_as_read(String conversation_id) async {
    final conversations = state.value;
    if (conversations == null) return;

    final index = conversations.indexWhere(
      (c) => c.core.uuid == conversation_id,
    );
    if (index == -1) return;

    _my_user_id ??= await LocalStorage.user_id.get();
    final my_id = _my_user_id!;

    // Collect text UUIDs that the current user hasn't seen yet
    final unseen_text_ids = conversations[index].texts
        .where((t) => !t.my_text && !t.seen_by.contains(my_id))
        .map((t) => t.uuid)
        .toList();

    if (unseen_text_ids.isEmpty) return;

    // Update seen_by locally on each text
    final updated_texts = conversations[index].texts.map((t) {
      if (unseen_text_ids.contains(t.uuid)) {
        return t.copyWith(seen_by: [...t.seen_by, my_id]);
      }
      return t;
    }).toList();

    conversations[index] = conversations[index].copyWith(
      texts: updated_texts,
      unread_count: 0,
    );
    state = AsyncValue.data([...conversations]);

    // Notify other participants via socket
    CustomSocket.instance.send_message_seen(
      conversation_id: conversation_id,
      text_ids: unseen_text_ids,
    );

    // Update cache
    Future.microtask(() async {
      try {
        await _cache.update_seen_by(text_ids: unseen_text_ids, user_id: my_id);
        await _cache.update_conversation(
          uuid: conversation_id,
          unread_count: 0,
        );
      } catch (e) {
        printLine('Failed to update read cache: $e');
      }
    });
  }

  /// Called when a remote user has seen messages in a conversation.
  void handle_message_seen(MessageSeenEvent event) {
    final conversations = state.value;
    if (conversations == null) return;

    final index = conversations.indexWhere(
      (c) => c.core.uuid == event.conversation_id,
    );
    if (index == -1) return;

    bool changed = false;
    final updated_texts = conversations[index].texts.map((t) {
      if (event.text_ids.contains(t.uuid) &&
          !t.seen_by.contains(event.user_id)) {
        changed = true;
        return t.copyWith(seen_by: [...t.seen_by, event.user_id]);
      }
      return t;
    }).toList();

    if (!changed) return;

    conversations[index] = conversations[index].copyWith(texts: updated_texts);
    state = AsyncValue.data([...conversations]);

    // Update cache
    Future.microtask(() async {
      try {
        await _cache.update_seen_by(
          text_ids: event.text_ids,
          user_id: event.user_id,
        );
      } catch (e) {
        printLine('Failed to update seen_by cache: $e');
      }
    });
  }

  // ── Typing indicator ───────────────────────────────────────────────────────

  Timer? _typing_timer;
  String? _typing_conversation_id;

  String? _my_user_id;

  void update_typing(TypingEvent event) async {
    _my_user_id ??= await LocalStorage.user_id.get();

    // Ignore my own typing events
    if (event.user_id == _my_user_id) return;

    final conversations = state.value ?? [];

    for (var i = 0; i < conversations.length; i++) {
      final conv = conversations[i];
      if (conv.core.uuid != event.conversation_id) continue;

      if (_typing_conversation_id == event.conversation_id) {
        _typing_timer?.cancel();
      }
      _typing_conversation_id = event.conversation_id;
      conversations[i].control.typing = true;
      conversations[i].control.typing_name = event.name;
      break;
    }

    state = AsyncValue.data(conversations);

    _typing_timer = Timer(const Duration(seconds: 3), () {
      final current = state.value ?? [];
      for (var i = 0; i < current.length; i++) {
        if (current[i].core.uuid == event.conversation_id) {
          current[i].control.typing = false;
          current[i].control.typing_name = null;
          break;
        }
      }
      state = AsyncValue.data(current);
    });
  }

  // ── Presence ───────────────────────────────────────────────────────────────

  void update_online(PresenceEvent event) {
    final conversations = state.value ?? [];

    for (var i = 0; i < conversations.length; i++) {
      if (conversations[i].core.type == ConversationType.Group) continue;
      if (conversations[i].single_metadata?.user_id != event.user_id) continue;

      conversations[i].single_metadata!.online = event.is_online;
      if (!event.is_online) {
        conversations[i].single_metadata!.last_seen =
            DateTime.now().millisecondsSinceEpoch;
      }
      break;
    }

    state = AsyncValue.data(conversations);
  }

  // ── Favorite ─────────────────────────────────────────────────────────────

  Future<void> toggle_favorite(String conversation_id) async {
    final conversations = state.value ?? [];
    final index = conversations.indexWhere(
      (c) => c.core.uuid == conversation_id,
    );
    if (index == -1) return;

    final was_favorite = conversations[index].common_metadata.favorite;
    conversations[index].common_metadata.favorite = !was_favorite;
    state = AsyncValue.data([...conversations]);

    _cache.update_conversation(
      uuid: conversation_id,
      is_favorite: !was_favorite,
    );

    final response = await utils.CustomHttp.patch(
      endpoint: '/conversation/favorite',
      body: {'conversation_id': conversation_id},
    );

    if (!response.ok) {
      conversations[index].common_metadata.favorite = was_favorite;
      state = AsyncValue.data([...conversations]);
      _cache.update_conversation(
        uuid: conversation_id,
        is_favorite: was_favorite,
      );
    }
  }

  // ── Mute ────────────────────────────────────────────────────────────────

  Future<void> toggle_mute(String conversation_id) async {
    final conversations = state.value ?? [];
    final index = conversations.indexWhere(
      (c) => c.core.uuid == conversation_id,
    );
    if (index == -1) return;

    final was_muted = conversations[index].common_metadata.muted;
    conversations[index].common_metadata.muted = !was_muted;
    state = AsyncValue.data([...conversations]);

    _cache.update_conversation(uuid: conversation_id, is_muted: !was_muted);

    final response = await utils.CustomHttp.patch(
      endpoint: '/conversation/mute',
      body: {'conversation_id': conversation_id},
    );

    if (!response.ok) {
      conversations[index].common_metadata.muted = was_muted;
      state = AsyncValue.data([...conversations]);
      _cache.update_conversation(uuid: conversation_id, is_muted: was_muted);
    }
  }

  // ── Lookup ─────────────────────────────────────────────────────────────────

  Future<ConversationModel> get_target_conversation(
    String conversation_id,
  ) async {
    var existing = state.value;

    if (existing == null) {
      final loaded = await _load();
      if (loaded == null) throw Exception('Failed to load conversations');
      state = AsyncValue.data(loaded);
      existing = loaded;
    }

    return existing.firstWhere((c) => c.core.uuid == conversation_id);
  }
}
