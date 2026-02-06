import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fanari_v2/firebase/firebase_api.dart';
import 'package:fanari_v2/model/attachment.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/providers/conversation.dart';

class SocketOutgoingTextModel {
  final String conversation_id;
  final String? text;
  final List<MentionModel>? mentions;
  final List<ImageModel>? images;
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
      'conversation_id': this.conversation_id,
      'text': this.text,
      'mentions': this.mentions,
      'images': this.images,
      'audio': this.audio,
      'videos': this.video,
      'type': this.type.name,
      'attachment': this.attachment,
      'reply_to': this.reply_to,
    });
  }
}

class CustomSocket {
  bool _connected = false;
  WebSocket? _connection;

  CustomSocket._();
  static CustomSocket instance = CustomSocket._();

  WidgetRef? _ref;

  bool inChatPage = false;
  String? openedConversationId = null;

  Future<void> connect(WidgetRef ref, {required String access_token}) async {
    _ref = ref;
    if (_connected) return;

    _connection = await WebSocket.connect(
      '${AppCredentials.wsDomain}/api/ws/chat',
      headers: {'Authorization': 'Bearer $access_token'},
    );
    _connected = true;

    _connection?.listen((message) async {
      printLine('message from socket: $message');
      final type = message.runtimeType;
      if (type != String) {
        printLine('Something from the message that not a string, type: $type');
        return;
      }

      final List<String> data = message.split('::');
      if (data.length < 2) {
        printLine('Message not in the correct format');
        return;
      }

      // Text message
      if (data[0] == "%text%") {
        final String textData = data[1];
        final json = jsonDecode(textData);
        handleIncomingText(json);
      }
      // When someone comes online
      else if (data[0] == "%connect%") {
        final String userId = data[1];
        handleUserConnect(userId);
      }
      // When someone goes offline
      else if (data[0] == "%disconnect%") {
        final String userId = data[1];
        handleUserDisconnect(userId);
      }
      // When someone is typing
      else if (data[0] == "%typing%") {
        final String conversation_id = data[1];
        final String user_id = data[2];
        final String name = data[3];

        _ref!
            .read(conversationNotifierProvider.notifier)
            .updateTyping(
              conversation_id: conversation_id,
              user_id: user_id,
              name: name,
            );
      }
    });

    _connection?.done
        .then((_) {
          printLine('WebSocket closed');
        })
        .catchError((e) {
          printLine('WebSocket error: $e');
        });
  }

  void handleIncomingText(dynamic json) async {
    final localStorage = await SharedPreferences.getInstance();
    final userId = localStorage.getString('user_id');
    final TextModel textModel = await TextModel.fromJson(json, userId!);

    _ref!
        .read(conversationNotifierProvider.notifier)
        .addMessage(
          conversation_id: textModel.conversation_id,
          message: textModel,
        );

    //! This is done so that posts loads quickly and info that might take time to load doesn't block the UI
    textModel.load3rdPartyInfos();

    if (textModel.my_text ||
        (inChatPage &&
            (openedConversationId == textModel.uuid ||
                openedConversationId == null)))
      return;

    _handleMessageNotification({
      'group_id': '1',
      'body': textModel.type.name == 'Text'
          ? textModel.text
          : textModel.type.name,
    });
  }

  Future<void> _handleMessageNotification(Map<String, dynamic> data) async {
    List<AndroidNotificationAction> actions = [];
    StyleInformation? styleInformation;

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

    styleInformation = MessagingStyleInformation(
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
          styleInformation: styleInformation,
          actions: actions,
          priority: Priority.high,
          importance: Importance.high,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  void handleUserConnect(String userId) {
    _ref!
        .read(conversationNotifierProvider.notifier)
        .updateOnline(user_id: userId, is_online: true);
  }

  void handleUserDisconnect(String userId) {
    _ref!
        .read(conversationNotifierProvider.notifier)
        .updateOnline(user_id: userId, is_online: false);
  }

  void sendTyping({required String conversation_id, required String user_id}) {
    final str = "%typing%::$conversation_id::$user_id::todo_name";
    _send(str);
  }

  void sendText(SocketOutgoingTextModel text) {
    final message = text.stringify();

    final str = "%text%::$message";
    _send(str);
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
    _connected = false;
  }

  Future<void> sendMessage(String message) async {
    if (_connected) {
      _connection?.add(message);
    }
  }
}
