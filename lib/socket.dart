import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fanari_v2/firebase/firebase_api.dart';
import 'package:fanari_v2/model/attachment.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/providers/conversation.dart';

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
      'CallRequest'      => CallSignalType.call_request,
      'CallAccept'       => CallSignalType.call_accept,
      'CallReject'       => CallSignalType.call_reject,
      'CallEnd'          => CallSignalType.call_end,
      'CallStart'        => CallSignalType.call_start,
      'CallJoin'         => CallSignalType.call_join,
      'CallLeave'        => CallSignalType.call_leave,
      'Offer'            => CallSignalType.offer,
      'Answer'           => CallSignalType.answer,
      'IceCandidate'     => CallSignalType.ice_candidate,
      'VideoToggle'      => CallSignalType.video_toggle,
      'AudioToggle'      => CallSignalType.audio_toggle,
      'CallParticipants' => CallSignalType.call_participants,
      'PeerOffline'      => CallSignalType.peer_offline,
      _                  => CallSignalType.unknown,
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
    return jsonEncode({
      'conversation_id': conversation_id,
      'text': text,
      'mentions': mentions,
      'images': images,
      'audio': audio,
      'videos': video,
      'type': type.name,
      'attachment': attachment,
      'reply_to': reply_to,
    });
  }
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

    _connection?.listen(
      (message) async {
        printLine('message from socket: $message');

        if (message.runtimeType != String) {
          printLine('Non-string message type: ${message.runtimeType}');
          return;
        }

        final List<String> data = (message as String).split('::');
        if (data.length < 2) {
          printLine('Message not in correct format');
          return;
        }

        final prefix = data[0];

        // Rejoin with '::' in case the payload itself contains '::'
        // (ICE candidates and SDP blobs often do)
        final payload = data.sublist(1).join('::');

        switch (prefix) {
          case '%text%':
            handle_incoming_text(jsonDecode(payload));
            break;

          case '%connect%':
            handle_user_connect(payload);
            break;

          case '%disconnect%':
            handle_user_disconnect(payload);
            break;

          case '%typing%':
            // format: %typing%::conversation_id::user_id::name
            // re-split the original message since typing uses positional parts
            final typing_parts = message.split('::');
            if (typing_parts.length >= 4) {
              _ref!.read(conversationNotifierProvider.notifier).updateTyping(
                conversation_id: typing_parts[1],
                user_id: typing_parts[2],
                name: typing_parts[3],
              );
            }
            break;

          case '%call_signal%':
            _handle_call_signal(payload);
            break;

          default:
            printLine('Unknown prefix: $prefix');
        }
      },
      onError: (e) => printLine('WebSocket error: $e'),
      onDone: () => printLine('WebSocket closed'),
    );
  }

  // ── Call Signal Handler ────────────────────────────────────────────────────

  void _handle_call_signal(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
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
      'type': 'CallRequest',
      'to': to_user_id,
      'call_type': call_type == CallType.video ? 'Video' : 'Audio',
    });
  }

  void send_call_accept({required String to_user_id}) {
    _send_call_signal({'type': 'CallAccept', 'to': to_user_id});
  }

  void send_call_reject({required String to_user_id}) {
    _send_call_signal({'type': 'CallReject', 'to': to_user_id});
  }

  void send_call_end({required String to_user_id}) {
    _send_call_signal({'type': 'CallEnd', 'to': to_user_id});
  }

  // Group call controls
  void send_call_start({
    required String room_id,
    required CallType call_type,
  }) {
    _send_call_signal({
      'type': 'CallStart',
      'room_id': room_id,
      'call_type': call_type == CallType.video ? 'Video' : 'Audio',
    });
  }

  void send_call_join({
    required String room_id,
    required CallType call_type,
  }) {
    _send_call_signal({
      'type': 'CallJoin',
      'room_id': room_id,
      'call_type': call_type == CallType.video ? 'Video' : 'Audio',
    });
  }

  void send_call_leave({required String room_id}) {
    _send_call_signal({'type': 'CallLeave', 'room_id': room_id});
  }

  // WebRTC signals — directed (both 1-1 and group)
  void send_offer({required String to_user_id, required String sdp}) {
    _send_call_signal({'type': 'Offer', 'to': to_user_id, 'sdp': sdp});
  }

  void send_answer({required String to_user_id, required String sdp}) {
    _send_call_signal({'type': 'Answer', 'to': to_user_id, 'sdp': sdp});
  }

  void send_ice_candidate({
    required String to_user_id,
    required Map<String, dynamic> candidate,
  }) {
    _send_call_signal({
      'type': 'IceCandidate',
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
      'type': 'VideoToggle',
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
      'type': 'AudioToggle',
      if (to_user_id != null) 'to': to_user_id,
      if (room_id != null) 'room_id': room_id,
      'muted': muted,
    });
  }

  void _send_call_signal(Map<String, dynamic> payload) {
    final message = '%call_signal%::${jsonEncode(payload)}';
    _send(message);
  }

  // ── Existing Methods (unchanged logic) ────────────────────────────────────

  void handle_incoming_text(dynamic json) async {
    final local_storage = await SharedPreferences.getInstance();
    final user_id = local_storage.getString('user_id');
    final TextModel text_model = await TextModel.fromJson(json, user_id!);

    _ref!.read(conversationNotifierProvider.notifier).addMessage(
      conversation_id: text_model.conversation_id,
      message: text_model,
    );

    text_model.load3rdPartyInfos();

    if (text_model.my_text ||
        (in_chat_page &&
            (opened_conversation_id == text_model.uuid ||
                opened_conversation_id == null))) return;

    _handle_message_notification({
      'group_id': '1',
      'body': text_model.type.name == 'Text'
          ? text_model.text
          : text_model.type.name,
    });
  }

  Future<void> _handle_message_notification(
    Map<String, dynamic> data,
  ) async {
    List<AndroidNotificationAction> actions = [];
    StyleInformation? style_information;

    actions.add(AndroidNotificationAction(
      'reply_action_id',
      'Reply',
      inputs: [AndroidNotificationActionInput(label: 'Type your reply')],
    ));
    actions.add(AndroidNotificationAction(
      'mark_as_read_action_id',
      'Mark as Read',
    ));

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
      Person(name: 'Sabbir'),
      conversationTitle: data['title'],
      groupConversation: false,
      messages: notification_texts[data['group_id']],
    );

    localNotificationPlugin.show(
      int.parse(data['group_id']),
      data['title'],
      data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          icon: '@mipmap/ic_launcher',
          enableLights: true,
          color: const Color(0xFF9A79F5),
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
  }) {
    _send('%typing%::$conversation_id::$user_id::todo_name');
  }

  void send_text(SocketOutgoingTextModel text) {
    _send('%text%::${text.stringify()}');
  }

  void _send(String message) {
    if (_connected) {
      _connection?.add(message);
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
