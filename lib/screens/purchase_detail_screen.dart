import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final VoidCallback goBack;
  final PurchaseHistory order;

  const PurchaseDetailScreen({
    super.key,
    required this.goBack,
    required this.order,
  });

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'Delivered':
        return {
          'icon': LucideIcons.checkCircle,
          'color': Colors.green.shade600,
          'bgColor': Colors.green.shade50,
        };
      case 'Shipped':
        return {
          'icon': LucideIcons.truck,
          'color': Colors.blue.shade600,
          'bgColor': Colors.blue.shade50,
        };
      case 'Processing':
        return {
          'icon': LucideIcons.clock,
          'color': Colors.orange.shade600,
          'bgColor': Colors.orange.shade50,
        };
      case 'Awaiting Payment':
        return {
          'icon': LucideIcons.alertCircle,
          'color': Colors.amber.shade700,
          'bgColor': Colors.amber.shade50,
        };
      case 'Cancelled':
        return {
          'icon': LucideIcons.xCircle,
          'color': Colors.red.shade600,
          'bgColor': Colors.red.shade50,
        };
      default:
        return {
          'icon': LucideIcons.package,
          'color': Colors.grey.shade600,
          'bgColor': Colors.grey.shade50,
        };
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'Delivered':
        return 'Pesanan telah diterima. Terima kasih!';
      case 'Shipped':
        return 'Pesanan dalam perjalanan ke alamat Anda';
      case 'Processing':
        return 'Pesanan sedang diproses';
      case 'Awaiting Payment':
        return 'Menunggu pembayaran Anda';
      case 'Cancelled':
        return 'Pesanan telah dibatalkan';
      default:
        return 'Status pesanan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(order.status);

    final orderItems = [
      {
        'name': 'OPI Top Coat High Shine Formula',
        'quantity': 1,
        'price': 85000,
        'image': 'assets/images/product2.jpeg',
      },
      {
        'name': 'Gel Polish Basic White (15ml)',
        'quantity': 1,
        'price': 45000,
        'image': 'assets/images/product1.jpeg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: goBack,
        ),
        title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const _OrderOptionsSheet(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusInfo['bgColor'],
                border: Border(
                  bottom: BorderSide(color: (statusInfo['color'] as Color).withOpacity(0.3)),
                ),
              ),
              child: Column(
                children: [
                  Icon(statusInfo['icon'] as IconData, size: 48, color: statusInfo['color'] as Color),
                  const SizedBox(height: 12),
                  Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusInfo['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusMessage(order.status),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            if (order.status != 'Cancelled' && order.status != 'Awaiting Payment')
              _OrderTimeline(status: order.status),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pesanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Order ID', value: order.id),
                  _InfoRow(label: 'Tanggal Pemesanan', value: order.date),
                  _InfoRow(label: 'Metode Pembayaran', value: 'Transfer Bank BCA'),
                  _InfoRow(label: 'Status Pembayaran', value: 'Lunas'),
                  const SizedBox(height: 24),

                  const Text(
                    'Alamat Pengiriman',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rina Kusuma', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('0812-3456-7890', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text(
                          'Jl. Raya Bandung No. 123, Kec. Coblong, Bandung, Jawa Barat 40132',
                          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Produk Dipesan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...orderItems.map((item) => _OrderItemCard(item: item)),
                  const SizedBox(height: 24),

                  const Text(
                    'Rincian Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _PaymentRow(label: 'Subtotal Produk', value: formatRupiah(130000)),
                        _PaymentRow(label: 'Ongkos Kirim', value: formatRupiah(15000)),
                        _PaymentRow(label: 'Diskon Voucher', value: '-${formatRupiah(10000)}', isDiscount: true),
                        _PaymentRow(label: 'Biaya Layanan', value: formatRupiah(2000)),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatRupiah(order.total),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: customPink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: _buildActionButton(context, order),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, PurchaseHistory order) {
    if (order.status == 'Awaiting Payment') {
      return ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lanjut ke pembayaran')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: customPink,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Bayar Sekarang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (order.status == 'Shipped') {
      return ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lacak pesanan')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: customPink,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Lacak Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (order.status == 'Delivered') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Beli lagi')),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: customPink),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Beli Lagi',
                style: TextStyle(color: customPink, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Beri ulasan')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customPink,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Beri Ulasan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    if (order.status == 'Processing') {
      return OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Batalkan Pesanan?'),
              content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pesanan dibatalkan')),
                    );
                  },
                  child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Batalkan Pesanan',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: Icon(LucideIcons.image, color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['quantity']}x ${formatRupiah(item['price'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(item['price'] * item['quantity']),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: customPink,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green.shade600 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final String status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Pesanan Dibuat', 'date': '2025-11-20 10:30', 'completed': true},
      {'label': 'Pembayaran Dikonfirmasi', 'date': '2025-11-20 11:00', 'completed': true},
      {'label': 'Sedang Diproses', 'date': '2025-11-20 14:00', 'completed': status != 'Awaiting Payment'},
      {'label': 'Sedang Dikirim', 'date': status == 'Shipped' || status == 'Delivered' ? '2025-11-21 09:00' : '-', 'completed': status == 'Shipped' || status == 'Delivered'},
      {'label': 'Pesanan Diterima', 'date': status == 'Delivered' ? '2025-11-25 16:00' : '-', 'completed': status == 'Delivered'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Pesanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            return _TimelineStep(
              label: step['label'] as String,
              date: step['date'] as String,
              completed: step['completed'] as bool,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final String date;
  final bool completed;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.date,
    required this.completed,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? customPink : Colors.grey.shade300,
                border: Border.all(
                  color: completed ? customPink : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: completed ? customPink : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                    color: completed ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                if (date != '-')
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderOptionsSheet extends StatelessWidget {
  const _OrderOptionsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.share2),
            title: const Text('Bagikan Pesanan'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bagikan pesanan')),
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.download),
            title: const Text('Download Invoice'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download invoice')),
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.messageCircle),
            title: const Text('Hubungi Customer Service'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hubungi CS')),
              );
            },
          ),
        ],
      ),
    );
  }
}