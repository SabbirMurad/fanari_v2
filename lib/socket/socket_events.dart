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
