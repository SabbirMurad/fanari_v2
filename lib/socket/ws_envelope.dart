import 'dart:convert';

class WsEnvelope {
  final String type;
  final Map<String, dynamic> payload;

  const WsEnvelope({required this.type, required this.payload});

  factory WsEnvelope.from_json(Map<String, dynamic> json) {
    return WsEnvelope(
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }

  /// The only place in the codebase that calls jsonEncode on outgoing messages.
  String encode() => jsonEncode({'type': type, 'payload': payload});
}
