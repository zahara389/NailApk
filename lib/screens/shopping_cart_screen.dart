import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io' show Platform; // ✅ Penting untuk cek Android
import '../config.dart';

class ShoppingCartScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<CartItem> cart;
  final Future<void> Function(int cartItemId, int newQuantity) updateCartQuantity;
  final Future<void> Function(int cartItemId) removeCartItem;

  const ShoppingCartScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.cart,
    required this.updateCartQuantity,
    required this.removeCartItem,
  });

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  CartItem? _itemToDelete;

  int _subtotal() => widget.cart.fold(0, (s, i) => s + i.product.price * i.quantity);
  int _shipping(int subtotal) => subtotal >= 500000 ? 0 : 30000;

  @override
  Widget build(BuildContext context) {
    final subtotal = _subtotal();
    final shipping = _shipping(subtotal);
    final total = subtotal + shipping;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: widget.goBack,
        ),
        title: const Text(
          'Keranjang Belanja', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      
      body: Stack(
        children: [
          // 1. KONTEN LIST
          Column(
            children: [
              Expanded(
                child: widget.cart.isEmpty
                    ? _EmptyCart(navigate: widget.navigate)
                    : ListView(
                        // Padding bawah 160 agar item terakhir tidak ketutup button
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
                        children: [
                          ...widget.cart.map((item) => _ModernCartItem(
                                item: item,
                                onIncrease: () async {
                                  await widget.updateCartQuantity(item.id, item.quantity + 1);
                                },
                                onDecrease: () async {
                                  if (item.quantity > 1) {
                                    await widget.updateCartQuantity(item.id, item.quantity - 1);
                                  }
                                },
                                onRemove: () => setState(() => _itemToDelete = item),
                              )),
                          
                          const SizedBox(height: 10),
                          _AestheticSummary(subtotal: subtotal, shipping: shipping, total: total),
                        ],
                      ),
              ),
            ],
          ),

          // 2. BUTTON CHECKOUT (Floating)
          if (widget.cart.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              // Jarak bottom 90 cukup aman agar tidak ketutup Navbar HP
              bottom: 90, 
              child: _FloatingCheckoutButton(
                total: total, 
                onCheckout: () => widget.navigate('Checkout')
              ),
            ),

          // 3. MODAL HAPUS (Overlay)
          if (_itemToDelete != null)
            _GlassDeleteModal(
              item: _itemToDelete!,
              onCancel: () => setState(() => _itemToDelete = null),
              onConfirm: () async {
                await widget.removeCartItem(_itemToDelete!.id);
                setState(() => _itemToDelete = null);
              },
            ),
        ],
      ),
    );
  }
}

/* ================= 1. KARTU PRODUK (DENGAN LOGIKA GAMBAR FINAL) ================= */

class _ModernCartItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _ModernCartItem({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  /// 🔥 LOGIKA ANTI ERROR 404 & DOUBLE PATH 🔥
  ImageProvider _getImageProvider(String url) {
    if (url.isEmpty) {
      return const AssetImage('assets/images/placeholder.png'); 
    }
    
    // 1. Cek aset lokal
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }

    String finalUrl = url;
    
    // 2. Jika belum ada HTTP (bukan URL lengkap)
    if (!url.startsWith('http')) {
      // Bersihkan slash di depan jika ada
      if (url.startsWith('/')) {
        url = url.substring(1);
      }

      // CEK APAKAH SUDAH ADA PATH 'images/products'
      if (url.contains('images/products')) {
         // Jika SUDAH ada di database -> Tempel ke Base URL utama
         // Hasil: http://IP:PORT/images/products/foto.jpg
         finalUrl = "$apiBaseUrl/$url";
      } else {
         // Jika BELUM ada (cuma nama file) -> Tempel ke Image Base URL
         // Hasil: http://IP:PORT/images/products/foto.jpg
         finalUrl = "$imageBaseUrl/$url";
      }
    }

    // 3. FIX ANDROID EMULATOR (127.0.0.1 -> 10.0.2.2)
    try {
      if (Platform.isAndroid && finalUrl.contains('127.0.0.1')) {
        finalUrl = finalUrl.replaceAll('127.0.0.1', '10.0.2.2');
      }
    } catch (e) {
      // Abaikan error
    }

    return NetworkImage(finalUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF909090).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar dengan Error Handling
          Hero(
            tag: 'product-${item.product.id}',
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey.shade100,
                image: DecorationImage(
                  image: _getImageProvider(item.product.imageUrl), // ✅ Pakai fungsi benar
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint("Gagal load gambar: $exception");
                  },
                ),
              ),
              child: item.product.imageUrl.isEmpty 
                  ? const Center(child: Icon(LucideIcons.image, color: Colors.grey))
                  : null,
            ),
          ),
          
          const SizedBox(width: 16),

          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Tombol Hapus
                    InkWell(
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Icon(LucideIcons.trash2, size: 20, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
                
                Text(
                  item.product.brand.isNotEmpty ? item.product.brand : 'No Brand',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatRupiah(item.product.price),
                      style: const TextStyle(
                        color: customPink,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    
                    // Quantity Control
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          _MiniBtn(icon: LucideIcons.minus, onTap: onDecrease, isActive: item.quantity > 1),
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          _MiniBtn(icon: LucideIcons.plus, onTap: onIncrease, isActive: true),
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

class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  
  const _MiniBtn({required this.icon, required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(
          icon, 
          size: 14, 
          color: isActive ? Colors.black87 : Colors.grey.shade300
        ),
      ),
    );
  }
}

/* ================= 2. MODAL HAPUS ================= */

class _GlassDeleteModal extends StatelessWidget {
  final CartItem item;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _GlassDeleteModal({
    required this.item,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30)
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.trash2, color: customPink, size: 32),
                    ),
                    const SizedBox(height: 24),
                    const Text('Hapus Item?', 
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.black87)
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kamu yakin ingin menghapus\n"${item.product.name}"?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: onCancel,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customPink,
                              elevation: 0,
                              shadowColor: customPink.withOpacity(0.4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ================= 3. FLOATING CHECKOUT BUTTON ================= */

class _FloatingCheckoutButton extends StatelessWidget {
  final int total;
  final VoidCallback onCheckout;

  const _FloatingCheckoutButton({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: onCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: customPink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Checkout', 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 16
              )
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text(
                formatRupiah(total), 
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w800, 
                  fontSize: 16
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= 4. SUMMARY SECTION ================= */

class _AestheticSummary extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int total;

  const _AestheticSummary({required this.subtotal, required this.shipping, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: [
        _row('Subtotal', formatRupiah(subtotal)),
        const SizedBox(height: 12),
        _row('Biaya Pengiriman', shipping == 0 ? 'Gratis' : formatRupiah(shipping)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
        ),
        _row('Total Pembayaran', formatRupiah(total), isTotal: true),
      ]),
    );
  }

  Widget _row(String l, String v, {bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l,
          style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black87 : Colors.grey.shade500,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
      Text(v,
          style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? customPink : Colors.black87,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600)),
    ]);
  }
}

/* ================= 5. EMPTY STATE ================= */

class _EmptyCart extends StatelessWidget {
  final Function(String, {dynamic data}) navigate;
  const _EmptyCart({required this.navigate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: customPink.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5
              )
            ]
          ),
          child: const Icon(LucideIcons.shoppingBag, size: 50, color: customPink),
        ),
        const SizedBox(height: 30),
        const Text('Keranjang Kosong',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),
        Text('Sepertinya kamu belum\nmenambahkan apapun.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, height: 1.5)),
        const SizedBox(height: 40),
        OutlinedButton(
          onPressed: () => navigate('Home'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: customPink, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)
          ),
          child: const Text('Mulai Belanja',
              style: TextStyle(color: customPink, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ]),
    );
  }
}