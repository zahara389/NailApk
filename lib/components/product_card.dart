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
            // ================= IMAGE =================
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.asset(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),

                  // LIMITED
                  if (product.isLimited)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LIMITED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // FAVORITE
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          handleFavoriteToggle?.call(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.heart,
                          size: 16,
                          color: product.isFavorite
                              ? customPink
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= INFO =================
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatRupiah(product.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              handleAddToCart?.call(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: customPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: Colors.white,
                            ),
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
