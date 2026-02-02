import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/text.dart';

enum ConversationType { Single, Group }

class ConversationCore {
  final String uuid;
  final ConversationType type;
  int last_message_at;

  ConversationCore({
    required this.uuid,
    required this.type,
    required this.last_message_at,
  });

  factory ConversationCore.fromJson(Map<String, dynamic> json) {
    return ConversationCore(
      uuid: json['uuid'],
      type: json['type'] == 'group'
          ? ConversationType.Group
          : ConversationType.Single,
      last_message_at: json['last_message_at'],
    );
  }

  ConversationCore copyWith({String? uuid, ConversationType? type}) {
    return ConversationCore(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      last_message_at: this.last_message_at,
    );
  }
}

class ConversationGroupMetadata {
  final String name;
  ImageModel? image;

  ConversationGroupMetadata({required this.name, required this.image});

  factory ConversationGroupMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationGroupMetadata(
      name: json['name'],
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
    );
  }

  ConversationGroupMetadata copyWith({String? name, ImageModel? image}) {
    return ConversationGroupMetadata(
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }
}

class ConversationSingleMetadata {
  final String user_id;
  final String first_name;
  final String last_name;
  final ImageModel? image;
  bool online;
  int last_seen;

  ConversationSingleMetadata({
    required this.user_id,
    required this.first_name,
    required this.last_name,
    required this.image,
    required this.online,
    required this.last_seen,
  });

  factory ConversationSingleMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationSingleMetadata(
      user_id: json['user_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      online: json['online'],
      last_seen: json['last_seen'],
    );
  }

  ConversationSingleMetadata copyWith({
    String? uuid,
    String? first_name,
    String? last_name,
    ImageModel? image,
    bool? online,
    int? last_seen,
  }) {
    return ConversationSingleMetadata(
      user_id: uuid ?? this.user_id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      image: image ?? this.image,
      online: online ?? this.online,
      last_seen: last_seen ?? this.last_seen,
    );
  }
}

class ConversationModel {
  final ConversationCore core;
  final ConversationGroupMetadata? group_metadata;
  final ConversationSingleMetadata? single_metadata;

  bool typing;
  List<TextModel> texts;

  ConversationModel({
    required this.core,
    this.group_metadata,
    this.single_metadata,
    required this.texts,
    this.typing = false,
  });

  static ConversationModel fromJson(Map<String, dynamic> json, String myId) {
    final texts = <TextModel>[];
    if (json['texts'] != null) {
      for (var i = 0; i < json['texts'].length; i++) {
        final model = TextModel.fromJson(json['texts'][i], myId);
        Future.delayed(Duration(milliseconds: 20), () {
          //! This is done so that posts loads quickly and info that might take time to load doesn't block the UI
          model.load3rdPartyInfos();
        });
        texts.add(model);
      }
    }

    return ConversationModel(
      core: ConversationCore.fromJson(json['core']),
      group_metadata: json['group_metadata'] != null
          ? ConversationGroupMetadata.fromJson(json['group_metadata'])
          : null,
      single_metadata: json['single_metadata'] != null
          ? ConversationSingleMetadata.fromJson(json['single_metadata'])
          : null,
      texts: texts,
      typing: json['typing'],
    );
  }

  ConversationModel copyWith({
    ConversationCore? core,
    ConversationGroupMetadata? group_metadata,
    ConversationSingleMetadata? single_metadata,
    List<TextModel>? texts,
    bool? typing,
  }) {
    return ConversationModel(
      core: core ?? this.core,
      group_metadata: group_metadata ?? this.group_metadata,
      single_metadata: single_metadata ?? this.single_metadata,
      texts: texts ?? this.texts,
      typing: typing ?? this.typing,
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
