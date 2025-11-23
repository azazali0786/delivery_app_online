import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Token operations
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data operations
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(_userKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(_userKey);
  }

  Future<void> removeUserData() async {
    await _prefs.remove(_userKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.containsKey(_tokenKey);
  }
}