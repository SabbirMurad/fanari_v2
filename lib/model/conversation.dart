import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/text.dart';

class ConversationModel {
  final String uuid;
  final String user_id;
  final String name;
  final ImageModel? image;
  bool online;
  int last_seen;
  bool typing;
  List<TextModel> texts;

  ConversationModel({
    required this.uuid,
    required this.user_id,
    required this.name,
    required this.image,
    required this.online,
    required this.texts,
    required this.last_seen,
    this.typing = false,
  });

  static ConversationModel fromJson(Map<String, dynamic> json, String myId) {
    final texts = <TextModel>[];
    if (json['texts'] != null) {
      for (var i = 0; i < json['texts'].length; i++) {
        final model = TextModel.fromJson(json['texts'][i], myId);
        Future.delayed(Duration(milliseconds: 100), () {
          //! This is done so that posts loads quickly and info that might take time to load doesn't block the UI
          model.load3rdPartyInfos();
        });
        texts.add(model);
      }
    }

    return ConversationModel(
      uuid: json['uuid'],
      name: json['name'],
      image: json['image'] == null ? null : ImageModel.fromJson(json['image']),
      online: json['online'],
      texts: texts,
      last_seen: json['last_seen'],
      user_id: json['user_id'],
    );
  }

  ConversationModel copyWith({
    String? uuid,
    String? name,
    ImageModel? image,
    bool? online,
    List<TextModel>? texts,
    int? last_seen,
    String? user_id,
    TextModel? last_message,
  }) {
    return ConversationModel(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      image: image ?? this.image,
      online: online ?? this.online,
      texts: texts ?? this.texts,
      last_seen: last_seen ?? this.last_seen,
      user_id: user_id ?? this.user_id,
    );
  }

  static List<ConversationModel> fromJsonList(dynamic json, String myId) {
    List<ConversationModel> newPosts = [];
    for (var i = 0; i < json.length; i++) {
      newPosts.add(ConversationModel.fromJson(json[i], myId));
    }

    return newPosts;
  }
}
