import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/outgoing_text.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/socket/call_signal.dart';
import 'package:fanari_v2/socket/socket_events.dart';
import 'package:fanari_v2/socket/ws_envelope.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';

// ── Connection state ──────────────────────────────────────────────────────────

enum SocketState { disconnected, connecting, connected, reconnecting }

// ── CustomSocket ──────────────────────────────────────────────────────────────

class CustomSocket {
  CustomSocket._();
  static final CustomSocket instance = CustomSocket._();

  // ── State ──────────────────────────────────────────────────────────────────

  SocketState _state = SocketState.disconnected;
  SocketState get state => _state;

  WebSocket? _connection;
  String? _last_token;
  String? _my_user_id;

  /// Set by the chat UI to suppress notifications for the open conversation.
  bool in_chat_list_page = false;
  String? opened_conversation_id;

  void enter_chat_list_page() {
    in_chat_list_page = true;
  }

  void leave_chat_list_page() {
    in_chat_list_page = false;
  }

  void enter_conversation(String conversation_id) {
    opened_conversation_id = conversation_id;
  }

  void leave_conversation() {
    opened_conversation_id = null;
  }

  // ── Outgoing streams ───────────────────────────────────────────────────────

  final _text_controller = StreamController<IncomingTextEvent>.broadcast();
  final _typing_controller = StreamController<TypingEvent>.broadcast();
  final _presence_controller = StreamController<PresenceEvent>.broadcast();
  final _message_seen_controller =
      StreamController<MessageSeenEvent>.broadcast();
  final _call_signal_controller = StreamController<CallSignal>.broadcast();
  final _state_controller = StreamController<SocketState>.broadcast();

  Stream<IncomingTextEvent> get incoming_texts => _text_controller.stream;
  Stream<TypingEvent> get typing_events => _typing_controller.stream;
  Stream<PresenceEvent> get presence_events => _presence_controller.stream;
  Stream<MessageSeenEvent> get message_seen_events =>
      _message_seen_controller.stream;
  Stream<CallSignal> get call_signals => _call_signal_controller.stream;

  /// Emits the new [SocketState] every time the connection status changes.
  Stream<SocketState> get state_changes => _state_controller.stream;

  // ── Connection ─────────────────────────────────────────────────────────────

  Future<void> connect({required String access_token}) async {
    if (_state == SocketState.connected || _state == SocketState.connecting)
      return;

    _last_token = access_token;
    _my_user_id = await LocalStorage.user_id.get();

    _set_state(SocketState.connecting);

    try {
      _connection = await WebSocket.connect(
        '${AppCredentials.wsDomain}/api/ws/chat',
        headers: {'Authorization': 'Bearer $access_token'},
      );

      _set_state(SocketState.connected);

      _connection!.listen(
        _on_message,
        onDone: _on_done,
        onError: _on_error,
        cancelOnError: false,
      );
    } catch (e) {
      printLine('Socket connect failed: $e');
      _set_state(SocketState.disconnected);
      _schedule_reconnect();
    }
  }

  Future<void> disconnect() async {
    _last_token = null;
    await _connection?.close();
    _set_state(SocketState.disconnected);
  }

  void _on_done() {
    printLine('Socket closed — scheduling reconnect');
    _set_state(SocketState.disconnected);
    _schedule_reconnect();
  }

  void _on_error(Object error) {
    printLine('Socket error: $error');
    _set_state(SocketState.disconnected);
    _schedule_reconnect();
  }

  void _schedule_reconnect() async {
    if (_last_token == null) return; // disconnect() was intentional
    _set_state(SocketState.reconnecting);

    final access_token_valid_till = await LocalStorage.access_token_valid_till
        .get();

    if (access_token_valid_till! < DateTime.now().millisecondsSinceEpoch) {
      final success = await utils.CustomHttp.refresh_access_token();

      if (!success) {
        printLine('Failed to refresh access token');
        _set_state(SocketState.disconnected);
        return;
      }

      final access_token = await LocalStorage.access_token.get();
      _last_token = access_token!;
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (_last_token != null) connect(access_token: _last_token!);
    });
  }

  void _set_state(SocketState s) {
    _state = s;
    _state_controller.add(s);
  }

  // ── Incoming message dispatch ──────────────────────────────────────────────

  void _on_message(dynamic raw) async {
    if (raw is! String) return;

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      printLine('Failed to decode WS message: $e');
      return;
    }

    final envelope = WsEnvelope.from_json(decoded);

    switch (envelope.type) {
      case 'text':
        await _handle_incoming_text(envelope.payload);
      case 'typing':
        _handle_typing(envelope.payload);
      case 'connect':
        _presence_controller.add(
          PresenceEvent(
            user_id: envelope.payload['user_id'] as String,
            is_online: true,
          ),
        );
      case 'disconnect':
        _presence_controller.add(
          PresenceEvent(
            user_id: envelope.payload['user_id'] as String,
            is_online: false,
          ),
        );
      case 'message_seen':
        _handle_message_seen(envelope.payload);
      case 'call_signal':
        _handle_call_signal(envelope.payload);
      default:
        printLine('Unknown WS message type: ${envelope.type}');
    }
  }

  // ── Incoming text ──────────────────────────────────────────────────────────

  Future<void> _handle_incoming_text(Map<String, dynamic> payload) async {
    try {
      // Fetch image metadata here so TextModel.fromJson stays a pure factory.
      List<ImageModel>? images;
      if (payload['images'] != null) {
        final response = await utils.CustomHttp.post(
          endpoint: '/image/metadata',
          body: payload['images'],
          add_api_prefix: false,
        );
        if (!response.ok) throw Exception('Failed to fetch image metadata');
        images = ImageModel.fromJsonList(response.data!);
      }

      VideoModel? video;
      if (payload['video'] != null) {
        final video_id = payload['video'] is String
            ? payload['video'] as String
            : (payload['video'] as List).first as String;
        final response = await utils.CustomHttp.post(
          endpoint: '/image/metadata',
          body: [video_id],
          add_api_prefix: false,
        );
        if (response.ok && response.data != null) {
          video = VideoModel.fromJson(response.data![0]);
        }
      }

      final text = TextModel.from_payload(
        payload,
        my_id: _my_user_id!,
        images: images,
        video: video,
      );

      _text_controller.add(IncomingTextEvent(text: text));
    } catch (e) {
      printLine('Failed to handle incoming text: $e');
    }
  }

  // ── Message seen ───────────────────────────────────────────────────────────

  void _handle_message_seen(Map<String, dynamic> payload) {
    _message_seen_controller.add(
      MessageSeenEvent(
        conversation_id: payload['conversation_id'] as String,
        user_id: payload['user_id'] as String,
        text_ids: List<String>.from(payload['text_ids'] as List),
      ),
    );
  }

  // ── Typing ─────────────────────────────────────────────────────────────────

  void _handle_typing(Map<String, dynamic> payload) {
    _typing_controller.add(
      TypingEvent(
        conversation_id: payload['conversation_id'] as String,
        user_id: payload['user_id'] as String,
        name: payload['name'] as String? ?? '',
      ),
    );
  }

  // ── Call signals ───────────────────────────────────────────────────────────

  void _handle_call_signal(Map<String, dynamic> payload) {
    try {
      _call_signal_controller.add(CallSignal.from_json(payload));
    } catch (e) {
      printLine('Failed to parse call signal: $e');
    }
  }

  // ── Send helpers ───────────────────────────────────────────────────────────

  void _send(WsEnvelope envelope) {
    if (_state != SocketState.connected) {
      printLine('Socket not connected — dropping message: ${envelope.type}');
      return;
    }
    _connection?.add(envelope.encode());
  }

  void _send_call_signal(Map<String, dynamic> payload) {
    _send(WsEnvelope(type: 'call_signal', payload: payload));
  }

  // ── Public send API ────────────────────────────────────────────────────────

  void send_text(SocketOutgoingText text) {
    _send(WsEnvelope(type: 'text', payload: text.to_json()));
  }

  void send_message_seen({
    required String conversation_id,
    required List<String> text_ids,
  }) {
    _send(
      WsEnvelope(
        type: 'message_seen',
        payload: {
          'conversation_id': conversation_id,
          'text_ids': text_ids,
        },
      ),
    );
  }

  void send_typing({
    required String conversation_id,
    required String user_id,
    required String name,
  }) {
    _send(
      WsEnvelope(
        type: 'typing',
        payload: {
          'conversation_id': conversation_id,
          'user_id': user_id,
          'name': name,
        },
      ),
    );
  }

  // 1-to-1 call controls
  void send_call_request({
    required String to_user_id,
    required CallType call_type,
  }) {
    _send_call_signal({
      'type': 'call_request',
      'to': to_user_id,
      'call_type': call_type == CallType.video ? 'Video' : 'Audio',
    });
  }

  void send_call_accept({required String to_user_id}) {
    _send_call_signal({'type': 'call_accept', 'to': to_user_id});
  }

  void send_call_reject({required String to_user_id}) {
    _send_call_signal({'type': 'call_reject', 'to': to_user_id});
  }

  void send_call_end({required String to_user_id}) {
    _send_call_signal({'type': 'call_end', 'to': to_user_id});
  }

  // Group call controls
  void send_call_start({required String room_id, required CallType call_type}) {
    _send_call_signal({
      'type': 'call_start',
      'room_id': room_id,
      'call_type': call_type == CallType.video ? 'Video' : 'Audio',
    });
  }

  void send_call_join({required String room_id, required CallType call_type}) {
    _send_call_signal({
      'type': 'call_join',
      'room_id': room_id,
      'call_type': call_type == CallType.video ? 'Video' : 'Audio',
    });
  }

  void send_call_leave({required String room_id}) {
    _send_call_signal({'type': 'call_leave', 'room_id': room_id});
  }

  // WebRTC signals
  void send_offer({required String to_user_id, required String sdp}) {
    _send_call_signal({'type': 'offer', 'to': to_user_id, 'sdp': sdp});
  }

  void send_answer({required String to_user_id, required String sdp}) {
    _send_call_signal({'type': 'answer', 'to': to_user_id, 'sdp': sdp});
  }

  void send_ice_candidate({
    required String to_user_id,
    required Map<String, dynamic> candidate,
  }) {
    _send_call_signal({
      'type': 'ice_candidate',
      'to': to_user_id,
      'candidate': candidate,
    });
  }

  // In-call toggles
  void send_video_toggle({
    String? to_user_id,
    String? room_id,
    required bool enabled,
  }) {
    _send_call_signal({
      'type': 'video_toggle',
      if (to_user_id != null) 'to': to_user_id,
      if (room_id != null) 'room_id': room_id,
      'enabled': enabled,
    });
  }

  void send_audio_toggle({
    String? to_user_id,
    String? room_id,
    required bool muted,
  }) {
    _send_call_signal({
      'type': 'audio_toggle',
      if (to_user_id != null) 'to': to_user_id,
      if (room_id != null) 'room_id': room_id,
      'muted': muted,
    });
  }
}
