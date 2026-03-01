class MentionModel {
  final String username;
  final String user_id;
  final int start_index;
  final int end_index;

  const MentionModel({
    required this.user_id,
    required this.username,
    required this.start_index,
    required this.end_index,
  });

  factory MentionModel.fromJson(Map<String, dynamic> json) {
    return MentionModel(
      user_id: json['user_id'],
      username: json['username'],
      start_index: json['start_index'],
      end_index: json['end_index'],
    );
  }

  static List<MentionModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => MentionModel.fromJson(item)).toList();
  }
}
