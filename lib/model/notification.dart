import 'package:fanari_v2/model/image.dart';

class NotificationModel {
  String uuid;
  bool seen;
  int created_at;
  ImageModel? image;
  String topic;
  Map<String, dynamic>? payload;

  NotificationModel({
    required this.uuid,
    required this.seen,
    required this.created_at,
    required this.topic,
    this.image,
    this.payload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      uuid: json['uuid'],
      seen: json['seen'],
      created_at: json['created_at'],
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      topic: json['topic'],
      payload: json['payload'],
    );
  }

  static List<NotificationModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => NotificationModel.fromJson(item)).toList();
  }
}
