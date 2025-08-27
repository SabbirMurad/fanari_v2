part of '../utils.dart';

class CopyBinaryStatus {
  final bool success;
  final String? errorMessage;

  CopyBinaryStatus({required this.success, this.errorMessage});
}

class FfmpegExecuteStatus {
  final bool success;
  final String? error;
  final String? output;

  FfmpegExecuteStatus({required this.success, this.error, this.output});
}

class FFmpegFlutter {
  // Copy the correct FFmpeg binary to a writable directory and make it executable
  static Future<CopyBinaryStatus> copyBinaryToInternalStorage() async {
    try {
      final String architecture = getDeviceArchitecture();
      String assetName;

      // Select the appropriate binary based on architecture
      switch (architecture) {
        case 'x86':
          assetName = 'assets/binary/ffmpeg/x86';
          break;
        case 'arm':
          assetName = 'assets/binary/ffmpeg/armeabi-v7a';
          break;
        default:
          print('Unsupported architecture: $architecture');
          return CopyBinaryStatus(
              success: false, errorMessage: 'Unsupported architecture');
      }

      // Get the app's documents directory to store the binary
      final directoryList = await getExternalCacheDirectories();
      // final dir = directoryList![0].path.split('/cache')[0] + '/files';


      final ffmpegFile = File('${directoryList![0].path}/ffmpeg');

      // if(await ffmpegFile.exists()) {
      //   await ffmpegFile.delete();
      // }

      if (!await ffmpegFile.exists()) {
        // Load the binary from assets and write it to the internal storage
        final byteData = await rootBundle.load(assetName);
        await ffmpegFile.writeAsBytes(byteData.buffer.asUint8List());
        print('FFmpeg binary copied to: ${ffmpegFile.path}');

        // Grant execution permission
        final result = await Process.run('chmod', ['777', ffmpegFile.path]);
        if (result.exitCode != 0) {
          print('Failed to set executable permissions: ${result.stderr}');
          return CopyBinaryStatus(
            success: false,
            errorMessage:
                'Failed to set executable permissions: ${result.stderr}',
          );
        } else {
          print('Permission set for ffmpeg');
        }
      }

      return CopyBinaryStatus(success: true, errorMessage: null);
    } catch (e) {
      print('Failed to copy FFmpeg binary: $e');
      return CopyBinaryStatus(
          success: false, errorMessage: 'Failed to copy FFmpeg binary: $e');
    }
  }

  // Detect the device architecture
  static String getDeviceArchitecture() {
    return Platform.operatingSystemVersion.contains('x86')
        ? 'x86'
        : 'arm'; // Default for modern Android devices
  }

  // Run FFmpeg command
  static Future<FfmpegExecuteStatus> execute(String command) async {
    try {
      final directoryList = await getExternalCacheDirectories();
      // final dir = directoryList![0].path.split('/cache')[0] + '/files';
      final binaryPath = '${directoryList![0].path}/ffmpeg';
      final process = await Process.run(binaryPath, command.split(' '));
      final output =
          await process.stdout.transform(SystemEncoding().decoder).join();
      final error =
          await process.stderr.transform(SystemEncoding().decoder).join();
      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        return FfmpegExecuteStatus(success: true, output: output);
      } else {
        print('FFmpeg error: $error');
        return FfmpegExecuteStatus(success: false, error: error);
      }
    } catch (e) {
      print('Error running FFmpeg command: $e');
      return FfmpegExecuteStatus(success: false, error: e.toString());
    }
  }
}
