import 'dart:async';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? userId = localStorage.getString('user_id');
    final response = await utils.CustomHttp.get(endpoint: '/chat/list');

    if (response.statusCode != 200) {
      printLine('Failed to load conversations');
      return null;
    }
    return ConversationModel.fromJsonList(response.data, userId!);
  }

  Future<void> addMessage({
    required String conversation_id,
    required TextModel message,
  }) async {
    List<ConversationModel> conversations = state.value ?? [];
    for (var i = 0; i < conversations.length; i++) {
      if (conversations[i].core.uuid == conversation_id) {
        conversations[i].texts = [message, ...conversations[i].texts];
        break;
      }
    }

    state = AsyncValue.data(conversations);
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

    _timer = Timer(Duration(seconds: 4), () {
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
