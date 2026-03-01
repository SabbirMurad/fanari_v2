part of '../utils.dart';

// ── Result types ──────────────────────────────────────────────────────────────

class FfmpegCopyResult {
  final bool success;
  final String? error_message;

  const FfmpegCopyResult({required this.success, this.error_message});
}

class FfmpegExecuteResult {
  final bool success;
  final String? error;
  final String? output;

  const FfmpegExecuteResult({required this.success, this.error, this.output});
}

// ── FFmpeg helper ─────────────────────────────────────────────────────────────

class FfmpegFlutter {
  FfmpegFlutter._();

  /// Returns the ABI directory name for the current device architecture.
  static String _device_abi() =>
      Platform.operatingSystemVersion.contains('x86') ? 'x86' : 'armeabi-v7a';

  /// Returns the path where the binary is (or will be) stored.
  static Future<String> _binary_path() async {
    final dirs = await getExternalCacheDirectories();
    return '${dirs!.first.path}/ffmpeg';
  }

  /// Copies the correct FFmpeg binary from assets to internal storage and
  /// marks it executable. Safe to call repeatedly — skips if already present.
  static Future<FfmpegCopyResult> copy_binary_to_internal_storage() async {
    try {
      final abi = _device_abi();
      final asset_path = switch (abi) {
        'x86' => 'assets/binary/ffmpeg/x86',
        _ => 'assets/binary/ffmpeg/armeabi-v7a',
      };

      final binary_path = await _binary_path();
      final binary_file = File(binary_path);

      if (await binary_file.exists()) {
        return const FfmpegCopyResult(success: true);
      }

      final byte_data = await rootBundle.load(asset_path);
      await binary_file.writeAsBytes(byte_data.buffer.asUint8List());

      final chmod = await Process.run('chmod', ['777', binary_path]);
      if (chmod.exitCode != 0) {
        return FfmpegCopyResult(
          success: false,
          error_message: 'Failed to set executable permissions: ${chmod.stderr}',
        );
      }

      printLine('FFmpeg binary ready at $binary_path');
      return const FfmpegCopyResult(success: true);
    } catch (e) {
      return FfmpegCopyResult(
        success: false,
        error_message: 'Failed to copy FFmpeg binary: $e',
      );
    }
  }

  /// Runs an FFmpeg [command] string using the binary in internal storage.
  ///
  /// Example: `await FfmpegFlutter.execute('-i input.mp4 output.mp3')`
  static Future<FfmpegExecuteResult> execute(String command) async {
    try {
      final binary_path = await _binary_path();
      final process = await Process.run(binary_path, command.split(' '));

      final output = await process.stdout
          .transform(const SystemEncoding().decoder)
          .join();
      final error = await process.stderr
          .transform(const SystemEncoding().decoder)
          .join();

      if (process.exitCode == 0) {
        return FfmpegExecuteResult(success: true, output: output);
      }

      printLine('FFmpeg error: $error');
      return FfmpegExecuteResult(success: false, error: error);
    } catch (e) {
      printLine('FFmpeg exception: $e');
      return FfmpegExecuteResult(success: false, error: e.toString());
    }
  }
}
