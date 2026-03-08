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
      type: json['type'] == 'Group'
          ? ConversationType.Group
          : ConversationType.Single,
      last_message_at: json['last_message_at'],
    );
  }

  ConversationCore copyWith({
    String? uuid,
    ConversationType? type,
    int? last_message_at,
  }) {
    return ConversationCore(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      last_message_at: last_message_at ?? this.last_message_at,
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
    String? user_id,
    String? first_name,
    String? last_name,
    ImageModel? image,
    bool? online,
    int? last_seen,
  }) {
    return ConversationSingleMetadata(
      user_id: user_id ?? this.user_id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      image: image ?? this.image,
      online: online ?? this.online,
      last_seen: last_seen ?? this.last_seen,
    );
  }
}

class ConversationCommonMetadata {
  bool is_favorite;
  bool is_muted;

  ConversationCommonMetadata({
    required this.is_favorite,
    required this.is_muted,
  });

  factory ConversationCommonMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationCommonMetadata(
      is_favorite: json['is_favorite'],
      is_muted: json['is_muted'],
    );
  }

  ConversationCommonMetadata copyWith({bool? is_favorite, bool? is_muted}) {
    return ConversationCommonMetadata(
      is_favorite: is_favorite ?? this.is_favorite,
      is_muted: is_muted ?? this.is_muted,
    );
  }
}

class ConversationModel {
  final ConversationCore core;
  final ConversationGroupMetadata? group_metadata;
  final ConversationSingleMetadata? single_metadata;
  final ConversationCommonMetadata common_metadata;

  bool typing;
  List<TextModel> texts;
  bool initial_text_loaded;
  bool texts_loading;
  bool has_more_texts;
  TextModel? last_text;

  ConversationModel({
    required this.core,
    required this.common_metadata,
    this.group_metadata,
    this.single_metadata,
    this.texts = const [],
    this.typing = false,
    this.initial_text_loaded = false,
    this.texts_loading = false,
    this.has_more_texts = true,
    this.last_text,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json, {
    required String my_id,
  }) {
    TextModel? last_text;
    if (json['last_text'] != null) {
      last_text = TextModel.fromJson(
        json['last_text'] as Map<String, dynamic>,
        my_id: my_id,
      );
    }

    return ConversationModel(
      core: ConversationCore.fromJson(json['core']),
      common_metadata: ConversationCommonMetadata.fromJson(
        json['common_metadata'],
      ),
      group_metadata: json['group_metadata'] != null
          ? ConversationGroupMetadata.fromJson(json['group_metadata'])
          : null,
      single_metadata: json['single_metadata'] != null
          ? ConversationSingleMetadata.fromJson(json['single_metadata'])
          : null,
      last_text: last_text,
    );
  }

  ConversationModel copyWith({
    ConversationCore? core,
    ConversationCommonMetadata? common_metadata,
    ConversationGroupMetadata? group_metadata,
    ConversationSingleMetadata? single_metadata,
    List<TextModel>? texts,
    bool? typing,
    bool? initial_text_loaded,
    bool? texts_loading,
    bool? has_more_texts,
    TextModel? last_text,
  }) {
    return ConversationModel(
      core: core ?? this.core,
      common_metadata: common_metadata ?? this.common_metadata,
      group_metadata: group_metadata ?? this.group_metadata,
      single_metadata: single_metadata ?? this.single_metadata,
      texts: texts ?? this.texts,
      typing: typing ?? this.typing,
      initial_text_loaded: initial_text_loaded ?? this.initial_text_loaded,
      texts_loading: texts_loading ?? this.texts_loading,
      has_more_texts: has_more_texts ?? this.has_more_texts,
      last_text: last_text ?? this.last_text,
    );
  }

  static List<ConversationModel> fromJsonList(
    List<dynamic> json, {
    required String my_id,
  }) {
    return json
        .map((item) => ConversationModel.fromJson(item, my_id: my_id))
        .toList();
  }
}
