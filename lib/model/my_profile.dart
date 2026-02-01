import 'package:fanari_v2/model/image.dart';

class MyselfCore {
  String uuid;
  String username;
  String role;
  String two_a_factor_auth_enabled;
  int? two_a_factor_auth_updated;

  MyselfCore({
    required this.uuid,
    required this.username,
    required this.role,
    required this.two_a_factor_auth_enabled,
    this.two_a_factor_auth_updated,
  });

  MyselfCore copyWith({
    String? uuid,
    String? username,
    String? role,
    String? two_a_factor_auth_enabled,
    int? two_a_factor_auth_updated,
  }) {
    return MyselfCore(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      role: role ?? this.role,
      two_a_factor_auth_enabled:
          two_a_factor_auth_enabled ?? this.two_a_factor_auth_enabled,
      two_a_factor_auth_updated:
          two_a_factor_auth_updated ?? this.two_a_factor_auth_updated,
    );
  }

  factory MyselfCore.fromJson(Map<String, dynamic> json) {
    return MyselfCore(
      uuid: json['uuid'],
      username: json['username'],
      role: json['role'],
      two_a_factor_auth_enabled: json['two_a_factor_auth_enabled'],
      two_a_factor_auth_updated: json['two_a_factor_auth_updated'],
    );
  }
}

class MyselfProfile {
  String first_name;
  String last_name;
  String? phone_number;
  int? date_of_birth;
  String? gender;
  ImageModel? profile_picture;
  String? biography;
  bool profile_verified;

  MyselfProfile({
    required this.first_name,
    required this.last_name,
    this.phone_number,
    this.date_of_birth,
    this.gender,
    this.profile_picture,
    this.biography,
    this.profile_verified = false,
  });

  MyselfProfile copyWith({
    String? first_name,
    String? last_name,
    String? phone_number,
    int? date_of_birth,
    String? gender,
    ImageModel? profile_picture,
    String? biography,
    bool? profile_verified,
  }) {
    return MyselfProfile(
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      phone_number: phone_number ?? this.phone_number,
      date_of_birth: date_of_birth ?? this.date_of_birth,
      gender: gender ?? this.gender,
      profile_picture: profile_picture ?? this.profile_picture,
      biography: biography ?? this.biography,
      profile_verified: profile_verified ?? this.profile_verified,
    );
  }

  factory MyselfProfile.fromJson(Map<String, dynamic> json) {
    return MyselfProfile(
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone_number: json['phone_number'],
      date_of_birth: json['date_of_birth'],
      gender: json['gender'],
      profile_picture: json['profile_picture'] != null
          ? ImageModel.fromJson(json['profile_picture'])
          : null,
      biography: json['biography'],
      profile_verified: json['profile_verified'],
    );
  }
}

class MyselfSocial {
  int like_count;
  int follower_count;
  int following_count;
  int friend_count;
  int blocked_count;

  MyselfSocial({
    required this.like_count,
    required this.follower_count,
    required this.following_count,
    required this.friend_count,
    required this.blocked_count,
  });

  MyselfSocial copyWith({
    int? like_count,
    int? follower_count,
    int? following_count,
    int? friend_count,
    int? blocked_count,
  }) {
    return MyselfSocial(
      like_count: like_count ?? this.like_count,
      follower_count: follower_count ?? this.follower_count,
      following_count: following_count ?? this.following_count,
      friend_count: friend_count ?? this.friend_count,
      blocked_count: blocked_count ?? this.blocked_count,
    );
  }

  factory MyselfSocial.fromJson(Map<String, dynamic> json) {
    return MyselfSocial(
      like_count: json['like_count'],
      follower_count: json['follower_count'],
      following_count: json['following_count'],
      friend_count: json['friend_count'],
      blocked_count: json['blocked_count'],
    );
  }
}

class MyselfModel {
  MyselfCore core;
  MyselfProfile profile;
  MyselfSocial social;

  MyselfModel({
    required this.core,
    required this.profile,
    required this.social,
  });

  MyselfModel copyWith({
    MyselfCore? core,
    MyselfProfile? profile,
    MyselfSocial? social,
  }) {
    return MyselfModel(
      core: core ?? this.core,
      profile: profile ?? this.profile,
      social: social ?? this.social,
    );
  }

  factory MyselfModel.fromJson(Map<String, dynamic> json) {
    return MyselfModel(
      core: MyselfCore.fromJson(json['core']),
      profile: MyselfProfile.fromJson(json['profile']),
      social: MyselfSocial.fromJson(json['social']),
    );
  }
}
