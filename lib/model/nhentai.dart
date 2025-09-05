class NhentaiBookModel {
  final String id;
  final String media_id;
  final NhentaiBookTitle title;
  final NhentaiBookImagesModel images;
  final int num_pages;
  final List<NhentaiBookTagModel> tags;

  static final String base_url = 'https://i.nhentai.net';

  const NhentaiBookModel({
    required this.id,
    required this.media_id,
    required this.title,
    required this.images,
    required this.num_pages,
    required this.tags,
  });

  factory NhentaiBookModel.fromJson(Map<String, dynamic> json) {
    return NhentaiBookModel(
      id: json['id'].toString(),
      media_id: json['media_id'].toString(),
      title: NhentaiBookTitle(
        english: json['title']['english'],
        japanese: json['title']['japanese'],
        pretty: json['title']['pretty'],
      ),
      images: NhentaiBookImagesModel.fromJson(json['images']),
      num_pages: json['num_pages'],
      tags: NhentaiBookTagModel.fromJsonList(json['tags']),
    );
  }

  String? getPage({required int index, String? baseURL}) {
    if (index >= this.images.pages.length) return null;
    final page = this.images.pages[index];
    return '${baseURL ?? NhentaiBookModel.base_url}/galleries/${this.media_id}/${index + 1}.${page.type}';
  }

  List<String> getAllPages({String? baseURL}) {
    List<String> pages = [];
    this.images.pages.asMap().forEach((index, page) {
      String url = baseURL ?? NhentaiBookModel.base_url;

      if (page.type == 'webp') {
        url = 'https://i1.nhentai.net';
      }

      pages.add('${url}/galleries/${this.media_id}/${index + 1}.${page.type}');
    });

    return pages;
  }

  String getCover({String baseURL = 'https://t.nhentai.net'}) {
    if (this.images.cover.type == 'webp') {
      baseURL = 'https://t1.nhentai.net';
    }

    return '${baseURL}/galleries/${this.media_id}/cover.${this.images.cover.type}';
  }
}

class NhentaiBookTagModel {
  final int id;
  final String type;
  final String name;
  final String url;
  final int count;

  const NhentaiBookTagModel({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
    required this.count,
  });

  factory NhentaiBookTagModel.fromJson(Map<String, dynamic> json) {
    return NhentaiBookTagModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
      count: json['count'],
    );
  }

  static List<NhentaiBookTagModel> fromJsonList(json) {
    List<NhentaiBookTagModel> tags = [];

    for (var i = 0; i < json.length; i++) {
      tags.add(NhentaiBookTagModel.fromJson(json[i]));
    }

    return tags;
  }
}

class NhentaiBookImagesModel {
  final List<NhentaiBookImageModel> pages;
  final NhentaiBookImageModel cover;
  final NhentaiBookImageModel thumbnail;

  const NhentaiBookImagesModel({
    required this.pages,
    required this.cover,
    required this.thumbnail,
  });

  factory NhentaiBookImagesModel.fromJson(Map<String, dynamic> json) {
    return NhentaiBookImagesModel(
      pages: NhentaiBookImageModel.fromJsonList(json['pages']),
      cover: NhentaiBookImageModel.fromJson(json['cover']),
      thumbnail: NhentaiBookImageModel.fromJson(json['thumbnail']),
    );
  }
}

class NhentaiBookImageModel {
  final String type;
  final int width;
  final int height;

  const NhentaiBookImageModel({
    required this.type,
    required this.width,
    required this.height,
  });

  static Map<String, String> typeMap = {
    "j": 'jpg',
    "p": 'png',
    "g": 'gif',
    "w": 'webp',
  };

  static List<NhentaiBookImageModel> fromJsonList(json) {
    List<NhentaiBookImageModel> image = [];

    for (var i = 0; i < json.length; i++) {
      image.add(NhentaiBookImageModel.fromJson(json[i]));
    }

    return image;
  }

  factory NhentaiBookImageModel.fromJson(Map<String, dynamic> json) {
    return NhentaiBookImageModel(
      type: typeMap[json['t']]!,
      width: json['w'],
      height: json['h'],
    );
  }
}

class NhentaiBookTitle {
  final String english;
  final String japanese;
  final String pretty;

  const NhentaiBookTitle({
    required this.english,
    required this.japanese,
    required this.pretty,
  });
}
