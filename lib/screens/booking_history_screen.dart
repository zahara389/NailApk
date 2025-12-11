import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class BookingHistoryScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<Booking> history;

  const BookingHistoryScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.history,
  });

  Color _getStatusColor(String status) {
    if (status == 'Completed') return Colors.green.shade600;
    if (status == 'Confirmed') return customPink;
    return Colors.orange.shade600;
  }
  
  Color _getStatusBgColor(String status) {
    if (status == 'Completed') return Colors.green.shade100;
    if (status == 'Confirmed') return customPinkLight;
    return Colors.orange.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: goBack,
        ),
        title: const Text('Riwayat Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.clock, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Anda belum memiliki riwayat booking.', style: TextStyle(color: Colors.grey.shade500)),
                      TextButton(
                        onPressed: () => navigate('Booking'),
                        child: Text('Buat Booking Baru', style: TextStyle(color: customPink, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: history.map((booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                          border: Border(left: BorderSide(color: customPink, width: 4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(booking.service, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    Text('#${booking.id}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusBgColor(booking.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(booking.status)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(color: Colors.grey.shade100, height: 1),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(LucideIcons.calendar, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text('${booking.date} | ${booking.time}', style: TextStyle(color: Colors.grey.shade800)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(booking.location, style: TextStyle(color: Colors.grey.shade800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
              ),
            ),
    );
  }
}