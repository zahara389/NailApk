import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final PaymentDetails? paymentDetails;
  final Function(PurchaseHistory) addPurchaseToHistory;

  const PaymentProcessingScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.paymentDetails,
    required this.addPurchaseToHistory,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  // State lokal untuk konfirmasi copy
  bool _copied = false;

  void _handleSuccessConfirmation() {
    if (widget.paymentDetails?.newOrder != null) {
      final finalOrder = widget.paymentDetails!.newOrder.copyWith(status: 'Processing');
      widget.addPurchaseToHistory(finalOrder);
    }
    widget.navigate('OrderSuccess');
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paymentDetails == null) {
      return const Scaffold(body: Center(child: Text('Detail pembayaran tidak tersedia.')));
    }

    final details = widget.paymentDetails!;
    final methodKey = details.methodKey;
    final totalAmount = details.totalAmount;

    List<Map<String, dynamic>> paymentData = [];
    Widget iconContent = const SizedBox.shrink();

    if (methodKey == 'QRIS') {
      paymentData = [
        {'label': 'Instruksi', 'value': 'Pindai kode QRIS di bawah.', 'isCopyable': false},
        {'label': 'Kode Referensi', 'value': 'QR-99008877', 'isCopyable': true},
      ];
      iconContent = Image.network(
        "https://placehold.co/150x150/ffffff/000000?text=QRIS+CODE",
        width: 150,
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(width: 150, height: 150, child: Center(child: Text('QRIS Code'))),
      );
    } else if (methodKey == 'Visa') {
      paymentData = [
        {'label': 'Bank Tujuan', 'value': 'BCA (Virtual Account)', 'isCopyable': false},
        {'label': 'Nomor VA', 'value': '8203 0812 3456 7890', 'isCopyable': true},
        {'label': 'Nama Akun', 'value': 'Nail Studio Payment', 'isCopyable': false},
      ];
      iconContent = Icon(LucideIcons.creditCard, size: 36, color: customPink);
    }

    final dueDate = DateTime.now().add(const Duration(hours: 24));
    final dueTime = TimeOfDay.fromDateTime(dueDate).format(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: BackButtonIcon(onBack: widget.goBack),
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
                  Icon(LucideIcons.clock, size: 36, color: customPink),
                  const SizedBox(height: 12),
                  const Text('Menunggu Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Selesaikan pembayaran sebelum:', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text(
                    '${dueDate.day}/${dueDate.month}/${dueDate.year} | $dueTime WIB',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text('No. Order: ${details.newOrder.id}', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail Pembayaran Dinamis
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
                        key: ValueKey(data['value']), 
                        label: data['label'] as String,
                        value: data['value'] as String,
                        isCopyable: data['isCopyable'] as bool,
                        onCopy: _copyToClipboard,
                        copied: _copied,
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
              onPressed: _handleSuccessConfirmation,
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
  final Function(String) onCopy;
  final bool copied;

  const _DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isCopyable = false,
    required this.onCopy,
    required this.copied,
  });

  @override
  Widget build(BuildContext context) {
    final showCopied = copied && isCopyable;

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
                  onTap: () => onCopy(value),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      showCopied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                        color: showCopied ? Colors.green : customPink,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}