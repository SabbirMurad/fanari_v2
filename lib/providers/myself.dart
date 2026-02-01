import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/my_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanari_v2/utils.dart' as utils;

part 'myself.g.dart';

@Riverpod(keepAlive: true)
class MyselfNotifier extends _$MyselfNotifier {
  @override
  FutureOr<MyselfModel?> build() async {
    return await loadUserData();
  }

  Future<MyselfModel?> loadUserData() async {
    if (!await utils.hasInternet()) {
      // final cacheUser = await _userFromCache();

      utils.showCustomToast(text: 'Please check your internet connection');
      return null;
    }

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('user_id')!;

    final response = await utils.CustomHttp.post(
      endpoint: '/account/short-details',
      body: {'user_id': userId},
    );

    if (response.statusCode != 200) return null;

    final userFromServer = MyselfModel.fromJson(response.data);

    return userFromServer;
  }

  // Future<bool> _updateUserCache(UserModel serverUser) async {
  //   final ServerImageModel? profilePicture = serverUser.profilePicture;
  //   String? imageData;
  //   if (profilePicture != null) {
  //     imageData = jsonEncode(profilePicture);
  //   }

  //   return await sqlite.update(
  //     table: 'user',
  //     data: {
  //       'full_name': serverUser.fullName,
  //       'biography': serverUser.biography,
  //       'profile_picture': imageData,
  //       'following_count': serverUser.followingCount,
  //       'follower_count': serverUser.followerCount,
  //       'like_count': serverUser.likeCount,
  //     },
  //     where: 'username = ?',
  //     whereArgs: [serverUser.username],
  //   );
  // }

  // Future<bool> _saveUserToCache(UserModel serverUser) async {
  //   final ServerImageModel? profilePicture = serverUser.profilePicture;
  //   String? imageData;
  //   if (profilePicture != null) {
  //     imageData = jsonEncode(profilePicture);
  //   }

  //   return await sqlite.insert(
  //     table: 'user',
  //     data: {
  //       'uuid': serverUser.uuid,
  //       'username': serverUser.username,
  //       'full_name': serverUser.fullName,
  //       'biography': serverUser.biography,
  //       'profile_picture': imageData,
  //       'following_count': serverUser.followingCount,
  //       'follower_count': serverUser.followerCount,
  //       'like_count': serverUser.likeCount,
  //     },
  //   );
  // }

  // Future<UserModel?> _userFromCache() async {
  //   final data = await sqlite.query(table: 'user');

  //   if (data.isNotEmpty) {
  //     return UserModel.fromJsonSqlite(data[0]);
  //   } else {
  //     return null;
  //   }
  // }

  void updateProfilePicture(ImageModel imageModel) async {
    MyselfModel myself = state.value!;

    state = AsyncData(
      myself.copyWith(
        profile: myself.profile.copyWith(profile_picture: imageModel),
      ),
    );
  }
}
