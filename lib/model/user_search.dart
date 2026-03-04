class UserSearchModel {
  final String? profile_picture;
  final String username;
  final String uuid;
  final String first_name;
  final String last_name;

  const UserSearchModel({
    required this.uuid,
    required this.username,
    required this.first_name,
    required this.last_name,
    this.profile_picture,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      uuid: json['uuid'],
      username: json['username'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      profile_picture: json['profile_picture'],
    );
  }

  static List<UserSearchModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => UserSearchModel.fromJson(item)).toList();
  }
}