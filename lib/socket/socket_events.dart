import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';

/// Emitted when a remote user starts typing in a conversation.
class TypingEvent {
  final String conversation_id;
  final String user_id;
  final String name;

  const TypingEvent({
    required this.conversation_id,
    required this.user_id,
    required this.name,
  });
}

/// Emitted when a user comes online or goes offline.
class PresenceEvent {
  final String user_id;
  final bool is_online;

  const PresenceEvent({required this.user_id, required this.is_online});
}

/// Emitted when a fully-constructed incoming [TextModel] arrives.
class IncomingTextEvent {
  final TextModel text;

  /// Whether this message was sent by the local user (e.g. confirmed by server).
  bool get is_mine => text.my_text;

  const IncomingTextEvent({required this.text});
}

/// Emitted when texts in a conversation have been marked as read by a user.
class MessageSeenEvent {
  final String conversation_id;
  final String user_id;
  final List<String> text_ids;

  const MessageSeenEvent({
    required this.conversation_id,
    required this.user_id,
    required this.text_ids,
  });
}

/// Emitted when a new conversation is created.
class NewConversationEvent {
  final String conversation_id;
  final ConversationType type;

  const NewConversationEvent({
    required this.conversation_id,
    required this.type,
  });

  factory NewConversationEvent.fromJson(Map<String, dynamic> json) {
    return NewConversationEvent(
      conversation_id: json['conversation_id'],
      type: json['type'] == 'Group'
          ? ConversationType.Group
          : ConversationType.Single,
    );
  }
}
