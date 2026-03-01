part of '../utils.dart';

/// Returns true when a network interface is available.
///
/// Pass [showError] to surface a toast when offline.
Future<bool> has_internet({bool show_error = false}) async {
  final connectivity_results = await Connectivity().checkConnectivity();

  if (connectivity_results.contains(ConnectivityResult.none)) {
    if (show_error) {
      show_custom_toast(
        text: 'Failed to establish connection, please check your internet connection.',
      );
    }
    return false;
  }

  return true;
}
