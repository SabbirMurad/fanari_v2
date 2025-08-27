import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

const iOS = DarwinInitializationSettings();
const android = AndroidInitializationSettings('@mipmap/ic_launcher');
const settings = InitializationSettings(android: android, iOS: iOS);

const androidChannel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.defaultImportance,
);

final localNotificationPlugin = FlutterLocalNotificationsPlugin()
  ..initialize(
    settings,
    onDidReceiveNotificationResponse: handleReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        handleReceiveBackgroundNotificationResponse,
  );

Future<void> handleReceiveNotificationResponse(
  NotificationResponse response,
) async {
  print('');
  print('response: ${response.actionId}');
  print('');

  AppRoutes.go('/home/notification');
}

Future<void> handleReceiveBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  print('');
  print('Background response handler called');
  print('response: ${response.actionId}');
  print('');

  if (response.actionId == 'follow_back_action_id') {
  } else if (response.actionId == 'accept_friend_request_action_id') {
  } else if (response.actionId == 'reject_friend_request_action_id') {
  } else if (response.actionId == 'reply_action_id') {
  } else if (response.actionId == 'mark_as_read_action_id') {}

  AppRoutes.go('/home/notification');
}

Future<void> handleMessage(RemoteMessage message) async {
  print('');
  print('Notification incoming');
  print('');

  List<AndroidNotificationAction> actions = [];
  StyleInformation? styleInformation;

  final data = message.data;
  if (data['topic'] == NotificationType.StartedFollowing.name) {
    actions.add(
      AndroidNotificationAction('follow_back_action_id', 'Follow Back'),
    );
  } else if (data['topic'] == NotificationType.FriendRequest.name) {
    actions.add(
      AndroidNotificationAction('accept_friend_request_action_id', 'Accept'),
    );
    actions.add(
      AndroidNotificationAction('reject_friend_request_action_id', 'Reject'),
    );
  } else if (data['topic'] == NotificationType.Message.name) {
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
  } else if (data['topic'] == NotificationType.FriendRequestAccept.name) {
  } else if (data['topic'] == NotificationType.FriendRequestReject.name) {
  } else if (data['topic'] == NotificationType.LikedProfile.name) {
  } else if (data['topic'] == NotificationType.LikedPost.name) {
  } else if (data['topic'] == NotificationType.CommentedPost.name) {
  } else if (data['topic'] == NotificationType.System.name) {
  } else {
    print('\nNotification topic not implemented: ${data['topic']}\n');
    return;
  }

  if (styleInformation == null) {
    String? imagePath;
    if (data['image'] != null) {
      imagePath = await downloadAndSaveImage(
        data['image'],
        'notification_image.jpg',
      );
    }

    styleInformation = imagePath != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(imagePath),
            contentTitle: data['title'],
            summaryText: data['body'],
          )
        : null;
  }

  localNotificationPlugin.show(
    data['group_id'] != null ? int.parse(data['group_id']) : message.hashCode,
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

Future<String?> downloadAndSaveImage(String url, String fileName) async {
  try {
    final response = await http.get(Uri.parse(url));
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) await file.delete();
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  } catch (e) {
    print("");
    print("Error downloading image: $e");
    print("");
    return null;
  }
}

Map<String, List<Message>> notification_texts = {};

enum NotificationType {
  System,
  LikedProfile,
  LikedPost,
  CommentedPost,
  StartedFollowing,
  FriendRequest,
  FriendRequestReject,
  FriendRequestAccept,
  Message,
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();

    initPushNotification();

    if (!await utils.hasInternet()) return;

    if (token != null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? accessToken = localStorage.getString('access_token');
      if (accessToken != null) {
        saveFcmToken(token);
      }
    }
  }

  saveFcmToken(String token) async {
    await utils.CustomHttp.post(
      endpoint: '/account/fcm-token/add',
      body: {'fcm_token': token},
    );
  }

  void handleMessage2(RemoteMessage? message) {
    if (message == null) return;
    //TODO: handle redirect
    //This if for routing to notification page
    // routes.myRoutes.go('/home/notification');
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage2);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage2);
    //TODO: Not sure why this being used
    FirebaseMessaging.onBackgroundMessage(handleMessage);

    FirebaseMessaging.onMessage.listen(handleMessage);
  }
}
