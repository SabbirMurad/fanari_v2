class AudioModel {
  final String uuid;
  final int duration;
  final int size;
  final String type;

  AudioModel({
    required this.uuid,
    required this.duration,
    required this.size,
    required this.type,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      uuid: json['uuid'],
      duration: json['duration'],
      size: json['size'],
      type: json['type'],
    );
  }
}
