class EmojiModel {
  String uuid;
  String name;
  String url;
  String webp_url;

  EmojiModel({
    required this.name,
    required this.uuid,
    required this.url,
    required this.webp_url,
  });

  factory EmojiModel.fromJson(Map<String, dynamic> json) {
    return EmojiModel(
      name: json['name'],
      uuid: json['uuid'],
      url: json['url'],
      webp_url: json['webp_url'],
    );
  }

  static List<EmojiModel> fromJsonList(List<dynamic> json) {
    List<EmojiModel> emojis = [];

    for (var i = 0; i < json.length; i++) {
      emojis.add(EmojiModel.fromJson(json[i]));
    }

    return emojis;
  }
}
