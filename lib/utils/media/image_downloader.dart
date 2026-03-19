part of '../media.dart';

Future<void> downloadImage(
  BuildContext context,
  String url,
  String fileName, {
  Uint8List? localBytes,
}) async {
  try {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading image...')));

    Uint8List bytes;
    if (localBytes != null) {
      bytes = localBytes;
    } else {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image.');
      }
      bytes = response.bodyBytes;
    }

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);

    MediaStore.appFolder = 'Fanari';
    final mediaStore = MediaStore();
    final result = await mediaStore.saveFile(
      tempFilePath: tempFile.path,
      dirType: DirType.download,
      dirName: DirName.download,
      relativePath: 'Fanari/Images',
    );

    if (!context.mounted) return;
    if (result!.saveStatus == SaveStatus.created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to Downloads folder')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save image')));
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error downloading image: $e')));
  }
}
