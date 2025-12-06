import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final Product product;
  final Function(Product) handleAddToCart;
  final int cartCount;

  const ProductDetailScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.product,
    required this.handleAddToCart,
    required this.cartCount,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite;
  final int _stockAvailable = 10;
  final double _discountRate = 0.20; // 20% OFF

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  void _handleAddToCartClick() {
    widget.handleAddToCart(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product.name} (1 unit) ditambahkan ke keranjang!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceOriginal = widget.product.price;
    final priceDiscounted = (priceOriginal * (1 - _discountRate)).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        actions: [
          InkWell(
            onTap: () => widget.navigate('Cart'),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (widget.cartCount > 0)
                    Positioned(
                      top: 4,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: customPink,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '${widget.cartCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Padding untuk Bottom Bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey.shade50,
                  child: Center(
                    child: Image.network(
                      widget.product.imageUrl,
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.brand.toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text(widget.product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Harga
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(formatRupiah(priceDiscounted), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 8),
                          Text(formatRupiah(priceOriginal), style: TextStyle(fontSize: 18, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough)),
                          const SizedBox(width: 8),
                          const Text('20% OFF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stok Tersedia
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200), bottom: BorderSide(color: Colors.grey.shade200))),
                        child: Row(
                          children: [
                            Text('Stok Tersedia:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                            const SizedBox(width: 8),
                            Text('$_stockAvailable unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Text(
                        'Gel Polish ini memberikan warna putih yang sempurna untuk French Manicure atau sebagai lapisan dasar untuk nail art. Formula yang cepat kering dan tahan lama hingga 3 minggu.',
                        style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Detail Produk
                      const Text('Detail Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _DetailBullet(text: 'Vegan & Cruelty-Free'),
                            _DetailBullet(text: 'Perlu Lampu UV/LED'),
                            _DetailBullet(text: 'Dibuat di USA'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Bar: Favorite and Add to Cart
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
              child: Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: _isFavorite ? customPink : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: _isFavorite ? customPink : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _stockAvailable == 0 ? null : _handleAddToCartClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_stockAvailable == 0 ? 'Out of Stock' : 'Add to Cart', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBullet extends StatelessWidget {
  final String text;
  const _DetailBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade600))),
        ],
      ),
    );
  }
}