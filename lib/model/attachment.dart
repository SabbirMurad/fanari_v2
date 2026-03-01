class AttachmentModel {
  String type;
  String uuid;
  String name;
  int size;

  AttachmentModel({
    required this.type,
    required this.uuid,
    required this.name,
    required this.size,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      type: json['type'],
      uuid: json['uuid'],
      name: json['name'],
      size: json['size'],
    );
  }
}
