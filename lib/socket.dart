import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/firebase/firebase_api.dart';
import 'package:fanari_v2/model/attachment.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/provider/conversation.dart';

// ── Call Signal Models ────────────────────────────────────────────────────────

enum CallType { audio, video }

enum CallSignalType {
  // 1-to-1
  call_request,
  call_accept,
  call_reject,
  call_end,
  // Group
  call_start,
  call_join,
  call_leave,
  // WebRTC (both 1-1 and group)
  offer,
  answer,
  ice_candidate,
  // In-call controls
  video_toggle,
  audio_toggle,
  // Server → client only
  call_participants,
  peer_offline,
  unknown,
}

class CallSignal {
  final CallSignalType type;
  final String from;
  final String? to;
  final String? room_id;
  final String? sdp;
  final Map<String, dynamic>? candidate;
  final CallType? call_type;
  final bool? enabled;
  final bool? muted;
  final List<String>? participants;

  const CallSignal({
    required this.type,
    required this.from,
    this.to,
    this.room_id,
    this.sdp,
    this.candidate,
    this.call_type,
    this.enabled,
    this.muted,
    this.participants,
  });

  factory CallSignal.from_json(Map<String, dynamic> json) {
    final type_str = json['type'] as String? ?? '';

    final type = switch (type_str) {
      'call_request' => CallSignalType.call_request,
      'call_accept' => CallSignalType.call_accept,
      'call_reject' => CallSignalType.call_reject,
      'call_end' => CallSignalType.call_end,
      'call_start' => CallSignalType.call_start,
      'call_join' => CallSignalType.call_join,
      'call_leave' => CallSignalType.call_leave,
      'offer' => CallSignalType.offer,
      'answer' => CallSignalType.answer,
      'ice_candidate' => CallSignalType.ice_candidate,
      'video_toggle' => CallSignalType.video_toggle,
      'audio_toggle' => CallSignalType.audio_toggle,
      'call_participants' => CallSignalType.call_participants,
      'peer_offline' => CallSignalType.peer_offline,
      _ => CallSignalType.unknown,
    };

    return CallSignal(
      type: type,
      from: json['from'] as String? ?? '',
      to: json['to'] as String?,
      room_id: json['room_id'] as String?,
      sdp: json['sdp'] as String?,
      candidate: json['candidate'] as Map<String, dynamic>?,
      call_type: json['call_type'] == 'Video' ? CallType.video : CallType.audio,
      enabled: json['enabled'] as bool?,
      muted: json['muted'] as bool?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

// ── Outgoing Text Model ───────────────────────────────────────────────────────

class SocketOutgoingTextModel {
  final String conversation_id;
  final String? text;
  final List<MentionModel>? mentions;
  final List<String>? images;
  final VideoModel? video;
  final String? audio;
  final TextType type;
  final AttachmentModel? attachment;
  final String? reply_to;

  SocketOutgoingTextModel({
    required this.conversation_id,
    required this.type,
    this.text,
    this.images,
    this.video,
    this.mentions,
    this.audio,
    this.attachment,
    this.reply_to,
  });

  String stringify() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversation_id,
      'text': text,
      'mentions': mentions,
      'images': images,
      'audio': audio,
      'videos': video,
      'type': type.name,
      'attachment': attachment,
      'reply_to': reply_to,
    };
  }
}

// ── CustomSocket ──────────────────────────────────────────────────────────────

class WsEnvelope {
  final String type;
  final Map<String, dynamic> payload;

  const WsEnvelope({required this.type, required this.payload});

  // Decode incoming
  factory WsEnvelope.from_json(Map<String, dynamic> json) {
    return WsEnvelope(
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }

  // Encode outgoing — the ONLY place you ever call jsonEncode
  String encode() => jsonEncode({'type': type, 'payload': payload});
}

// ── CustomSocket ──────────────────────────────────────────────────────────────

class CustomSocket {
  bool _connected = false;
  WebSocket? _connection;

  CustomSocket._();
  static CustomSocket instance = CustomSocket._();

  WidgetRef? _ref;

  bool in_chat_page = false;
  String? opened_conversation_id;

  final _call_signal_controller = StreamController<CallSignal>.broadcast();
  Stream<CallSignal> get call_signals => _call_signal_controller.stream;

  // ── Connect ────────────────────────────────────────────────────────────────

  Future<void> connect(WidgetRef ref, {required String access_token}) async {
    _ref = ref;
    if (_connected) return;

    _connection = await WebSocket.connect(
      '${AppCredentials.wsDomain}/api/ws/chat',
      headers: {'Authorization': 'Bearer $access_token'},
    );
    _connected = true;

    _connection?.listen((message) async {
      if (message is! String) return;

      final Map<String, dynamic> raw;
      try {
        raw = jsonDecode(message) as Map<String, dynamic>;
      } catch (e) {
        printLine('Failed to decode message: $e');
        return;
      }

      final envelope = WsEnvelope.from_json(raw);

      switch (envelope.type) {
        case 'text':
          handle_incoming_text(envelope.payload);
          break;
        case 'typing':
          _handle_typing(envelope.payload);
          break;
        case 'connect':
          handle_user_connect(envelope.payload['user_id']);
          break;
        case 'disconnect':
          handle_user_disconnect(envelope.payload['user_id']);
          break;
        case 'call_signal':
          _handle_call_signal(envelope.payload);
          break;
        default:
          printLine('Unknown message type: ${envelope.type}');
      }
    });
  }

  // ── Call Signal Handler ────────────────────────────────────────────────────

  void _handle_call_signal(Map<String, dynamic> json) {
    try {
      final signal = CallSignal.from_json(json);

      printLine('call signal received: ${signal.type}');

      _call_signal_controller.add(signal);
    } catch (e) {
      printLine('Failed to parse call signal: $e');
    }
  }

  // ── Call Signal Senders ────────────────────────────────────────────────────

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

  // WebRTC signals — directed (both 1-1 and group)
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

  void _send_call_signal(Map<String, dynamic> payload) {
    _send(WsEnvelope(type: 'call_signal', payload: payload));
  }

  void _handle_typing(Map<String, dynamic> payload) {
    _ref!
        .read(conversationNotifierProvider.notifier)
        .updateTyping(
          conversation_id: payload['conversation_id'],
          user_id: payload['user_id'],
          name: payload['name'] ?? '',
        );
  }

  void handle_incoming_text(dynamic json) async {
    final local_storage = await SharedPreferences.getInstance();
    final user_id = local_storage.getString('user_id');
    final TextModel text_model = await TextModel.fromJson(json, user_id!);

    _ref!
        .read(conversationNotifierProvider.notifier)
        .addMessage(
          conversation_id: text_model.conversation_id,
          message: text_model,
        );

    if (text_model.my_text) return;

    final this_conversation_opened =
        opened_conversation_id == text_model.conversation_id;
    final no_conversation_opened = opened_conversation_id == null;

    if (in_chat_page && (this_conversation_opened || no_conversation_opened))
      return;

    final conversation = await _ref!
        .read(conversationNotifierProvider.notifier)
        .getTargetConversation(text_model.conversation_id);

    final name = conversation.core.type == ConversationType.Group
        ? conversation.group_metadata!.name
        : conversation.single_metadata!.first_name +
              ' ' +
              conversation.single_metadata!.last_name;

    _handle_message_notification({
      'group_id': '1',
      'name': name,
      'body': text_model.type.name == 'Text'
          ? text_model.text
          : text_model.type.name,
    });
  }

  Future<void> _handle_message_notification(Map<String, dynamic> data) async {
    printLine('Handle message notification: $data');

    List<AndroidNotificationAction> actions = [];
    StyleInformation? style_information;

    actions.add(
      AndroidNotificationAction(
        'reply_action_id',
        'Reply',
        inputs: [AndroidNotificationActionInput(label: 'Type your reply')],
      ),
    );
    actions.add(
      AndroidNotificationAction('mark_as_read_action_id', 'Mark as Read'),
    );

    if (notification_texts[data['group_id']] != null) {
      notification_texts[data['group_id']]!.add(
        Message(data['body'], DateTime.now(), null),
      );
    } else {
      notification_texts[data['group_id']] = [
        Message(data['body'], DateTime.now(), null),
      ];
    }

    style_information = MessagingStyleInformation(
      Person(name: data['name']),
      conversationTitle: data['title'],
      groupConversation: false,
      messages: notification_texts[data['group_id']],
    );

    local_notification_plugin.show(
      int.parse(data['group_id']),
      data['title'],
      data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          android_channel.id,
          android_channel.name,
          channelDescription: android_channel.description,
          icon: '@mipmap/launcher_icon',
          enableLights: true,
          color: AppColors.primary,
          styleInformation: style_information,
          actions: actions,
          priority: Priority.high,
          importance: Importance.high,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  void handle_user_connect(String user_id) {
    _ref!
        .read(conversationNotifierProvider.notifier)
        .updateOnline(user_id: user_id, is_online: true);
  }

  void handle_user_disconnect(String user_id) {
    _ref!
        .read(conversationNotifierProvider.notifier)
        .updateOnline(user_id: user_id, is_online: false);
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

  void send_text(SocketOutgoingTextModel text) {
    _send(WsEnvelope(type: 'text', payload: text.toJson()));
  }

  void _send(WsEnvelope message_envelope) {
    if (_connected) {
      _connection?.add(message_envelope.encode());
    } else {
      printLine('Socket not connected');
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    await _call_signal_controller.close();
    _connected = false;
  }

  Future<void> send_message(String message) async {
    if (_connected) _connection?.add(message);
  }
}
