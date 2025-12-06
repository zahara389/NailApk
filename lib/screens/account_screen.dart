import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final bool isLoggedIn;
  final Function(bool) setIsLoggedIn;
  final String userName;
  final String currentView;

  const AccountScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.isLoggedIn,
    required this.setIsLoggedIn,
    required this.userName,
    required this.currentView,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isEditMode = false;
  late Address _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = Address(
      name: widget.userName,
      phone: '0812-3456-7890',
      address: 'Jl. Bojongsoang No. 10, Bandung',
    );
  }

  void _handleLogout() {
    widget.setIsLoggedIn(false);
    widget.navigate('Login');
  }

  void _handleSaveProfile() {
    // Logika simpan profil
    print('Profile saved: ${_profileData.name}');
    setState(() {
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('Anda Belum Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Silakan login atau daftar untuk mengakses akun.', style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => widget.navigate('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPink,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Login / Daftar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        title: const Text('Akun Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.person, size: 48, color: customPink),
                    const SizedBox(height: 8),
                    Text(_profileData.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('sarah.nail@mail.com', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Edit Profile / Profile Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () => setState(() => _isEditMode = !_isEditMode),
                        child: Text(_isEditMode ? 'Cancel' : 'Edit Profil', style: TextStyle(color: customPink, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isEditMode ? _ProfileEditor(
                    profileData: _profileData,
                    onUpdate: (newData) => setState(() => _profileData = newData),
                  ) : _ProfileDetails(profileData: _profileData),
                  if (_isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: _handleSaveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customPink,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Riwayat Pembelian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Riwayat Pembelian & Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...dummyPurchaseHistory.map((order) => _PurchaseItem(order: order)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => print('Lihat Semua Riwayat'),
                    child: Text('Lihat Semua Riwayat', style: TextStyle(color: customPink, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Logout
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 20, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final Address profileData;

  const _ProfileDetails({required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Telepon:', value: profileData.phone),
        _DetailRow(label: 'Email:', value: 'sarah.nail@mail.com'), // Email statis
        _DetailRow(label: 'Alamat:', value: profileData.address),
        _DetailRow(label: 'Status Akun:', value: 'Aktif'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _ProfileEditor extends StatefulWidget {
  final Address profileData;
  final Function(Address) onUpdate;

  const _ProfileEditor({required this.profileData, required this.onUpdate});

  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData.name);
    _phoneController = TextEditingController(text: widget.profileData.phone);
    _addressController = TextEditingController(text: widget.profileData.address);

    _nameController.addListener(_updateData);
    _phoneController.addListener(_updateData);
    _addressController.addListener(_updateData);
  }

  void _updateData() {
    final newAddress = widget.profileData.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    widget.onUpdate(newAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileInput(controller: _nameController, hintText: 'Nama'),
        _ProfileInput(controller: TextEditingController(text: 'sarah.nail@mail.com'), hintText: 'Email (Disabled)', isEnabled: false),
        _ProfileInput(controller: _phoneController, hintText: 'Telepon', keyboardType: TextInputType.phone),
        _ProfileInput(controller: _addressController, hintText: 'Alamat', maxLines: 2),
      ],
    );
  }
}

class _ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool isEnabled;

  const _ProfileInput({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: isEnabled,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: customPink)),
          fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
          filled: true,
        ),
      ),
    );
  }
}

class _PurchaseItem extends StatelessWidget {
  final PurchaseHistory order;

  const _PurchaseItem({required this.order});

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    switch (order.status) {
      case 'Delivered':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green.shade600;
        break;
      case 'Shipped':
        statusIcon = Icons.local_shipping;
        statusColor = Colors.blue.shade600;
        break;
      case 'Processing':
        statusIcon = Icons.access_time;
        statusColor = Colors.orange.shade600;
        break;
      default:
        statusIcon = Icons.close;
        statusColor = Colors.grey.shade500;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${order.id} (${order.items} items)', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(order.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(order.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              Text(formatRupiah(order.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}