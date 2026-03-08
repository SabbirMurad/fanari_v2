import 'dart:async';

import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/prepared_image.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/socket/socket_events.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation.g.dart';

@Riverpod(keepAlive: true)
class ConversationNotifier extends _$ConversationNotifier {
  static const int _texts_per_page = 20;

  @override
  FutureOr<List<ConversationModel>> build() async {
    return await _load() ?? [];
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Future<List<ConversationModel>?> _load() async {
    final response = await utils.CustomHttp.get(endpoint: '/conversation/list');

    if (!response.ok) {
      printLine('Failed to load conversations');
      return null;
    }

    final my_id = await LocalStorage.user_id.get();
    return ConversationModel.fromJsonList(response.data, my_id: my_id!);
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
    if (conversations[index].initial_text_loaded) return;

    // Mark as loading
    conversations[index] = conversations[index].copyWith(texts_loading: true);
    state = AsyncValue.data([...conversations]);

    final my_id = await LocalStorage.user_id.get();
    final response = await utils.CustomHttp.get(
      endpoint: '/conversation/text/list',
      queries: {
        'conversation_id': conversation_id,
        'limit': _texts_per_page,
        'offset': 0,
      },
    );

    if (!response.ok || my_id == null) {
      printLine(
        'Failed to load texts for conversation $conversation_id, code: ${response.status_code}',
      );
      final current = state.value ?? [];
      final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
      if (idx != -1) {
        current[idx] = current[idx].copyWith(texts_loading: false);
        state = AsyncValue.data([...current]);
      }
      return;
    }

    final texts = TextModel.fromJsonList(response.data as List, my_id: my_id);

    final current = state.value ?? [];
    final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
    if (idx == -1) return;

    current[idx] = current[idx].copyWith(
      texts: texts,
      initial_text_loaded: true,
      texts_loading: false,
      has_more_texts: texts.length >= _texts_per_page,
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
    if (conv.texts_loading || !conv.has_more_texts) return;

    // Mark as loading
    conversations[index] = conv.copyWith(texts_loading: true);
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
        current[idx] = current[idx].copyWith(texts_loading: false);
        state = AsyncValue.data([...current]);
      }
      return;
    }

    final older_texts = TextModel.fromJsonList(
      response.data as List,
      my_id: my_id,
    );

    final current = state.value ?? [];
    final idx = current.indexWhere((c) => c.core.uuid == conversation_id);
    if (idx == -1) return;

    current[idx] = current[idx].copyWith(
      texts: [...current[idx].texts, ...older_texts],
      texts_loading: false,
      has_more_texts: older_texts.length >= _texts_per_page,
    );
    state = AsyncValue.data([...current]);
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
      final image_ids = await utils.upload_images(
        images: [group_image],
        used_at: utils.AssetUsedAt.Chat,
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
    required TextModel message,
  }) async {
    final is_temp = message.uuid.startsWith('temp_');

    final updated = state.value!.map((conv) {
      if (conv.core.uuid != conversation_id) return conv;

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

      return conv.copyWith(
        texts: new_texts,
        last_text: is_temp ? conv.last_text : message,
      );
    }).toList();

    state = AsyncValue.data(updated);

    if (!is_temp) {
      Future.microtask(() async {
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

  // ── Typing indicator ───────────────────────────────────────────────────────

  Timer? _typing_timer;
  String? _typing_conversation_id;

  void update_typing(TypingEvent event) {
    final conversations = state.value ?? [];

    for (var i = 0; i < conversations.length; i++) {
      final conv = conversations[i];
      if (conv.core.uuid != event.conversation_id) continue;

      final is_group = conv.core.type == ConversationType.Group;
      final is_other_user =
          !is_group && conv.single_metadata?.user_id == event.user_id;

      if (!is_group && !is_other_user) break; // typing event is from myself

      if (_typing_conversation_id == event.conversation_id) {
        _typing_timer?.cancel();
      }
      _typing_conversation_id = event.conversation_id;
      conversations[i].typing = true;
      break;
    }

    state = AsyncValue.data(conversations);

    _typing_timer = Timer(const Duration(seconds: 3), () {
      final current = state.value ?? [];
      for (var i = 0; i < current.length; i++) {
        if (current[i].core.uuid == event.conversation_id) {
          current[i].typing = false;
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

    final was_favorite = conversations[index].common_metadata.is_favorite;
    conversations[index].common_metadata.is_favorite = !was_favorite;
    state = AsyncValue.data([...conversations]);

    final response = await utils.CustomHttp.patch(
      endpoint: '/conversation/favorite',
      body: {'conversation_id': conversation_id},
    );

    if (!response.ok) {
      conversations[index].common_metadata.is_favorite = was_favorite;
      state = AsyncValue.data([...conversations]);
    }
  }

  // ── Mute ────────────────────────────────────────────────────────────────

  Future<void> toggle_mute(String conversation_id) async {
    final conversations = state.value ?? [];
    final index = conversations.indexWhere(
      (c) => c.core.uuid == conversation_id,
    );
    if (index == -1) return;

    final was_muted = conversations[index].common_metadata.is_muted;
    conversations[index].common_metadata.is_muted = !was_muted;
    state = AsyncValue.data([...conversations]);

    final response = await utils.CustomHttp.patch(
      endpoint: '/conversation/mute',
      body: {'conversation_id': conversation_id},
    );

    if (!response.ok) {
      conversations[index].common_metadata.is_muted = was_muted;
      state = AsyncValue.data([...conversations]);
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
