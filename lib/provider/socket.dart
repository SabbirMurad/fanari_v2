import 'dart:async';

import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/service/notification_service.dart';
import 'package:fanari_v2/socket/socket.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'socket.g.dart';

// ── Socket provider ───────────────────────────────────────────────────────────

/// Exposes the singleton [CustomSocket] so widgets can call send methods
/// without reaching for a global.
final socket_provider = Provider<CustomSocket>((ref) {
  return CustomSocket.instance;
});

// ── Connection state provider ─────────────────────────────────────────────────

/// Tracks [SocketState] as a reactive value widgets can watch.
@Riverpod(keepAlive: true)
class SocketStateNotifier extends _$SocketStateNotifier {
  StreamSubscription<SocketState>? _sub;

  @override
  SocketState build() {
    _sub = CustomSocket.instance.state_changes.listen((s) {
      state = s;
      printLine('Socket state → $s');
    });

    ref.onDispose(() => _sub?.cancel());

    return CustomSocket.instance.state;
  }
}

// ── Socket listener provider ──────────────────────────────────────────────────

/// Wires the socket's event streams to the appropriate Riverpod notifiers.
/// Keep this alive so the subscriptions are never cancelled while the app runs.
@Riverpod(keepAlive: true)
class SocketListener extends _$SocketListener {
  final List<StreamSubscription> _subs = [];

  @override
  void build() {
    final socket = CustomSocket.instance;
    final conv_notifier = ref.read(conversationNotifierProvider.notifier);

    // ── Incoming messages ────────────────────────────────────────────────────
    _subs.add(
      socket.incoming_texts.listen((event) {
        conv_notifier.add_message(
          conversation_id: event.text.conversation_id,
          message_input: event.text,
        );
      }),
    );

    // ── Typing indicators ────────────────────────────────────────────────────
    _subs.add(
      socket.typing_events.listen((event) {
        conv_notifier.update_typing(event);
      }),
    );

    // ── Presence (online/offline) ────────────────────────────────────────────
    _subs.add(
      socket.presence_events.listen((event) {
        conv_notifier.update_online(event);
      }),
    );

    // ── Message seen (read receipts) ──────────────────────────────────────────
    _subs.add(
      socket.message_seen_events.listen((event) {
        conv_notifier.handle_message_seen(event);
      }),
    );

    // ── Notifications ────────────────────────────────────────────────────────
    NotificationService.instance.listen(
      stream: socket.incoming_texts,
      is_visible: (conversation_id) =>
          socket.in_chat_list_page &&
          (socket.opened_conversation_id == conversation_id ||
              socket.opened_conversation_id == null),
    );

    ref.onDispose(() {
      for (final sub in _subs) sub.cancel();
      NotificationService.instance.dispose();
    });
  }
}

// ── Connect helper ────────────────────────────────────────────────────────────

/// Call this once after login. Connects the socket and activates the listener.
Future<void> initialize_socket(
  WidgetRef ref, {
  required String access_token,
}) async {
  // Ensure the listener provider is alive before the first message arrives.
  ref.read(socketListenerProvider);
  await Future.microtask(() {}); // let the provider graph settle
  await CustomSocket.instance.connect(access_token: access_token);
}
