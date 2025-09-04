import 'package:fanari_v2/model/image.dart';

class UserModel {
  final String name;
  final ImageModel? image;
  final String username;
  final bool isMe;
  final bool following;
  final bool friend;

  const UserModel({
    required this.name,
    this.image,
    required this.username,
    required this.isMe,
    required this.following,
    required this.friend,
  });
}
