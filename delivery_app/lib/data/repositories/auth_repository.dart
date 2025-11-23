import 'dart:convert';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        {'email': email, 'password': password},
        includeAuth: false,
      );

      // Save token
      await _storageService.saveToken(response['token']);

      // Save user data
      await _storageService.saveUserData(jsonEncode(response['user']));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> verifyToken() async {
    try {
      final token = _storageService.getToken();
      if (token == null) return null;

      final response = await _apiService.get(ApiConstants.verify);
      final user = UserModel.fromJson(response['user']);

      // Update user data
      await _storageService.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      await logout();
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = _storageService.getUserData();
      if (userData == null) return null;

      return UserModel.fromJson(jsonDecode(userData));
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }

  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }
}