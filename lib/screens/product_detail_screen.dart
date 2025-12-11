import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final Product? product;
  final Function(Product) handleAddToCart;
  final int cartCount;
  final Function(List<Product>) setNewArrivals;

  const ProductDetailScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.product,
    required this.handleAddToCart,
    required this.cartCount,
    required this.setNewArrivals,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite;
  final int _stockAvailable = 10;
  final double _discountRate = 0.20;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product?.isFavorite ?? false;
  }

  void _handleAddToCartClick() {
    if (widget.product != null) {
      widget.handleAddToCart(widget.product!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product!.name} (1 unit) ditambahkan ke keranjang!')),
      );
    }
  }

  void _handlePdpFavoriteToggle() {
    if (widget.product == null) return;
    final newState = !_isFavorite;
    setState(() {
      _isFavorite = newState;
    });

    widget.setNewArrivals((prevArrivals) {
      final updatedList = prevArrivals.map((p) {
        if (p.id == widget.product!.id) {
          return p.copyWith(isFavorite: newState);
        }
        return p;
      }).toList();
      return updatedList;
    });

    if (newState) {
      widget.navigate('Favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return const Scaffold(body: Center(child: Text('Produk tidak ditemukan.')));
    }

    final product = widget.product!;
    final priceOriginal = product.price;
    final priceDiscounted = (priceOriginal * (1 - _discountRate)).round();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: BackButtonIcon(onBack: widget.goBack),
                actions: [
                  InkWell(
                    onTap: () => widget.navigate('Cart'),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(LucideIcons.shoppingBag),
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
                  )
                ],
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                floating: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // Gambar Produk
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey.shade50,
                    child: Center(
                      child: Image.network(
                        product.imageUrl,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Text('Product Image')),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.brand.toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailBullet(text: 'Vegan & Cruelty-Free'),
                              _DetailBullet(text: 'Perlu Lampu UV/LED'),
                              _DetailBullet(text: 'Dibuat di USA'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Ruang bawah
                      ],
                    ),
                  ),
                ]),
              ),
            ],
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
                    onTap: _handlePdpFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: _isFavorite ? customPink : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.heart,
                        size: 24,
                        color: _isFavorite ? customPink : Colors.grey.shade600,
                        fill: _isFavorite ? customPink : null,
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