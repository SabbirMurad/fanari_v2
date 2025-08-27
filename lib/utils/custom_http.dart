part of '../utils.dart';

class CustomHttpResult {
  final dynamic data;
  final int statusCode;
  final String? error;

  const CustomHttpResult({this.data, required this.statusCode, this.error});
}

enum CommonCustomMethods { POST, PUT, PATCH }

class CustomHttp {
  static Future<CustomHttpResult> get({
    required String endpoint,
    bool showFloatingError = true,
    bool needAuth = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queries,
  }) async {
    if (!await hasInternet(showError: true)) {
      return CustomHttpResult(
        statusCode: -1,
        error: 'No internet connection found!',
      );
    }

    try {
      Map<String, String> _headers = {'Content-Type': 'application/json'};

      if (needAuth) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        String? accessToken = localStorage.getString('access_token');
        _headers['Authorization'] = 'Bearer $accessToken';

        final cookie = localStorage.getString('cookie');
        if (cookie != null) {
          _headers['Cookie'] = cookie;
        }
      }

      if (headers != null) {
        _headers.addAll(headers);
      }

      var url = '${AppCredentials.domain}/api$endpoint';

      if (queries != null) {
        url += '?';

        queries.forEach((key, value) {
          if (value.runtimeType == List) {
            for (var i = 0; i < value.length; i++) {
              url += '$key=${value[i]}&';
            }
          } else {
            url += '$key=$value&';
          }
        });
        url = url.substring(0, url.length - 1);
      }

      final uri = Uri.parse(url);

      debugPrint('');
      debugPrint('<===== GET REQUEST =====>');
      debugPrint('url: $url');
      debugPrint('headers: $_headers');
      debugPrint('');

      final response = await http.get(uri, headers: _headers);
      return handleResponse(response, showFloatingError);
    } catch (e) {
      debugPrint('');
      debugPrint('<===== GET REQUEST =====>');
      debugPrint('url: $endpoint');
      debugPrint('error: ${e.toString()}');
      debugPrint('');
      return CustomHttpResult(statusCode: -2, error: e.toString());
    }
  }

  static Future<CustomHttpResult> post({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
  }) async {
    return commonRequests(
      endpoint: endpoint,
      headers: headers,
      body: body,
      showFloatingError: showFloatingError,
      needAuth: needAuth,
      method: CommonCustomMethods.POST,
    );
  }

  static Future<CustomHttpResult> commonRequests({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
    required CommonCustomMethods method,
  }) async {
    if (!await hasInternet(showError: true)) {
      return CustomHttpResult(
        statusCode: -1,
        error: 'No internet connection found!',
      );
    }

    try {
      Map<String, String> _headers = {'Content-Type': 'application/json'};
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      if (needAuth) {
        String? accessToken = localStorage.getString('access_token');
        _headers['Authorization'] = 'Bearer $accessToken';

        final cookie = localStorage.getString('cookie');
        if (cookie != null) {
          _headers['Cookie'] = cookie;
        }
      }

      if (headers != null) {
        _headers.addAll(headers);
      }

      final url = '${AppCredentials.domain}/api$endpoint';
      final uri = Uri.parse(url);

      debugPrint('');
      debugPrint('<===== ${method.name} REQUEST =====>');
      debugPrint('url: $url');
      debugPrint('headers: $_headers');
      debugPrint('');

      late http.Response response;

      if (method == CommonCustomMethods.POST) {
        response = await http.post(
          uri,
          body: jsonEncode(body ?? {}),
          headers: _headers,
          encoding: Encoding.getByName('utf-8'),
        );
      } else if (method == CommonCustomMethods.PUT) {
        response = await http.put(
          uri,
          body: jsonEncode(body ?? {}),
          headers: _headers,
          encoding: Encoding.getByName('utf-8'),
        );
      } else if (method == CommonCustomMethods.PATCH) {
        response = await http.patch(
          uri,
          body: jsonEncode(body ?? {}),
          headers: _headers,
          encoding: Encoding.getByName('utf-8'),
        );
      }

      if (response.headers['set-cookie'] != null) {
        String cookie = response.headers['set-cookie']!;
        localStorage.setString('cookie', cookie);
      }

      return handleResponse(response, showFloatingError);
    } catch (e) {
      debugPrint('');
      debugPrint('<===== ${method.name} REQUEST =====>');
      debugPrint('url: $endpoint');
      debugPrint('error: ${e.toString()}');
      debugPrint('');
      return CustomHttpResult(statusCode: -2, error: e.toString());
    }
  }

  static Future<String?> newAccessToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? refreshToken = localStorage.getString('refresh_token');
    String? role = localStorage.getString('role');
    String? userId = localStorage.getString('user_id');

    if (refreshToken == null || role == null || userId == null) {
      localStorage.remove('access_token');
      localStorage.remove('refresh_token');
      localStorage.remove('role');
      localStorage.remove('user_id');
      return null;
    }

    final postData = {
      'refresh_token': refreshToken,
      'role': role,
      'user_id': userId,
    };

    var response = await http.post(
      Uri.parse('${AppCredentials.domain}/api/account/access-token/new'),
      body: jsonEncode(postData),
      headers: {'Content-Type': 'application/json'},
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String accessToken = data['access_token'];
      return accessToken;
    } else {
      localStorage.remove('access_token');
      localStorage.remove('refresh_token');
      localStorage.remove('role');
      localStorage.remove('user_id');
      return null;
    }
  }

  static CustomHttpResult handleResponse(
    http.Response response,
    bool showFloatingError,
  ) {
    if (response.statusCode == 200) {
      Uint8List encodedJson = Uint8List.fromList(response.body.codeUnits);
      return CustomHttpResult(
        statusCode: response.statusCode,
        data: jsonDecode(utf8.decode(encodedJson)),
      );
    } else {
      late String message;
      try {
        final body = jsonDecode(response.body);
        message = body['message'];
      } catch (e) {
        if (response.statusCode == 404) {
          message = 'End point not found!';
        } else if (response.statusCode == 400) {
          message = response.body.toString();
        } else {
          message = "Something went wrong ...";
        }
      }

      if (showFloatingError) {
        showCustomToast(text: message);
      }

      return CustomHttpResult(statusCode: response.statusCode, error: message);
    }
  }
}
