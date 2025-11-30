import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static const String tokenKey = 'token';
  static const String userIDKey = 'userID';

  // Simpan Token
  Future<void> setToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      print('✅ [UserInfo] Token saved: $token');
    } catch (e) {
      print('❌ [UserInfo] Error saving token: $e');
      rethrow;
    }
  }

  // Ambil Token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      print('✅ [UserInfo] Token retrieved: $token');
      return token;
    } catch (e) {
      print('❌ [UserInfo] Error getting token: $e');
      return null;
    }
  }

  // Simpan UserID
  Future<void> setUserID(int userID) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(userIDKey, userID);
      print('✅ [UserInfo] UserID saved: $userID');
    } catch (e) {
      print('❌ [UserInfo] Error saving userID: $e');
      rethrow;
    }
  }

  // Ambil UserID
  Future<int?> getUserID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getInt(userIDKey);
      print('✅ [UserInfo] UserID retrieved: $userID');
      return userID;
    } catch (e) {
      print('❌ [UserInfo] Error getting userID: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ [UserInfo] Logout success, data cleared');
    } catch (e) {
      print('❌ [UserInfo] Error logout: $e');
      rethrow;
    }
  }
}
