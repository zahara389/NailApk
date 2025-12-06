import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class LoginScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final Function(bool) setIsLoggedIn;
  final Function(String) setUserName;

  const LoginScreen({
    super.key,
    required this.navigate,
    required this.setIsLoggedIn,
    required this.setUserName,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final TextEditingController _usernameController = TextEditingController(text: 'Sarah'); // Dummy data
  final TextEditingController _passwordController = TextEditingController(text: 'password123'); // Dummy data

  void _handleLogin() {
    // Simulasi Login Sukses
    widget.setIsLoggedIn(true);
    widget.setUserName(_usernameController.text.isEmpty ? 'Sarah' : _usernameController.text);
    widget.navigate('Home');
  }

  void _handleGuestLogin() {
    widget.setIsLoggedIn(false);
    widget.navigate('Home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bentuk Lingkaran Pink di Kiri Atas
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: customPinkLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk dengan akun Anda.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Form Input
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Nama Pengguna',
                    prefixIcon: const Icon(LucideIcons.user, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: customPink)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(LucideIcons.lock, color: Colors.grey),
                    suffixIcon: InkWell(
                      onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                      child: Icon(_passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.grey),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: customPink)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Login
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPink,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    shadowColor: customPink.withOpacity(0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Login', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(LucideIcons.chevronRight, size: 20, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tautan Sign Up
                Center(
                  child: InkWell(
                    onTap: () => widget.navigate('Register'),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(color: customPink, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Lanjut sebagai Guest
                Center(
                  child: TextButton(
                    onPressed: _handleGuestLogin,
                    child: Text('Lanjut sebagai Guest', style: TextStyle(color: Colors.grey.shade500, fontSize: 14, decoration: TextDecoration.underline)),
                  ),
                ),
                const SizedBox(height: 50), // Padding Bawah
              ],
            ),
          ),
        ],
      ),
    );
  }
}