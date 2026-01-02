import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../helpers/session_helper.dart';

class AuthService {
  // FIX: Tambahkan port :8000 sesuai dengan yang ada di browser kamu
  static const String baseUrl = "http://10.174.212.209:8000/api";

  // LOGIN
  Future<String?> login(String username, String password) async {
    try {
      final url = Uri.parse("$baseUrl/login");
      
      // Debug untuk memastikan URL sudah benar di console
      debugPrint("Mencoba login ke: $url");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // Penting agar Laravel kirim error JSON, bukan HTML
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      debugPrint("Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Pastikan key 'token' dan 'user' sesuai dengan response JSON Laravel kamu
        final token = data['token'];
        final userData = data['user'];

        if (token != null) {
          debugPrint("TOKEN LOGIN BERHASIL: $token");
          await SessionHelper.saveSession(token, userData);
          return token;
        }
      }

      // Jika gagal, kita bisa lihat pesan error dari Laravel
      debugPrint("LOGIN FAILED: ${response.body}");
      return null;

    } catch (e) {
      debugPrint("AuthService Login Error: $e");
      return null;
    }
  }

  // REGISTER
  Future<bool> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {'Accept': 'application/json'},
        body: data,
      );

      debugPrint("Register Status: ${response.statusCode}");
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("AuthService Register Error: $e");
      return false;
    }
  }
}