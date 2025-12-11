import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class RegisterScreen extends StatelessWidget {
  final Function(String, {dynamic data}) navigate;
  final VoidCallback goBack;

  const RegisterScreen({
    super.key,
    required this.navigate,
    required this.goBack,
  });

  void _handleRegister() {
    print('User Registered. Navigating to Login...');
    navigate('Login');
  }

  void _handleGuestLogin() {
    navigate('Home');
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
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: BackButtonIcon(onBack: goBack),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 30),
                    const Text(
                      'Create account',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lengkapi detail Anda.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Input Nama
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Nama',
                        contentPadding: const EdgeInsets.only(bottom: 12),
                        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: customPink)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Email
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        contentPadding: const EdgeInsets.only(bottom: 12),
                        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: customPink)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Password
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.only(bottom: 12),
                        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: customPink)),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Tombol Sign Up
                    ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPink,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                        shadowColor: customPink.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sign up', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.chevronRight, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tautan Sign In
                    Center(
                      child: InkWell(
                        onTap: () => navigate('Login'),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign in',
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
                    const SizedBox(height: 50),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}