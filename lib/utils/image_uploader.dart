part of '../utils.dart';

Future<List<String>?> uploadImages(List<File> images) async {
  var uri = Uri.parse('${AppCredentials.domain}/image');
  var request = http.MultipartRequest('POST', uri);

  for (int i = 0; i < images.length; i++) {
    var image = images[i];

    final bytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      debugPrint('');
      debugPrint('Error decoding image');
      debugPrint('');
      return null;
    }

    final blur_hash = await BlurhashFFI.encode(
      MemoryImage(bytes),
      componentX: 4,
      componentY: 3,
    );

    // Attach image
    request.files.add(
      await http.MultipartFile.fromPath(
        'images', // <-- same key for all images
        image.path,
        filename: image.uri.pathSegments.last,
      ),
    );

    // Attach metadata for that image (by index)
    request.fields['width_$i'] = '${decodedImage.width}';
    request.fields['height_$i'] = '${decodedImage.height}';
    request.fields['blur_hash_$i'] = blur_hash;
    request.fields['used_at_$i'] = 'Post';
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);
    List<String> imageIds = [];

    for (int i = 0; i < json.length; i++) {
      imageIds.add(json[i]);
    }
    return imageIds;
  } else {
    print('Upload failed: ${response.statusCode}');
    print('Upload failed: ${await response.stream.bytesToString()}');
    return null;
  }
}