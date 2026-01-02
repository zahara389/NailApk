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
  bool _showApiSettings = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load persisted API URL override (if any) and prefill the input.
    loadApiBaseUrlOverride().then((_) {
      if (!mounted) return;
      setState(() {
        _apiUrlController.text = apiBaseUrlOverride ?? apiBaseUrl;
      });
    });
  }

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
      _showError("Login gagal. Cek koneksi & server API, lalu coba lagi.");
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
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveApiUrl() async {
    final raw = _apiUrlController.text.trim();
    await setApiBaseUrlOverride(raw);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL API disimpan: ${apiBaseUrlOverride ?? apiBaseUrl}'),
        backgroundColor: Colors.green,
      ),
    );
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

                // API URL Settings (inline, minimal)
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showApiSettings = !_showApiSettings),
                    child: Text(
                      _showApiSettings ? 'Tutup pengaturan URL API' : 'Ubah URL API',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
                if (_showApiSettings) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _apiUrlController,
                    decoration: _inputDecoration('URL API (contoh: http://10.0.2.2:8000)', LucideIcons.link),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveApiUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPink,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan URL API',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
