import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class PaymentProcessingScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final PaymentDetails? paymentDetails;
  final List<CartItem> cart; // Dipertahankan, meskipun tidak digunakan di sini

  const PaymentProcessingScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.paymentDetails,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    if (paymentDetails == null) {
      return const Scaffold(body: Center(child: Text('Detail pembayaran tidak tersedia.')));
    }

    final methodKey = paymentDetails!.methodKey;
    final totalAmount = paymentDetails!.totalAmount;

    List<Map<String, dynamic>> paymentData = [];
    Widget iconContent = const SizedBox.shrink();

    if (methodKey == 'QRIS') {
      paymentData = [
        {'label': 'Instruksi', 'value': 'Pindai kode QRIS di bawah.', 'type': 'text'},
        {'label': 'Kode Referensi', 'value': 'QR-99008877', 'type': 'copy'},
      ];
      iconContent = Image.network(
        "https://placehold.co/150x150/ffffff/000000?text=QRIS+CODE",
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      );
    } else if (methodKey == 'Visa') {
      paymentData = [
        {'label': 'Bank Tujuan', 'value': 'BCA (Virtual Account)', 'type': 'text'},
        {'label': 'Nomor VA', 'value': '8203 0812 3456 7890', 'type': 'copy'},
        {'label': 'Nama Akun', 'value': 'Nail Studio Payment', 'type': 'text'},
      ];
      iconContent = Icon(Icons.credit_card, size: 36, color: customPink);
    }

    final dueDate = DateTime.now().add(const Duration(hours: 24));
    final dueTime = TimeOfDay.fromDateTime(dueDate).format(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
        title: const Text('Tagihan Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                border: Border(top: BorderSide(color: customPink, width: 4)),
              ),
              child: Column(
                children: [
                  Icon(Icons.access_time, size: 36, color: customPink),
                  const SizedBox(height: 12),
                  const Text('Menunggu Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Selesaikan pembayaran sebelum:', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text(
                    '${dueDate.day}/${dueDate.month}/${dueDate.year} | $dueTime WIB',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail Pembayaran
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
                  Text('Pembayaran ($methodKey)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  Center(child: iconContent),
                  const SizedBox(height: 16),
                  ...paymentData.map((data) => _DetailRow(
                        label: data['label'] as String,
                        value: data['value'] as String,
                        isCopyable: data['type'] == 'copy',
                      )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      Text(formatRupiah(totalAmount), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: customPink)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simulasi Konfirmasi
            ElevatedButton(
              onPressed: () => navigate('OrderSuccess'),
              style: ElevatedButton.styleFrom(
                backgroundColor: customPink,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simulasi: Konfirmasi Pembayaran Berhasil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopyable;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (isCopyable)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label dicopy!')));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Copy', style: TextStyle(color: customPink, fontSize: 12, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}