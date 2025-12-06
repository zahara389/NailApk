import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function(Product) navigateToPdp;
  final void Function(int) handleFavoriteToggle;
  final void Function(Product) handleAddToCart;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    required this.navigateToPdp,
    required this.handleFavoriteToggle,
    required this.handleAddToCart,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isGrid ? null : 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => navigateToPdp(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Gambar
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text('Image Error')),
                  ),
                ),
                // Badge Limited Edition
                if (product.isLimited)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Chip(
                      label: Text('LIMITED EDITION', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                      labelPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                // Ikon Favorit
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => handleFavoriteToggle(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.heart,
                        size: 16,
                        color: product.isFavorite ? customPink : Colors.grey.shade400,
                        fill: product.isFavorite ? customPink : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Area Detail
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 30, // Ketinggian tetap untuk nama
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatRupiah(product.price),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () => handleAddToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: customPink,
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
          ],
        ),
      ),
    );
  }
}