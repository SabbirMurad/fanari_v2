import 'package:fanari_v2/constants/credential.dart';

class EmojiModel {
  String uuid;
  String name;
  String original_url;
  String webp_url;

  EmojiModel({
    required this.name,
    required this.uuid,
    required this.original_url,
    required this.webp_url,
  });

  factory EmojiModel.fromJson(Map<String, dynamic> json) {
    final original_url =
        '${AppCredentials.domain}/api/emoji/original/${json['uuid']}';
    final webp_url = '${AppCredentials.domain}/api/emoji/webp/${json['uuid']}';

    return EmojiModel(
      name: json['name'],
      uuid: json['uuid'],
      original_url: original_url,
      webp_url: webp_url,
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
