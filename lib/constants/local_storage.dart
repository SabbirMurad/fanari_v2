import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static _localStorageAccessToken access_token = _localStorageAccessToken();
  static _localStorageAccessTokenValidTill access_token_valid_till =
      _localStorageAccessTokenValidTill();

  static _localStorageRefreshToken refresh_token = _localStorageRefreshToken();
  static _localStorageRole role = _localStorageRole();
  static _localStorageUserId user_id = _localStorageUserId();
  static _localStorageCookie cookie = _localStorageCookie();
}

class _localStorageCookie {
  static const String key = 'cookie';

  Future<bool> set(String value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setString(_localStorageCookie.key, value);
  }

  Future<String?> get() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString(_localStorageCookie.key);
  }
}

class _localStorageAccessToken {
  static const String key = 'access_token';

  Future<bool> set(String value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setString(_localStorageAccessToken.key, value);
  }

  Future<String?> get() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString(_localStorageAccessToken.key);
  }
}


class _localStorageAccessTokenValidTill {
  static const String key = 'access_token_valid_till';

  Future<bool> set(int value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setInt(_localStorageAccessTokenValidTill.key, value);
  }

  Future<int?> get() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getInt(_localStorageAccessTokenValidTill.key);
  }
}

class _localStorageRefreshToken {
  static const String key = 'refresh_token';

  Future<bool> set(String value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setString(_localStorageRefreshToken.key, value);
  }

  Future<String?> get() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString(_localStorageRefreshToken.key);
  }
}

class _localStorageRole {
  static const String key = 'role';

  Future<bool> set(String value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setString(_localStorageRole.key, value);
  }

  Future<String?> get() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString(_localStorageRole.key);
  }
}

class _localStorageUserId {
  static const String key = 'user_id';

  Future<bool> set(String value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setString(_localStorageUserId.key, value);
  }

  Future<String?> get() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString(_localStorageUserId.key);
  }
}
