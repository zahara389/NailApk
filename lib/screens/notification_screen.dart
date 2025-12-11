import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<NotificationItem> notifications;
  final Function(int) markAsRead;

  const NotificationScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.notifications,
    required this.markAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => !n.read).toList();
    final read = notifications.where((n) => n.read).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: BackButtonIcon(onBack: goBack),
        title: Text('Notifikasi (${unread.length} Baru)', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.bell, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Kotak masuk notifikasi Anda kosong.', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unread.isNotEmpty) ...[
                    const Text('Belum Dibaca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...unread.map((n) => _NotificationItem(notification: n, markAsRead: markAsRead)),
                    const SizedBox(height: 24),
                  ],
                  if (read.isNotEmpty) ...[
                    const Text('Sudah Dibaca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...read.map((n) => _NotificationItem(notification: n, markAsRead: markAsRead)),
                  ],
                ],
              ),
            ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationItem notification;
  final Function(int) markAsRead;

  const _NotificationItem({required this.notification, required this.markAsRead});

  IconData _getIconData(String type) {
    if (type == 'Promo') return LucideIcons.gift;
    if (type == 'Transaksi') return LucideIcons.shoppingCart;
    return LucideIcons.bell;
  }

  Color _getIconColor(String type) {
    if (type == 'Promo') return Colors.green.shade600;
    if (type == 'Transaksi') return Colors.blue.shade600;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(notification.type);
    final iconColor = _getIconColor(notification.type);

    return InkWell(
      onTap: () {
        if (!notification.read) {
          markAsRead(notification.id);
        }
        print('Notifikasi ${notification.id} diklik.');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : customPinkLight.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: notification.read ? Border.all(color: Colors.grey.shade100) : Border(right: BorderSide(color: customPink, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: notification.read ? Colors.grey.shade200 : customPink),
              ),
              child: Icon(iconData, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.type,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: notification.read ? Colors.grey.shade500 : customPink),
                      ),
                      if (!notification.read)
                        const Text('BARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(notification.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}