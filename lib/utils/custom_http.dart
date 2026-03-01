part of '../utils.dart';

// ── Result type ───────────────────────────────────────────────────────────────

class CustomHttpResult {
  final dynamic data;
  final int status_code;
  final String? error;
  final bool ok;

  const CustomHttpResult({
    this.data,
    required this.status_code,
    this.error,
    required this.ok,
  });
}

// ── HTTP methods enum ─────────────────────────────────────────────────────────

enum _HttpMethod { post, put, patch }

// ── Client ────────────────────────────────────────────────────────────────────

class CustomHttp {
  CustomHttp._();

  // ── Public API ─────────────────────────────────────────────────────────────

  static Future<CustomHttpResult> get({
    required String endpoint,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queries,
  }) async {
    if (!await has_internet(show_error: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet connection found!',
      );
    }

    try {
      final resolved_headers = await _build_headers(
        need_auth: need_auth,
        extra: headers,
      );
      if (resolved_headers == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired, please sign in again!',
        );
      }

      final url = _build_url('/api$endpoint', queries);

      _log_request('GET', url, resolved_headers);

      final response = await http.get(
        Uri.parse(url),
        headers: resolved_headers,
      );
      return _handle_response(response, show_floating_error);
    } catch (e) {
      _log_error('GET', endpoint, e);
      return CustomHttpResult(status_code: -2, error: e.toString(), ok: false);
    }
  }

  static Future<CustomHttpResult> post({
    required String endpoint,
    bool add_api_prefix = true,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.post,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  static Future<CustomHttpResult> put({
    required String endpoint,
    bool add_api_prefix = true,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.put,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  static Future<CustomHttpResult> patch({
    required String endpoint,
    bool add_api_prefix = true,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.patch,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  static Future<CustomHttpResult> _send_with_body({
    required _HttpMethod method,
    required String endpoint,
    required bool add_api_prefix,
    Map<String, String>? headers,
    dynamic body,
    required bool show_floating_error,
    required bool need_auth,
    Map<String, dynamic>? queries,
  }) async {
    if (!await has_internet(show_error: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet connection found!',
      );
    }

    try {
      final resolved_headers = await _build_headers(
        need_auth: need_auth,
        extra: headers,
      );
      if (resolved_headers == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired, please sign in again!',
        );
      }

      final prefix = add_api_prefix ? '/api' : '';
      final url = _build_url(
        '${AppCredentials.domain}$prefix$endpoint',
        queries,
      );

      _log_request(method.name.toUpperCase(), url, resolved_headers);

      final encoded_body = jsonEncode(body ?? {});
      final encoding = Encoding.getByName('utf-8');

      late http.Response response;

      switch (method) {
        case _HttpMethod.post:
          response = await http.post(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
            encoding: encoding,
          );
        case _HttpMethod.put:
          response = await http.put(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
            encoding: encoding,
          );
        case _HttpMethod.patch:
          response = await http.patch(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
            encoding: encoding,
          );
      }

      final set_cookie = response.headers['set-cookie'];
      if (set_cookie != null) {
        await LocalStorage.cookie.set(set_cookie);
      }

      return _handle_response(response, show_floating_error);
    } catch (e) {
      _log_error(method.name.toUpperCase(), endpoint, e);
      return CustomHttpResult(status_code: -2, error: e.toString(), ok: false);
    }
  }

  /// Builds auth + content-type headers, refreshing the access token if needed.
  /// Returns null when re-auth fails (caller should treat as 401).
  static Future<Map<String, String>?> _build_headers({
    required bool need_auth,
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (need_auth) {
      final valid_till = await LocalStorage.access_token_valid_till.get();
      final is_expired =
          valid_till == null ||
          valid_till < DateTime.now().millisecondsSinceEpoch;

      if (is_expired && !await _refresh_access_token()) {
        AppRoutes.go(AppRoutes.landing);
        return null;
      }

      final access_token = await LocalStorage.access_token.get();
      headers['Authorization'] = 'Bearer $access_token';

      final cookie = await LocalStorage.cookie.get();
      if (cookie != null) headers['Cookie'] = cookie;
    }

    if (extra != null) headers.addAll(extra);

    return headers;
  }

  /// Attempts to get a new access token using the refresh token.
  /// Returns true on success.
  static Future<bool> _refresh_access_token() async {
    final refresh_token = await LocalStorage.refresh_token.get();
    final user_id = await LocalStorage.user_id.get();
    final role = await LocalStorage.role.get();

    if (refresh_token == null || user_id == null || role == null) {
      printLine('Token refresh failed — missing credentials');
      printLine(
        'refresh_token: $refresh_token | user_id: $user_id | role: $role',
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppCredentials.domain}/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refresh_token,
          'user_id': user_id,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await LocalStorage.access_token_valid_till.set(
          data['access_token_valid_till'],
        );
        await LocalStorage.access_token.set(data['access_token']);
        return true;
      }

      printLine('Token refresh failed — status: ${response.statusCode}');
      return false;
    } catch (e) {
      printLine('Token refresh exception: $e');
      return false;
    }
  }

  /// Builds a URL string, appending [queries] as query parameters.
  static String _build_url(String base, Map<String, dynamic>? queries) {
    if (queries == null || queries.isEmpty) return base;

    final buffer = StringBuffer('$base?');

    queries.forEach((key, value) {
      if (value is List) {
        for (final item in value) {
          buffer.write('$key=$item&');
        }
      } else {
        buffer.write('$key=$value&');
      }
    });

    final raw = buffer.toString();
    return raw.substring(0, raw.length - 1);
  }

  /// Parses an [http.Response] into a [CustomHttpResult].
  static CustomHttpResult _handle_response(
    http.Response response,
    bool show_floating_error,
  ) {
    const success_codes = {200, 201, 202, 203, 204};

    if (success_codes.contains(response.statusCode)) {
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return CustomHttpResult(
        ok: true,
        status_code: response.statusCode,
        data: data,
      );
    }

    final message = _parse_error_message(response);

    if (show_floating_error) show_custom_toast(text: message);

    return CustomHttpResult(
      status_code: response.statusCode,
      error: message,
      ok: false,
    );
  }

  static String _parse_error_message(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] as String? ?? 'Something went wrong.';
    } catch (_) {
      if (response.statusCode == 404) return 'Endpoint not found!';
      if (response.statusCode == 400) return response.body;
      debugPrint(
        'Unhandled HTTP error: ${response.statusCode}\n${response.body}',
      );
      return 'Something went wrong.';
    }
  }

  static void _log_request(
    String method,
    String url,
    Map<String, String> headers,
  ) {
    debugPrint('');
    debugPrint('<===== $method REQUEST =====>');
    debugPrint('url: $url');
    debugPrint('headers: $headers');
    debugPrint('');
  }

  static void _log_error(String method, String endpoint, Object error) {
    debugPrint('');
    debugPrint('<===== $method REQUEST =====>');
    debugPrint('url: $endpoint');
    debugPrint('error: $error');
    debugPrint('');
  }
}
