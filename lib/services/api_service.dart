import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // -----------------------------
  // ✅ Host config (удобно для раздачи)
  // -----------------------------
  static const String _defaultHost = 'http://172.20.10.3:8080';
  static const String _hostKey = 'api_host';

  static const int retryCount = 3;

  // База именно users
  static String _usersBase(String host) => '$host/api/users';

  /// Поставить хост (например, когда IP поменялся)
  /// Пример: await ApiService.setHost('http://172.20.10.7:8080');
  static Future<void> setHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hostKey, host);
  }

  /// Получить текущий хост
  static Future<String> getHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hostKey) ?? _defaultHost;
  }

  // -----------------------------
  // Retry helper
  // -----------------------------
  Future<http.Response> _retryRequest(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    while (attempts < retryCount) {
      try {
        final response = await request();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        attempts++;
        if (attempts >= retryCount) return response;
        await Future.delayed(const Duration(seconds: 2));
      } on SocketException {
        attempts++;
        if (attempts >= retryCount) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      } catch (_) {
        attempts++;
        if (attempts >= retryCount) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('Failed request after $retryCount attempts');
  }

  // -----------------------------
  // ApiResponse parsing
  // -----------------------------
  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw Exception('Invalid JSON');
  }

  /// ✅ Безопаснее: data может быть Map или что-то другое
  Map<String, dynamic>? _extractData(Map<String, dynamic> apiResp) {
    final data = apiResp['data'];
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  bool _extractSuccess(Map<String, dynamic> apiResp) =>
      apiResp['success'] == true;

  String _extractMessage(Map<String, dynamic> apiResp) {
    final msg = apiResp['message'];
    return msg?.toString() ?? '';
  }

  // -----------------------------
  // Local storage: user + token
  // -----------------------------
  Future<Map<String, dynamic>?> _getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<void> _saveLocalUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    if (t == null || t.isEmpty) return null;
    return t;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _mergeUser(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming,
  ) {
    final merged = <String, dynamic>{...existing, ...incoming};

    merged['id'] ??= existing['id'];
    merged['username'] ??= existing['username'] ?? 'USER';
    merged['email'] ??= existing['email'] ?? '';
    merged['role'] ??= existing['role'] ?? 'user';
    merged['pushEnabled'] ??= existing['pushEnabled'] ?? true;
    merged['fcmToken'] ??= existing['fcmToken'];

    // ✅ не затирать телефон пустым значением
    final incPhone = incoming['phone']?.toString() ?? '';
    if (incPhone.trim().isEmpty) {
      merged['phone'] = existing['phone'];
    }

    return merged;
  }

  Future<bool> isLoggedIn() async {
    final user = await _getLocalUser();
    final token = await _getToken();
    return user != null &&
        (user['email']?.toString().isNotEmpty ?? false) &&
        token != null &&
        token.isNotEmpty;
  }

  // -----------------------------
  // PUSH
  // -----------------------------
  Future<void> updatePushToken(int userId, String token) async {
    final host = await getHost();
    final baseUrl = _usersBase(host);

    final url = Uri.parse('$baseUrl/$userId/push-setting');
    final response = await _retryRequest(
      () async => http.put(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'fcmToken': token}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления push токена: ${response.body}');
    }
  }

  Future<void> updatePushSetting(int userId, bool enabled) async {
    final host = await getHost();
    final baseUrl = _usersBase(host);

    final url = Uri.parse('$baseUrl/$userId/push-setting');
    final response = await _retryRequest(
      () async => http.put(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'pushEnabled': enabled}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления push уведомлений: ${response.body}');
    }
  }

  // -----------------------------
  // GET PROFILE
  // -----------------------------
  Future<Map<String, dynamic>?> getUserProfile() async {
    final host = await getHost();
    final baseUrl = _usersBase(host);

    final local = await _getLocalUser();
    if (local == null) return null;

    final id = local['id'];
    if (id == null) return local;

    final response = await _retryRequest(
      () async =>
          http.get(Uri.parse('$baseUrl/$id'), headers: await _authHeaders()),
    );

    // если токен просрочен/неверный
    if (response.statusCode == 401) {
      return local; // мягко
    }

    final apiResp = _decodeBody(response.body);
    if (!_extractSuccess(apiResp)) return local;

    final data = _extractData(apiResp);
    if (data == null) return local;

    final merged = _mergeUser(local, data);
    await _saveLocalUser(merged);
    return merged;
  }

  Future<Map<String, dynamic>?> getUserData() async => _getLocalUser();

  // -----------------------------
  // AUTH
  // -----------------------------
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final host = await getHost();
    final baseUrl = _usersBase(host);

    final response = await _retryRequest(
      () => http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ),
    );

    final apiResp = _decodeBody(response.body);
    final ok = _extractSuccess(apiResp);
    final msg = _extractMessage(apiResp);
    final data = _extractData(apiResp);

    if (!ok || data == null) {
      return {
        'success': false,
        'message': msg.isNotEmpty ? msg : response.body,
      };
    }

    data['email'] ??= email;
    data['username'] ??= username;
    data['role'] ??= 'user';

    await _saveLocalUser(data);

    return {'success': true, 'message': msg, 'user': data};
  }

  /// Backend: data: { token, user }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final host = await getHost();
    final baseUrl = _usersBase(host);

    final response = await _retryRequest(
      () => http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );

    final apiResp = _decodeBody(response.body);
    final ok = _extractSuccess(apiResp);
    final msg = _extractMessage(apiResp);
    final data = _extractData(apiResp);

    if (!ok || data == null) {
      return {
        'success': false,
        'message': msg.isNotEmpty ? msg : 'Неверный email или пароль',
      };
    }

    final token = data['token']?.toString();
    final userObj = data['user'];

    if (token == null || token.isEmpty || userObj == null) {
      return {
        'success': false,
        'message': 'Неверный формат ответа от сервера (нет token/user)',
      };
    }

    final user = Map<String, dynamic>.from(userObj as Map);

    user['email'] ??= email;
    user['username'] ??= email.split('@')[0];
    user['role'] ??= 'user';

    final existing = await _getLocalUser() ?? {};
    final merged = _mergeUser(existing, user);

    await _saveToken(token);
    await _saveLocalUser(merged);

    return {'success': true, 'message': msg, 'user': merged, 'token': token};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
  }

  // -----------------------------
  // UPDATE USER
  // -----------------------------
  Future<Map<String, dynamic>> updateEmail(int userId, String newEmail) async =>
      _updateField(userId, {'email': newEmail});

  Future<Map<String, dynamic>> updatePassword(
    int userId,
    String newPassword,
  ) async => _updateField(userId, {'password': newPassword});

  Future<Map<String, dynamic>> updateUsername(
    int userId,
    String newUsername,
  ) async => _updateField(userId, {'username': newUsername});

  Future<Map<String, dynamic>> updatePhone(int userId, String newPhone) async =>
      _updateField(userId, {'phone': newPhone});

  Future<Map<String, dynamic>> _updateField(
    int userId,
    Map<String, dynamic> body,
  ) async {
    final host = await getHost();
    final baseUrl = _usersBase(host);

    final response = await _retryRequest(
      () async => http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      ),
    );

    if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Не авторизован (token отсутствует/просрочен)',
      };
    }

    final apiResp = _decodeBody(response.body);
    final ok = _extractSuccess(apiResp);
    final msg = _extractMessage(apiResp);
    final data = _extractData(apiResp);

    if (!ok || data == null) {
      return {
        'success': false,
        'message': msg.isNotEmpty ? msg : response.body,
      };
    }

    final existing = await _getLocalUser() ?? {};
    final merged = _mergeUser(existing, data);

    await _saveLocalUser(merged);
    return {'success': true, 'user': merged};
  }
}
