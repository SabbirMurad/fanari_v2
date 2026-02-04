import 'package:fanari_v2/model/image.dart';

class UserCore {
  String uuid;
  String username;
  String role;

  UserCore({required this.uuid, required this.username, required this.role});

  UserCore copyWith({
    String? uuid,
    String? username,
    String? role,
    bool? two_a_factor_auth_enabled,
    int? two_a_factor_auth_updated,
  }) {
    return UserCore(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      role: role ?? this.role,
    );
  }

  factory UserCore.fromJson(Map<String, dynamic> json) {
    return UserCore(
      uuid: json['uuid'],
      username: json['username'],
      role: json['role'],
    );
  }
}

class UserProfile {
  String first_name;
  String last_name;
  String? gender;
  ImageModel? profile_picture;
  String? biography;
  bool profile_verified;

  UserProfile({
    required this.first_name,
    required this.last_name,
    this.gender,
    this.profile_picture,
    this.biography,
    this.profile_verified = false,
  });

  UserProfile copyWith({
    String? first_name,
    String? last_name,
    String? phone_number,
    int? date_of_birth,
    String? gender,
    ImageModel? profile_picture,
    String? biography,
    bool? profile_verified,
  }) {
    return UserProfile(
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      gender: gender ?? this.gender,
      profile_picture: profile_picture ?? this.profile_picture,
      biography: biography ?? this.biography,
      profile_verified: profile_verified ?? this.profile_verified,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      first_name: json['first_name'],
      last_name: json['last_name'],
      gender: json['gender'],
      profile_picture: json['profile_picture'] != null
          ? ImageModel.fromJson(json['profile_picture'])
          : null,
      biography: json['biography'],
      profile_verified: json['profile_verified'],
    );
  }
}

class UserSocial {
  int like_count;
  int follower_count;
  int following_count;
  int friend_count;

  UserSocial({
    required this.like_count,
    required this.follower_count,
    required this.following_count,
    required this.friend_count,
  });

  UserSocial copyWith({
    int? like_count,
    int? follower_count,
    int? following_count,
    int? friend_count,
    int? blocked_count,
  }) {
    return UserSocial(
      like_count: like_count ?? this.like_count,
      follower_count: follower_count ?? this.follower_count,
      following_count: following_count ?? this.following_count,
      friend_count: friend_count ?? this.friend_count,
    );
  }

  factory UserSocial.fromJson(Map<String, dynamic> json) {
    return UserSocial(
      like_count: json['like_count'],
      follower_count: json['follower_count'],
      following_count: json['following_count'],
      friend_count: json['friend_count'],
    );
  }
}

class UserStat {
  bool myself;
  bool is_friend;
  bool is_following;
  bool is_follower;
  bool is_liked;
  bool is_blocked;

  UserStat({
    required this.myself,
    required this.is_friend,
    required this.is_following,
    required this.is_follower,
    required this.is_liked,
    required this.is_blocked,
  });

  UserStat copyWith({
    bool? myself,
    bool? is_friend,
    bool? is_following,
    bool? is_follower,
    bool? is_liked,
    bool? is_blocked,
  }) {
    return UserStat(
      myself: myself ?? this.myself,
      is_friend: is_friend ?? this.is_friend,
      is_following: is_following ?? this.is_following,
      is_follower: is_follower ?? this.is_follower,
      is_liked: is_liked ?? this.is_liked,
      is_blocked: is_blocked ?? this.is_blocked,
    );
  }

  factory UserStat.fromJson(Map<String, dynamic> json) {
    return UserStat(
      myself: json['myself'],
      is_friend: json['is_friend'],
      is_following: json['is_following'],
      is_follower: json['is_follower'],
      is_liked: json['is_liked'],
      is_blocked: json['is_blocked'],
    );
  }
}

class UserModel {
  UserCore core;
  UserProfile profile;
  UserSocial social;
  UserStat stat;

  UserModel({
    required this.core,
    required this.profile,
    required this.social,
    required this.stat,
  });

  UserModel copyWith({
    UserCore? core,
    UserProfile? profile,
    UserSocial? social,
    UserStat? stat,
  }) {
    return UserModel(
      core: core ?? this.core,
      profile: profile ?? this.profile,
      social: social ?? this.social,
      stat: stat ?? this.stat,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      core: UserCore.fromJson(json['core']),
      profile: UserProfile.fromJson(json['profile']),
      social: UserSocial.fromJson(json['social']),
      stat: UserStat.fromJson(json['stat']),
    );
  }
}
