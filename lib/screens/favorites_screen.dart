import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<Product> newArrivals;
  final List<GalleryItem> galleryItems;

  const FavoritesScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.newArrivals,
    required this.galleryItems,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteProducts = newArrivals.where((p) => p.isFavorite).toList();
    final favoriteGallery = galleryItems.where((g) => g.isFavorite).toList();
    final totalFavorites = favoriteProducts.length + favoriteGallery.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: BackButtonIcon(onBack: goBack),
        title: Text('Favorit Saya ($totalFavorites)', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: totalFavorites == 0
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
                      Icon(LucideIcons.heart, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Anda belum memiliki item favorit.', style: TextStyle(color: Colors.grey.shade500)),
                      TextButton(
                        onPressed: () => navigate('Home'),
                        child: Text('Mulai Berbelanja', style: TextStyle(color: customPink, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (favoriteProducts.isNotEmpty)
                    _FavoriteSection(
                      title: 'Produk Favorit (${favoriteProducts.length})',
                      items: favoriteProducts,
                      type: 'product',
                      navigate: navigate,
                    ),
                  if (favoriteProducts.isNotEmpty && favoriteGallery.isNotEmpty)
                    const SizedBox(height: 24),
                  if (favoriteGallery.isNotEmpty)
                    _FavoriteSection(
                      title: 'Gaya Kuku Favorit (${favoriteGallery.length})',
                      items: favoriteGallery,
                      type: 'gallery',
                      navigate: navigate,
                    ),
                ],
              ),
            ),
    );
  }
}

class _FavoriteSection extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final String type; 
  final Function(String, {dynamic data}) navigate;

  const _FavoriteSection({
    required this.title,
    required this.items,
    required this.type,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Column(
          children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _FavoriteItemCard(item: item, type: type, navigate: navigate),
              )).toList(),
        ),
      ],
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final dynamic item;
  final String type;
  final Function(String, {dynamic data}) navigate;

  const _FavoriteItemCard({
    required this.item,
    required this.type,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    final title = type == 'product' ? item.name : item.title;
    final subtitle = type == 'product' ? formatRupiah(item.price) : item.designer;
    final imageUrl = type == 'product' ? item.imageUrl : item.imgUrl;
    final navKey = type == 'product' ? 'PDP' : 'GalleryDetail';

    return InkWell(
      onTap: () => navigate(navKey, data: item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.heart, color: customPink)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}