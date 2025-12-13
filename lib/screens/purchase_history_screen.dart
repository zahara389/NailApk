import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<PurchaseHistory> purchaseHistory;

  const PurchaseHistoryScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.purchaseHistory,
  });

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Delivered', 'Shipped', 'Processing', 'Awaiting Payment', 'Cancelled'];

  List<PurchaseHistory> get _filteredHistory {
    if (_selectedFilter == 'Semua') {
      return widget.purchaseHistory;
    }
    return widget.purchaseHistory.where((order) => order.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: widget.goBack,
        ),
        title: const Text('Riwayat Pembelian & Status', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: customPink.withOpacity(0.2),
                    checkmarkColor: customPink,
                    labelStyle: TextStyle(
                      color: isSelected ? customPink : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? customPink : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),

          // Purchase List
          Expanded(
            child: _filteredHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shoppingBag, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada riwayat pembelian',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final order = _filteredHistory[index];
                      return _PurchaseCard(
                        order: order,
                        onTap: () => widget.navigate('PurchaseDetail', data: order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final PurchaseHistory order;
  final VoidCallback onTap;

  const _PurchaseCard({
    required this.order,
    required this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusInfo['bgColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusInfo['icon'], size: 14, color: statusInfo['color']),
                        const SizedBox(width: 4),
                        Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusInfo['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date & Items
              Row(
                children: [
                  Icon(LucideIcons.calendar, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    order.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(LucideIcons.shoppingBag, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              
              const Divider(height: 24),

              // Total & Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
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
                  OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text('Detail'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: customPink,
                      side: BorderSide(color: customPink),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}