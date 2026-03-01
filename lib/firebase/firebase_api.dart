import 'dart:convert';
import 'dart:io';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Notification Channel ──────────────────────────────────────────────────────

const _ios_settings = DarwinInitializationSettings();
const _android_settings = AndroidInitializationSettings('@mipmap/ic_launcher');
const _init_settings = InitializationSettings(
  android: _android_settings,
  iOS: _ios_settings,
);

const android_channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final local_notification_plugin = FlutterLocalNotificationsPlugin()
  ..initialize(
    _init_settings,
    onDidReceiveNotificationResponse: _handle_notification_response,
    onDidReceiveBackgroundNotificationResponse:
        _handle_background_notification_response,
  );

// ── Notification Types ────────────────────────────────────────────────────────

enum NotificationType {
  system,
  liked_profile,
  liked_post,
  commented_post,
  started_following,
  friend_request,
  friend_request_reject,
  friend_request_accept,
  incoming_call, // ✅ added for call notifications
  message,
}

// ── Notification State ────────────────────────────────────────────────────────

// Tracks message threads for MessagingStyleInformation grouping
final Map<String, List<Message>> notification_texts = {};

// ── Response Handlers ─────────────────────────────────────────────────────────

Future<void> _handle_notification_response(
  NotificationResponse response,
) async {
  printLine('Notification tapped — action: ${response.actionId}');
  AppRoutes.go('/home/notification');
}

// Runs in a background isolate — keep it minimal, no providers or state
Future<void> _handle_background_notification_response(
  NotificationResponse response,
) async {
  printLine('Background notification action: ${response.actionId}');

  switch (response.actionId) {
    case 'reply_action_id':
      // TODO: send reply
      break;
    case 'mark_as_read_action_id':
      // TODO: mark conversation as read
      break;
    case 'follow_back_action_id':
      // TODO: follow back
      break;
    case 'accept_friend_request_action_id':
      // TODO: accept request
      break;
    case 'reject_friend_request_action_id':
      // TODO: reject request
      break;
  }

  AppRoutes.go('/home/notification');
}

// ── Foreground Message Handler ────────────────────────────────────────────────

Future<void> handle_message(RemoteMessage message) async {
  printLine('Notification incoming — topic: ${message.data['topic']}');

  final data = message.data;
  final topic_str = data['topic'] as String?;
  final notification_id = data['group_id'] != null
      ? int.parse(data['group_id'])
      : message.hashCode;

  // Map topic string to enum — unknown topics are ignored
  final NotificationType? type = NotificationType.values
      .where((e) => e.name == topic_str)
      .firstOrNull;

  if (type == null) {
    printLine('Notification topic not implemented: $topic_str');
    return;
  }

  final List<AndroidNotificationAction> actions = _build_actions(type, data);
  final StyleInformation? style_information = await _build_style(type, data);

  local_notification_plugin.show(
    notification_id,
    data['title'],
    data['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        android_channel.id,
        android_channel.name,
        channelDescription: android_channel.description,
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

// ── Action Builder ────────────────────────────────────────────────────────────

List<AndroidNotificationAction> _build_actions(
  NotificationType type,
  Map<String, dynamic> data,
) {
  switch (type) {
    case NotificationType.started_following:
      return [
        const AndroidNotificationAction('follow_back_action_id', 'Follow Back'),
      ];

    case NotificationType.friend_request:
      return [
        const AndroidNotificationAction(
          'accept_friend_request_action_id',
          'Accept',
        ),
        const AndroidNotificationAction(
          'reject_friend_request_action_id',
          'Reject',
        ),
      ];

    case NotificationType.message:
      return [
        AndroidNotificationAction(
          'reply_action_id',
          'Reply',
          inputs: [
            const AndroidNotificationActionInput(label: 'Type your reply'),
          ],
        ),
        const AndroidNotificationAction(
          'mark_as_read_action_id',
          'Mark as Read',
        ),
      ];

    case NotificationType.incoming_call:
      return [
        const AndroidNotificationAction('accept_call_action_id', 'Accept'),
        const AndroidNotificationAction('reject_call_action_id', 'Reject'),
      ];

    default:
      return [];
  }
}

// ── Style Builder ─────────────────────────────────────────────────────────────

Future<StyleInformation?> _build_style(
  NotificationType type,
  Map<String, dynamic> data,
) async {
  // Message notifications use conversation threading style
  if (type == NotificationType.message) {
    final group_id = data['group_id'] as String;

    notification_texts[group_id] ??= [];
    notification_texts[group_id]!.add(
      Message(data['body'], DateTime.now(), null),
    );

    return MessagingStyleInformation(
      const Person(name: 'Sabbir'), // TODO: replace with actual user name
      conversationTitle: data['title'],
      groupConversation: false,
      messages: notification_texts[group_id],
    );
  }

  // All other types use a big picture if an image URL is provided
  if (data['image'] != null) {
    final image_path = await _download_and_save_image(
      data['image'],
      'notification_image.jpg',
    );
    if (image_path != null) {
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(image_path),
        contentTitle: data['title'],
        summaryText: data['body'],
      );
    }
  }

  return null;
}

// ── Image Download ────────────────────────────────────────────────────────────

Future<String?> _download_and_save_image(String url, String file_name) async {
  try {
    final response = await http.get(Uri.parse(url));
    final directory = await getTemporaryDirectory();
    final file_path = '${directory.path}/$file_name';
    final file = File(file_path);

    if (await file.exists()) await file.delete();
    await file.writeAsBytes(response.bodyBytes);

    return file_path;
  } catch (e) {
    printLine('Error downloading notification image: $e');
    return null;
  }
}

// ── FirebaseApi ───────────────────────────────────────────────────────────────

class FirebaseApi {
  final _firebase_messaging = FirebaseMessaging.instance;

  Future<void> init_notification() async {
    await _firebase_messaging.requestPermission();

    await _firebase_messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Wire up all message entry points
    FirebaseMessaging.instance.getInitialMessage().then(_handle_app_open);
    FirebaseMessaging.onMessageOpenedApp.listen(_handle_app_open);
    FirebaseMessaging.onBackgroundMessage(handle_message);
    FirebaseMessaging.onMessage.listen(handle_message);

    // Register FCM token with backend if user is logged in
    if (!await utils.has_internet()) return;

    final token = await _firebase_messaging.getToken();
    if (token == null) return;

    final local_storage = await SharedPreferences.getInstance();
    final access_token = local_storage.getString('access_token');
    if (access_token != null) await _save_fcm_token(token);
  }

  // Handles tapping a notification that opened the app from terminated/background state
  void _handle_app_open(RemoteMessage? message) {
    if (message == null) return;
    // TODO: route to the relevant screen based on message.data['topic']
  }

  Future<void> _save_fcm_token(String token) async {
    await utils.CustomHttp.post(
      endpoint: '/account/fcm-token/add',
      body: {'fcm_token': token},
    );
  }
}
