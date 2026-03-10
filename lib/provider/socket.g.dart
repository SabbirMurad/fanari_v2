// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$socketStateNotifierHash() =>
    r'a69d71f08baad53e0cd50f8de57125b8abe75678';

/// Tracks [SocketState] as a reactive value widgets can watch.
///
/// Copied from [SocketStateNotifier].
@ProviderFor(SocketStateNotifier)
final socketStateNotifierProvider =
    NotifierProvider<SocketStateNotifier, SocketState>.internal(
      SocketStateNotifier.new,
      name: r'socketStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$socketStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SocketStateNotifier = Notifier<SocketState>;
String _$socketListenerHash() => r'7db8ebe2155f276b54e5aa76ccc339f3e56529f6';

/// Wires the socket's event streams to the appropriate Riverpod notifiers.
/// Keep this alive so the subscriptions are never cancelled while the app runs.
///
/// Copied from [SocketListener].
@ProviderFor(SocketListener)
final socketListenerProvider = NotifierProvider<SocketListener, void>.internal(
  SocketListener.new,
  name: r'socketListenerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socketListenerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SocketListener = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
