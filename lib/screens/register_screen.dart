import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final VoidCallback goBack;

  const RegisterScreen({
    super.key,
    required this.navigate,
    required this.goBack,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Semua field harus diisi!");
      return;
    }

    setState(() => _isLoading = true);

    // FIX: Menambahkan field yang diminta oleh Laravel API kamu
    Map<String, String> registerData = {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': password, // Mengisi konfirmasi password otomatis
      'role': 'member',                 // Mengirim role default 'member'
    };

    final bool success = await AuthService().register(registerData);

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Registrasi Berhasil! Silakan Login.");
      widget.navigate('Login');
    } else {
      _showSnackBar("Registrasi Gagal. Periksa kembali data Anda.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
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
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 24),
                  onPressed: widget.goBack,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    const Text('Create account',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Lengkapi detail Anda.', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 30),
                    _buildTextField(_nameController, 'Nama Lengkap', LucideIcons.user),
                    const SizedBox(height: 20),
                    _buildTextField(_usernameController, 'Username', LucideIcons.atSign),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email', LucideIcons.mail, isEmail: true),
                    const SizedBox(height: 20),
                    _buildTextField(_passwordController, 'Password', LucideIcons.lock, isPassword: true),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPink,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign up', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () => widget.navigate('Login'),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.grey.shade600),
                            children: [
                              TextSpan(text: 'Sign in', style: TextStyle(color: customPink, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isEmail = false, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: customPink)),
      ),
    );
  }
}