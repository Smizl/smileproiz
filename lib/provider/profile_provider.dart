import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  bool _isLoggedIn = false;

  String _userName = 'GUEST USER';
  String _userEmail = 'guest@mork.store';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  /// ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // --- 1. Загружаем кэш ---
    final cached = prefs.getString('user_profile');
    if (cached != null) {
      final Map<String, dynamic> cachedData = Map<String, dynamic>.from(
        jsonDecode(cached),
      );
      _userName = (cachedData['username'] ?? cachedData['name'] ?? 'USER')
          .toString();
      _userEmail = (cachedData['email'] ?? 'guest@mork.store').toString();
      _isLoggedIn = true;
      notifyListeners(); // показываем кэш сразу
    }

    // --- 2. Загружаем свежие данные с сервера ---
    try {
      final freshProfileRaw =
          await _api.getUserProfile() ?? await _api.getUserData();

      if (freshProfileRaw != null && freshProfileRaw is Map<String, dynamic>) {
        _userName =
            (freshProfileRaw['username'] ?? freshProfileRaw['name'] ?? 'USER')
                .toString();
        _userEmail = (freshProfileRaw['email'] ?? 'guest@mork.store')
            .toString();
        _isLoggedIn = true;

        // сохраняем кэш
        await prefs.setString('user_profile', jsonEncode(freshProfileRaw));
      }
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      debugPrint('Ошибка при выходе: $e');
    }

    _isLoggedIn = false;
    _userName = 'GUEST USER';
    _userEmail = 'guest@mork.store';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');

    notifyListeners();
  }

  /// ================= UPDATE PROFILE =================
  Future<void> updateProfile(Map<String, dynamic> newProfile) async {
    _userName = (newProfile['username'] ?? newProfile['name'] ?? 'USER')
        .toString();
    _userEmail = (newProfile['email'] ?? 'guest@mork.store').toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(newProfile));

    notifyListeners();
  }
}
