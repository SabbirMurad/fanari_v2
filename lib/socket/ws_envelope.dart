import 'dart:convert';

enum WsEnvelopeType {
  text,
  typing,
  connect,
  disconnect,
  call_signal,
  message_seen,
  new_conversation,
}

class WsEnvelope {
  final WsEnvelopeType type;
  final Map<String, dynamic> payload;

  const WsEnvelope({required this.type, required this.payload});

  factory WsEnvelope.from_json(Map<String, dynamic> json) {
    final WsEnvelopeType type = switch (json['type'] as String) {
      'text' => WsEnvelopeType.text,
      'typing' => WsEnvelopeType.typing,
      'connect' => WsEnvelopeType.connect,
      'disconnect' => WsEnvelopeType.disconnect,
      'new_conversation' => WsEnvelopeType.new_conversation,
      'call_signal' => WsEnvelopeType.call_signal,
      'message_seen' => WsEnvelopeType.message_seen,
      _ => throw Exception('Unknown WS envelope type: ${json['type']}'),
    };

    return WsEnvelope(
      type: type,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }

  /// The only place in the codebase that calls jsonEncode on outgoing messages.
  String encode() => jsonEncode({'type': type.name, 'payload': payload});
}
