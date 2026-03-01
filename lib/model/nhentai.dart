// ── Private sub-models ────────────────────────────────────────────────────────

class _NhentaiBookTitle {
  final String english;
  final String japanese;
  final String pretty;

  const _NhentaiBookTitle({
    required this.english,
    required this.japanese,
    required this.pretty,
  });
}

class _NhentaiBookImage {
  final String type;
  final int width;
  final int height;

  static const _type_map = {'j': 'jpg', 'p': 'png', 'g': 'gif', 'w': 'webp'};

  const _NhentaiBookImage({
    required this.type,
    required this.width,
    required this.height,
  });

  factory _NhentaiBookImage.fromJson(Map<String, dynamic> json) {
    return _NhentaiBookImage(
      type: _type_map[json['t']]!,
      width: json['w'],
      height: json['h'],
    );
  }

  static List<_NhentaiBookImage> listFromJson(List<dynamic> json) {
    return json.map((item) => _NhentaiBookImage.fromJson(item)).toList();
  }
}

class _NhentaiBookImages {
  final List<_NhentaiBookImage> pages;
  final _NhentaiBookImage cover;
  final _NhentaiBookImage thumbnail;

  const _NhentaiBookImages({
    required this.pages,
    required this.cover,
    required this.thumbnail,
  });

  factory _NhentaiBookImages.fromJson(Map<String, dynamic> json) {
    return _NhentaiBookImages(
      pages: _NhentaiBookImage.listFromJson(json['pages']),
      cover: _NhentaiBookImage.fromJson(json['cover']),
      thumbnail: _NhentaiBookImage.fromJson(json['thumbnail']),
    );
  }
}

class _NhentaiBookTag {
  final int id;
  final String type;
  final String name;
  final String url;
  final int count;

  const _NhentaiBookTag({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
    required this.count,
  });

  factory _NhentaiBookTag.fromJson(Map<String, dynamic> json) {
    return _NhentaiBookTag(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
      count: json['count'],
    );
  }

  static List<_NhentaiBookTag> listFromJson(List<dynamic> json) {
    return json.map((item) => _NhentaiBookTag.fromJson(item)).toList();
  }
}

// ── Public model ──────────────────────────────────────────────────────────────

class NhentaiBookModel {
  final String id;
  final String media_id;
  final _NhentaiBookTitle title;
  final _NhentaiBookImages images;
  final int num_pages;
  final List<_NhentaiBookTag> tags;

  static const String base_url = 'https://i.nhentai.net';

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
      title: _NhentaiBookTitle(
        english: json['title']['english'],
        japanese: json['title']['japanese'],
        pretty: json['title']['pretty'],
      ),
      images: _NhentaiBookImages.fromJson(json['images']),
      num_pages: json['num_pages'],
      tags: _NhentaiBookTag.listFromJson(json['tags']),
    );
  }

  String? get_page({required int index, String? base_url}) {
    if (index >= images.pages.length) return null;
    final page = images.pages[index];
    return '${base_url ?? NhentaiBookModel.base_url}/galleries/$media_id/${index + 1}.${page.type}';
  }

  List<String> get_all_pages({String? base_url}) {
    return images.pages.asMap().entries.map((entry) {
      final index = entry.key;
      final page = entry.value;
      String url = base_url ?? NhentaiBookModel.base_url;
      if (page.type == 'webp') url = 'https://i1.nhentai.net';
      return '$url/galleries/$media_id/${index + 1}.${page.type}';
    }).toList();
  }

  String get_cover({String base_url = 'https://t.nhentai.net'}) {
    final cover = images.cover;
    if (cover.type == 'webp') base_url = 'https://t1.nhentai.net';
    return '$base_url/galleries/$media_id/cover.${cover.type}';
  }
}
