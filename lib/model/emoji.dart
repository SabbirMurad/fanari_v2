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
    return EmojiModel(
      name: json['name'],
      uuid: json['uuid'],
      original_url: '${AppCredentials.domain}/api/emoji/original/${json['uuid']}',
      webp_url: '${AppCredentials.domain}/api/emoji/webp/${json['uuid']}',
    );
  }

  static List<EmojiModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => EmojiModel.fromJson(item)).toList();
  }
}
