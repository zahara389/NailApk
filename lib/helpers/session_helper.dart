import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionHelper {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  static Future<void> saveSession(String token, Map<String, dynamic> user) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_tokenKey, token);
    await pref.setString(_userKey, jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final pref = await SharedPreferences.getInstance();
    String? userStr = pref.getString(_userKey);
    return userStr != null ? jsonDecode(userStr) : null;
  }

  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}