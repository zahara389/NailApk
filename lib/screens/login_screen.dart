import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../services/auth_service.dart';
import '../helpers/session_helper.dart';

class LoginScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final Function(bool) setIsLoggedIn;
  final Function(String) setUserName;
  final Function(dynamic) setUserAddress;

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
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ===============================
  // HANDLE LOGIN (FIXED)
  // ===============================
  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("Harap isi username dan password");
      return;
    }

    setState(() => _isLoading = true);

    // 🔥 LOGIN → DAPAT TOKEN
    final token = await AuthService().login(username, password);

    setState(() => _isLoading = false);

    if (token != null) {
      // 🔥 AMBIL USER DARI SESSION
      final userData = await SessionHelper.getUser();

      debugPrint("LOGIN SUCCESS, TOKEN SIAP DIPAKAI");

      // 1. Set status login
      widget.setIsLoggedIn(true);

      // 2. Set nama user
      widget.setUserName(
        userData?['name'] ?? userData?['username'] ?? 'User',
      );

      // 3. Set alamat user (AMAN)
      widget.setUserAddress(
        Address(
          name: userData?['name'] ?? '',
          phone: userData?['phone'] ?? '',
          address: userData?['address'] ?? 'Alamat belum diatur',
          email: userData?['email'] ?? '',
        ),
      );

      // 4. Pindah ke Home
      widget.navigate('Home');
    } else {
      _showError("Username atau Password salah!");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _handleGuestLogin() {
    widget.setIsLoggedIn(false);
    widget.setUserName('Guest');
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
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
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
                const SizedBox(height: 100),
                const Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Username', LucideIcons.user),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: _inputDecoration('Password', LucideIcons.lock)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff,
                      ),
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // BUTTON LOGIN
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPink,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => widget.navigate('Register'),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _handleGuestLogin,
                    child: Text(
                      'Lanjut sebagai Guest',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: customPink),
      ),
    );
  }
}
