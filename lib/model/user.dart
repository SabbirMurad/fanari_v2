import 'package:fanari_v2/model/image.dart';

class UserModel {
  final String name;
  final ImageModel? image;
  final String username;
  final bool is_me;
  final bool following;
  final bool friend;

  const UserModel({
    required this.name,
    this.image,
    required this.username,
    required this.is_me,
    required this.following,
    required this.friend,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      username: json['username'],
      is_me: json['is_me'],
      following: json['following'],
      friend: json['friend'],
    );
  }

  static List<UserModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => UserModel.fromJson(item)).toList();
  }
}
