import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';

class ApiExceptionClient implements Exception {
  final int statusCode;
  final String message;
  ApiExceptionClient(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Cliente HTTP centralizado para consumir track60-backend (Spring Boot).
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _accessTokenKey = 'track60_access_token';
  static const _refreshTokenKey = 'track60_refresh_token';

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.get(uri, headers: await _headers(auth: auth)).timeout(ApiConfig.timeout);
    return _handleResponse(res, () => get(path, auth: auth), auth: auth);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http
        .post(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _handleResponse(res, () => post(path, body, auth: auth), auth: auth);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http
        .patch(uri, headers: await _headers(auth: auth), body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _handleResponse(res, () => patch(path, body: body, auth: auth), auth: auth);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http
        .put(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _handleResponse(res, () => put(path, body, auth: auth), auth: auth);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.delete(uri, headers: await _headers(auth: auth)).timeout(ApiConfig.timeout);
    return _handleResponse(res, () => delete(path, auth: auth), auth: auth);
  }

  Future<dynamic> _handleResponse(
    http.Response res,
    Future<dynamic> Function() retryFn, {
    required bool auth,
    bool isRetry = false,
  }) async {
    if (res.statusCode == 401 && auth && !isRetry) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return retryFn();
      }
    }

    final Map<String, dynamic> parsed = res.body.isNotEmpty
        ? (jsonDecode(res.body) as Map<String, dynamic>)
        : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parsed['data'];
    }

    final msg = parsed['message']?.toString() ?? 'Error de comunicación (${res.statusCode})';
    throw ApiExceptionClient(res.statusCode, msg);
  }

  Future<bool> _tryRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString(_refreshTokenKey);
      if (refresh == null || refresh.isEmpty) return false;
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
      final res = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'refreshToken': refresh}))
          .timeout(ApiConfig.timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        await saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (_) {}
    await clearTokens();
    return false;
  }
}

