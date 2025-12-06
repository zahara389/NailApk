import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class ShoppingCartScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<CartItem> cart;
  final Function(int, int) updateCartQuantity;

  const ShoppingCartScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.cart,
    required this.updateCartQuantity,
  });

  void _handleRemoveItem(int productId) {
    updateCartQuantity(productId, -100); // Hapus semua
  }

  int _calculateSubtotal() {
    return cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  int _calculateShipping(int subtotal) {
    return subtotal > 500000 ? 0 : 30000;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShipping(subtotal);
    final total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        leading: BackButtonIcon(onBack: goBack),
        title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shoppingBag, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Keranjang belanja Anda kosong.', style: TextStyle(color: Colors.grey.shade500)),
                  TextButton(
                    onPressed: () => navigate('Home'),
                    child: Text('Lanjut Berbelanja', style: TextStyle(color: customPink, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120), // Ruang untuk tombol checkout
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Daftar Item
                        ...cart.map((item) => _CartItem(
                              item: item,
                              updateCartQuantity: updateCartQuantity,
                              handleRemoveItem: _handleRemoveItem,
                            )),
                        const SizedBox(height: 24),

                        // Summary dan Kupon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan kupon',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => print('Apply Kupon'),
                                    style: ElevatedButton.styleFrom(backgroundColor: customPink, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                                    child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 14)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _SummaryRow(label: 'Subtotal', value: formatRupiah(subtotal)),
                              Divider(color: Colors.grey.shade200),
                              _SummaryRow(label: 'Shipping', value: shipping == 0 ? 'Gratis' : formatRupiah(shipping)),
                              const SizedBox(height: 8),
                              _SummaryRow(label: 'Total', value: formatRupiah(total), isTotal: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tombol Checkout
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: ElevatedButton(
                      onPressed: () => navigate('Checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPink,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Proceed to Checkout (${formatRupiah(total)})', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem item;
  final Function(int, int) updateCartQuantity;
  final Function(int) handleRemoveItem;

  const _CartItem({
    required this.item,
    required this.updateCartQuantity,
    required this.handleRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              item.product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Center(child: Text(item.product.name.substring(0, 4))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(item.product.brand, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => handleRemoveItem(item.product.id),
                      child: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatRupiah(item.product.price), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: customPink)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => updateCartQuantity(item.product.id, -1),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(LucideIcons.minus, size: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          InkWell(
                            onTap: () => updateCartQuantity(item.product.id, 1),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(LucideIcons.plus, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal ? customPink : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}