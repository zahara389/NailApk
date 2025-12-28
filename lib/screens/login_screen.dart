import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class LoginScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final Function(bool) setIsLoggedIn;
  final Function(String) setUserName;
  final Function(Address) setUserAddress;

  const LoginScreen({
    super.key,
    required this.navigate,
    required this.setIsLoggedIn,
    required this.setUserName,
    required this.setUserAddress,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final TextEditingController _usernameController = TextEditingController(text: 'Sarah');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');

  void _handleLogin() {
    final input = _usernameController.text.trim();
    String displayName;
    if (input.contains('@')) {
      final local = input.split('@').first;
      displayName = local.isEmpty ? 'Sarah' : '${local[0].toUpperCase()}${local.substring(1)}';
    } else {
      displayName = input.isEmpty ? 'Sarah' : input;
    }

    widget.setIsLoggedIn(true);
    widget.setUserName(displayName);
    widget.setUserAddress(Address(
      name: displayName,
      phone: '0812-3456-7890',
      address: 'Jl. Bojongsoang No. 10, Kecamatan Bojongsoang, Kab. Bandung, 40288',
      email: input.contains('@') ? input : 'sarah.nail@mail.com',
    ));
    widget.navigate('Home');
  }

  void _handleGuestLogin() {
    widget.setIsLoggedIn(false);
    widget.setUserName('Guest');
    widget.setUserAddress(Address(
      name: 'Guest',
      phone: '',
      address: 'Harap login untuk mengisi alamat.',
      email: '',
    ));
    widget.navigate('Home');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                const SizedBox(height: 80),
                const Text(
                  'Welcome back',
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                    shadowColor: customPink.withAlpha((0.4 * 255).round()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sign in', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.chevronRight, size: 20, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tautan Sign Up
                Center(
                  child: TextButton(
                    onPressed: () => widget.navigate('Register'),
                    child: const Text('Create one', style: TextStyle(decoration: TextDecoration.underline)),
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
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}