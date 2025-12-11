import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;

  const SettingsScreen({
    super.key,
    required this.goBack,
    required this.navigate,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _theme = 'light';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _locationAccess = false;

  void _handleToggle(String key, bool value) {
    setState(() {
      if (key == 'emailNotifications') _emailNotifications = value;
      if (key == 'pushNotifications') _pushNotifications = value;
      if (key == 'locationAccess') _locationAccess = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: widget.goBack,
        ),
        title: const Text(
          'Pengaturan Umum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOTIFIKASI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.grey, height: 16),
                  _SettingToggle(
                    title: "Notifikasi Email",
                    description: "Dapatkan pembaruan pesanan dan promo via email.",
                    stateKey: "emailNotifications",
                    checked: _emailNotifications,
                    onToggle: _handleToggle,
                  ),
                  _SettingToggle(
                    title: "Notifikasi Push",
                    description: "Pesan langsung saat order Anda diproses.",
                    stateKey: "pushNotifications",
                    checked: _pushNotifications,
                    onToggle: _handleToggle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DATA & THEME
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akses Data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.grey, height: 16),

                  _SettingToggle(
                    title: "Akses Lokasi",
                    description: "Izinkan akses untuk menemukan studio terdekat.",
                    stateKey: "locationAccess",
                    checked: _locationAccess,
                    onToggle: _handleToggle,
                  ),

                  const Divider(color: Colors.grey, height: 20),

                  const Text(
                    'Pilih Tema',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    value: _theme,
                    onChanged: (val) {
                      if (val != null) setState(() => _theme = val);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'light',
                        child: Text('Light Mode (Default)'),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text('Dark Mode (Simulasi)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String title;
  final String? description;
  final String stateKey;
  final bool checked;
  final Function(String, bool) onToggle;

  const _SettingToggle({
    required this.title,
    this.description,
    required this.stateKey,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Switch(
            value: checked,
            onChanged: (val) => onToggle(stateKey, val),
            activeColor: customPink,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
