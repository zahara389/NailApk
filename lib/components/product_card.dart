import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product)? navigateToPdp;
  final Function(int)? handleFavoriteToggle;
  final Function(Product)? handleAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.navigateToPdp,
    this.handleFavoriteToggle,
    this.handleAddToCart,
  });

  Widget _buildProductImage(String imageUrl) {
    // 1. Cek jika URL kosong
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    // 2. Cek jika ini asset lokal (bukan dari API)
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    // 3. LOGIC FIX: Cek apakah imageUrl sudah berupa link lengkap (http/https)?
    // Ini mencegah error: http://baseurl/images/http://url_asli_dari_db
    String fullUrl;
    if (imageUrl.startsWith('http')) {
      // Jika sudah ada http, gunakan langsung apa adanya
      fullUrl = imageUrl;
    } else {
      // Jika belum (misal cuma "products/gambar.jpg"), baru tambahkan base URL via resolveApiImage
      fullUrl = resolveApiImage(imageUrl);
    }

    // Debugging: Cek console untuk memastikan URL sudah bersih
    debugPrint("FINAL URL LOAD: $fullUrl");

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      // Loading Indicator agar user tidak bingung saat gambar sedang ditarik
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade50,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      // Error Handler: Jika masih gagal, tampilkan icon broken
      errorBuilder: (context, error, stackTrace) {
        debugPrint("ERROR LOAD ($fullUrl): $error");
        return Container(
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                "Gagal Muat",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => navigateToPdp?.call(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildProductImage(product.imageUrl),
                    ),
                  ),

                  // LABEL LIMITED
                  if (product.isLimited)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LIMITED',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // TOMBOL FAVORITE
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => handleFavoriteToggle?.call(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.heart,
                          size: 16,
                          // Pastikan warna pink sesuai variabel global atau hardcode Colors.pink
                          color: product.isFavorite ? Colors.pink : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFO SECTION
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatRupiah(product.price),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => handleAddToCart?.call(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.pink, // Sesuaikan warna tema
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}