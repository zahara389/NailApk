import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart'; // Pastikan customPink dll ada di sini
import '../services/auth_service.dart';
import '../helpers/session_helper.dart';

class LoginScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final Function(bool) setIsLoggedIn;
  final Function(String) setUserName;
  final Function(dynamic) setUserAddress; // Sesuaikan tipe data Address kamu

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
  bool _isLoading = false; // Status loading
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("Harap isi username dan password");
      return;
    }

    setState(() => _isLoading = true);

    // Proses tembak API ke PABW
    final userData = await AuthService().login(username, password);

    setState(() => _isLoading = false);

    if (userData != null) {
      // 1. Set Status Login
      widget.setIsLoggedIn(true);
      
      // 2. Ambil nama dari DB
      widget.setUserName(userData['name'] ?? userData['username']);
      
      // 3. Set Alamat dari DB
      // Sesuaikan constructor Address() dengan class yang kamu punya
      widget.setUserAddress(Address(
        name: userData['name'] ?? '',
        phone: userData['phone'] ?? '',
        address: userData['address'] ?? 'Alamat belum diatur',
        email: userData['email'] ?? '',
      ));

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
            top: -150, left: -150,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(color: customPinkLight, shape: BoxShape.circle),
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
                
                // Input Username
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Username', LucideIcons.user),
                ),
                const SizedBox(height: 16),
                
                // Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: _inputDecoration('Password', LucideIcons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Sign In
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPink,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => widget.navigate('Register'),
                    child: const Text('Create Account', style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _handleGuestLogin,
                    child: Text('Lanjut sebagai Guest', style: TextStyle(color: Colors.grey.shade500)),
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
        borderSide: BorderSide(color: customPink),
      ),
    );
  }
}