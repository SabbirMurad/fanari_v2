import 'dart:async';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation.g.dart';

@Riverpod(keepAlive: true)
class ConversationNotifier extends _$ConversationNotifier {
  int offset = 0;
  int limit = 10;

  @override
  FutureOr<List<ConversationModel>> build() async {
    return await load() ?? [];
  }

  Future<List<ConversationModel>?> load() async {
    final response = await utils.CustomHttp.get(endpoint: '/conversation/list');

    if (!response.ok) {
      printLine('Failed to load conversations');
      return null;
    }

    return ConversationModel.fromJsonList(response.data);
  }

  Future<String?> createSingleConversation({
    required String target_user,
  }) async {
    List<ConversationModel>? existingConversations = state.value;

    if (existingConversations == null) {
      final conversations = await load();
      if (conversations == null) return null;
      state = AsyncValue.data(conversations);
    }

    existingConversations = state.value;

    for (var conversation in existingConversations!) {
      if (conversation.core.type == ConversationType.Group) continue;
      if (conversation.single_metadata!.user_id == target_user)
        return conversation.core.uuid;
    }

    final response = await utils.CustomHttp.post(
      endpoint: '/conversation/single',
      body: {'other_user': target_user},
    );

    if (!response.ok) return null;

    final conversation = ConversationModel.fromJson(response.data);

    state = AsyncValue.data([conversation, ...state.value!]);

    return conversation.core.uuid;
  }

  Future<void> addMessage({
    required String conversation_id,
    required TextModel message,
  }) async {
    for (int i = 0; i < state.value!.length; i++) {
      if (state.value![i].core.uuid == conversation_id) {
        state.value![i].texts = [message, ...state.value![i].texts];
        break;
      }
    }

    Future.microtask(() async {
      for (int i = 0; i < state.value!.length; i++) {
        if (state.value![i].core.uuid == conversation_id) {
          // Load third party data later so ui does not block
          final loaded_data = await state.value![i].texts[0]
              .load3rdPartyInfos();
          if (loaded_data == null) return;
          state.value![i].texts[0] = loaded_data;
          break;
        }
      }
    });
  }

  Future<ConversationModel> getTargetConversation(
    String conversation_id,
  ) async {
    List<ConversationModel>? existingConversations = state.value;

    if (existingConversations == null) {
      final conversations = await load();
      if (conversations == null) {
        throw 'Failed to load conversations';
      }

      state = AsyncValue.data(conversations);
    }

    existingConversations = state.value;

    return existingConversations!.firstWhere(
      (elm) => elm.core.uuid == conversation_id,
    );
  }

  Timer? _timer;
  String? previousConversationIdForRemovingTypingTimer;

  Future<void> updateTyping({
    required String conversation_id,
    required String user_id,
    required String name,
  }) async {
    List<ConversationModel> conversations = state.value ?? [];

    for (var i = 0; i < conversations.length; i++) {
      if (conversations[i].core.uuid == conversation_id) {
        if (conversations[i].core.type == ConversationType.Group) {
          if (previousConversationIdForRemovingTypingTimer == conversation_id) {
            _timer?.cancel();
          }

          previousConversationIdForRemovingTypingTimer = conversation_id;

          conversations[i].typing = true;
        } else {
          if (user_id == conversations[i].single_metadata!.user_id) {
            if (previousConversationIdForRemovingTypingTimer ==
                conversation_id) {
              _timer?.cancel();
            }

            previousConversationIdForRemovingTypingTimer = conversation_id;

            conversations[i].typing = true;
          } else {
            // Means the user is typing in a 1:1 conversation is me, not the other person, need to fix backend so this doesn't even come here
          }
        }
        break;
      }
    }

    state = AsyncValue.data(conversations);

    _timer = Timer(Duration(seconds: 3), () {
      for (var i = 0; i < conversations.length; i++) {
        if (conversations[i].core.uuid == conversation_id) {
          conversations[i].typing = false;
          break;
        }
      }

      state = AsyncValue.data(conversations);
    });
  }

  Future<void> updateOnline({
    required String user_id,
    required bool is_online,
  }) async {
    List<ConversationModel> conversations = state.value ?? [];
    for (var i = 0; i < conversations.length; i++) {
      if (conversations[i].core.type == ConversationType.Group) continue;

      if (conversations[i].single_metadata!.user_id == user_id) {
        conversations[i].single_metadata!.online = is_online;

        if (!is_online) {
          conversations[i].single_metadata!.last_seen =
              DateTime.now().millisecondsSinceEpoch;
        }
        break;
      }
    }

    state = AsyncValue.data(conversations);
  }
}
