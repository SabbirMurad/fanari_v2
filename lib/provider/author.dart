import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/author.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fanari_v2/utils.dart' as utils;

part 'author.g.dart';

@Riverpod(keepAlive: true)
class AuthorNotifier extends _$AuthorNotifier {
  @override
  FutureOr<AuthorModel?> build() async {
    return null;
  }

  Future<bool> loadAuthorDetails() async {
    final authorDetails = await _getAuthorDetails();

    if (authorDetails == null) {
      throw 'Failed to load author details';
    }

    state = AsyncData(authorDetails);

    return true;
  }

  Future<AuthorModel?> _getAuthorDetails() async {
    if (!await utils.hasInternet()) {
      // final cacheUser = await _userFromCache();

      utils.showCustomToast(text: 'Please check your internet connection');
      return null;
    }

    final response = await utils.CustomHttp.get(
      endpoint: '/profile/myself/details',
    );

    if (!response.ok) return null;

    return AuthorModel.fromJson(response.data);
  }

  Future<bool> signIn({
    required String email_or_username,
    required String password,
  }) async {
    final response = await utils.CustomHttp.post(
      endpoint: '/auth/sign-in',
      body: {'email_or_username': email_or_username, 'password': password},
      needAuth: false,
    );

    if (!response.ok) return false;

    final data = response.data['auth_payload'];

    await LocalStorage.access_token.set(data['access_token']);
    await LocalStorage.access_token_valid_till.set(
      data['access_token_valid_till'],
    );
    await LocalStorage.refresh_token.set(data['refresh_token']);
    await LocalStorage.role.set(data['role']);
    await LocalStorage.user_id.set(data['user_id']);

    final authorDetails = await _getAuthorDetails();

    if (authorDetails == null) return false;

    state = AsyncData(authorDetails);

    return true;
  }

  Future<String?> signUp({
    required String first_name,
    required String last_name,
    required String email_address,
    required String username,
    required String password,
    required String confirm_password,
  }) async {
    final response = await utils.CustomHttp.post(
      endpoint: '/auth/sign-up',
      body: {
        'first_name': first_name,
        'last_name': last_name,
        'email_address': email_address,
        'username': username,
        'password': password,
        'confirm_password': confirm_password,
      },
      needAuth: false,
    );

    if (response.ok) {
      return response.data['user_id'];
    }

    return null;
  }

  Future<bool> validateEmail({
    required String user_id,
    required String otp,
  }) async {
    final response = await utils.CustomHttp.post(
      endpoint: '/auth/validate-email',
      body: {'user_id': user_id, 'verification_code': otp},
      needAuth: false,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      await LocalStorage.access_token.set(data['access_token']);
      await LocalStorage.access_token_valid_till.set(
        data['access_token_valid_till'],
      );
      await LocalStorage.refresh_token.set(data['refresh_token']);
      await LocalStorage.role.set(data['role']);
      await LocalStorage.user_id.set(data['user_id']);

      final authorDetails = await _getAuthorDetails();

      if (authorDetails == null) return false;

      state = AsyncData(authorDetails);

      return true;
    }

    return false;
  }

  void updateProfilePicture(ImageModel imageModel) async {
    AuthorModel myself = state.value!;

    state = AsyncData(
      myself.copyWith(
        profile: myself.profile.copyWith(profile_picture: imageModel),
      ),
    );
  }
}
