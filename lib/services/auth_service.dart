import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../helpers/session_helper.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // LOGIN
  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {'Accept': 'application/json'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final token = data['token'];

        // 🔥 INI YANG PENTING
        debugPrint("TOKEN LOGIN: $token");

        await SessionHelper.saveSession(token, data['user']);

        // 🔥 KEMBALIKAN TOKEN
        return token;
      }

      debugPrint("LOGIN FAILED: ${response.body}");
      return null;

    } catch (e) {
      debugPrint("AuthService Login Error: $e");
      return null;
    }
  }

  // REGISTER (TIDAK PERLU DIUBAH)
  Future<bool> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {'Accept': 'application/json'},
        body: data,
      );

      debugPrint("Register Status: ${response.statusCode}");
      debugPrint("Register Response: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("AuthService Register Error: $e");
      return false;
    }
  }
}
