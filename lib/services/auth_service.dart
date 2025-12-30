import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/session_helper.dart';

class AuthService {
  static const String baseUrl = "http://10.174.212.209:8000/api";

  // LOGIN
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {'Accept': 'application/json'},
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        await SessionHelper.saveSession(data['token'], data['user']);
        return data['user'];
      }
      return null;
    } catch (e) {
      print("AuthService Login Error: $e");
      return null;
    }
  }

  // REGISTER - FIX: Mengirim data mentah ke backend
  Future<bool> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {'Accept': 'application/json'}, // Penting untuk melihat pesan error detail
        body: data,
      );

      print("Register Status: ${response.statusCode}");
      print("Register Response: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("AuthService Register Error: $e");
      return false;
    }
  }
}