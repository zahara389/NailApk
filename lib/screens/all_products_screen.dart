import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<Product> newArrivals;
  final Function(Product) handleAddToCart;
  final Function(List<Product>) setNewArrivals;

  const AllProductsScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.newArrivals,
    required this.handleAddToCart,
    required this.setNewArrivals,
  });

  void _handleFavoriteToggle(int productId) {
    bool wasFavorite = false;
    final updatedList = newArrivals.map((p) {
      if (p.id == productId) {
        wasFavorite = p.isFavorite;
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
    setNewArrivals(updatedList);
    if (!wasFavorite) {
      navigate('Favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: goBack,
        ),
        title: Text(
          'Semua Produk (${newArrivals.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.6, // Sesuaikan ini dengan tinggi ProductCard
        ),
        itemCount: newArrivals.length + 1, // +1 untuk footer
        itemBuilder: (context, index) {
          // Footer item
          if (index == newArrivals.length) {
            return const SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  'Akhir dari daftar produk.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            );
          }
          
          final product = newArrivals[index];
          return ProductCard(
            product: product,
            navigateToPdp: (p) => navigate('PDP', data: p),
            handleFavoriteToggle: _handleFavoriteToggle,
            handleAddToCart: handleAddToCart,
            isGrid: true,
          );
        },
      ),
    );
  }
}