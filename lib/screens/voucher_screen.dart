import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class VoucherScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<Voucher> vouchers;

  const VoucherScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.vouchers,
  });

  @override
  Widget build(BuildContext context) {
    final available = vouchers.where((v) => v.status == 'available').toList();
    final used = vouchers.where((v) => v.status == 'used').toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // FIX BACK BUTTON (tadinya BackButtonIcon yang error)
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: goBack,
        ),

        title: Text(
          'Voucher Saya (${available.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: (available.isEmpty && used.isEmpty)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.gift, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Anda belum memiliki voucher saat ini.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    TextButton(
                      onPressed: () => print('Lihat Promo Terbaru'),
                      child: Text(
                        'Lihat Promo Terbaru',
                        style: TextStyle(
                          color: customPink,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (available.isNotEmpty) ...[
                    Text(
                      'Tersedia (${available.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...available.map((v) => _VoucherCard(voucher: v)),
                    const SizedBox(height: 24),
                  ],
                  
                  if (used.isNotEmpty) ...[
                    Text(
                      'Sudah Digunakan (${used.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...used.map((v) => Opacity(
                      opacity: 0.7,
                      child: _VoucherCard(voucher: v),
                    )),
                  ],
                ],
              ),
            ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;

  const _VoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final isUsed = voucher.status == 'used';
    final bgColor = isUsed ? Colors.grey.shade200 : customPink;
    final buttonText = isUsed ? 'Used' : 'Use Now';
    final buttonColor = isUsed ? Colors.grey.shade400 : Colors.white;
    final textColor = isUsed ? Colors.grey.shade600 : customPink;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ],
        border: Border.all(color: customPinkLight),
      ),
      child: Row(
        children: [
          // LEFT
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: 100,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.gift, size: 32, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  'VOUCHER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // RIGHT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Kode: ${voucher.code}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exp: ${voucher.expiry}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isUsed ? null : () => print('Voucher ${voucher.code} digunakan.'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          side: BorderSide(
                            color: isUsed ? Colors.transparent : customPink,
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
