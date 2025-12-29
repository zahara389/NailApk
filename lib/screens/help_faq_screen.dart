import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class HelpFAQScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;

  const HelpFAQScreen({
    super.key,
    required this.goBack,
    required this.navigate,
  });

  @override
  State<HelpFAQScreen> createState() => _HelpFAQScreenState();
}

class _HelpFAQScreenState extends State<HelpFAQScreen> {
  int? _openIndex;

  final List<Map<String, String>> faqItems = const [
    {
      'q': "Bagaimana cara melacak pesanan saya?",
      'a': "Anda dapat melacak pesanan Anda melalui menu Akun > Riwayat Pembelian & Status. Klik pada nomor order untuk melihat detail pengiriman."
    },
    {
      'q': "Apa itu Gel Polish?",
      'a': "Gel Polish adalah jenis kuteks yang menggunakan formula gel dan harus dikeringkan menggunakan lampu UV atau LED agar mengeras dan tahan lama (hingga 3 minggu)."
    },
    {
      'q': "Bisakah saya membatalkan booking?",
      'a': "Pembatalan booking dapat dilakukan maksimal 24 jam sebelum waktu janji temu melalui telepon ke studio terkait."
    },
    {
      'q': "Apakah produk Anda Cruelty-Free?",
      'a': "Ya, sebagian besar merek yang kami jual sudah terverifikasi Vegan & Cruelty-Free."
    },
  ];

  void _toggleFAQ(int index) {
    setState(() {
      _openIndex = _openIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        title: const Text('Bantuan & FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Bantuan
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan atau topik bantuan...',
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: customPink)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // FAQ List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...faqItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _FAQItem(
                      item: item,
                      index: index,
                      isOpen: _openIndex == index,
                      onTap: _toggleFAQ,
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kontak Bantuan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Perlu Bantuan Lebih Lanjut?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tim support kami siap membantu Anda.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => print('Hubungi Live Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hubungi Live Chat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

class _FAQItem extends StatelessWidget {
  final Map<String, String> item;
  final int index;
  final bool isOpen;
  final Function(int) onTap;

  const _FAQItem({
    required this.item,
    required this.index,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item['q']!, style: const TextStyle(fontWeight: FontWeight.w600))),
                Transform.rotate(
                  angle: isOpen ? 90 * 3.1415926535 / 180 : 0, // rotate 90 degrees when open
                  child: Icon(LucideIcons.chevronRight, size: 20, color: customPink),
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              item['a']!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
}
