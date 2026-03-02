import 'dart:async';
import 'dart:convert';

import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/firebase/firebase_api.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/socket/socket_events.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Listens to the socket's [IncomingTextEvent] stream and shows local
/// notifications for messages that arrive while the user is not looking at
/// that conversation.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  StreamSubscription<IncomingTextEvent>? _subscription;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Start listening. [is_visible] is a callback that returns true when the
  /// user currently has [conversation_id] open — notifications are suppressed
  /// in that case.
  void listen({
    required Stream<IncomingTextEvent> stream,
    required bool Function(String conversation_id) is_visible,
  }) {
    _subscription?.cancel();
    _subscription = stream.listen((event) {
      if (event.is_mine) return;
      if (is_visible(event.text.conversation_id)) return;
      _show(event.text);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  // ── Notification display ───────────────────────────────────────────────────

  Future<void> _show(TextModel text) async {
    printLine('Showing notification for conversation: ${text.conversation_id}');

    final group_id = text.conversation_id;
    final body = text.type == TextType.Text
        ? (text.text ?? '')
        : '📎 ${text.type.name}';

    // Thread messages per conversation for MessagingStyle grouping
    notification_texts[group_id] ??= [];
    notification_texts[group_id]!.add(
      Message(body, DateTime.now(), null),
    );

    final style = MessagingStyleInformation(
      const Person(name: ''),
      groupConversation: false,
      messages: notification_texts[group_id],
    );

    final actions = [
      AndroidNotificationAction(
        'reply_action_id',
        'Reply',
        inputs: [const AndroidNotificationActionInput(label: 'Type your reply')],
      ),
      const AndroidNotificationAction('mark_as_read_action_id', 'Mark as Read'),
    ];

    local_notification_plugin.show(
      group_id.hashCode,
      null,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          android_channel.id,
          android_channel.name,
          channelDescription: android_channel.description,
          icon: '@mipmap/launcher_icon',
          enableLights: true,
          color: AppColors.primary,
          styleInformation: style,
          actions: actions,
          priority: Priority.high,
          importance: Importance.high,
        ),
      ),
      payload: jsonEncode({
        'group_id': group_id,
        'conversation_id': text.conversation_id,
      }),
    );
  }
}
