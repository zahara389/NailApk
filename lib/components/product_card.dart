import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Pastikan package ini terinstall
import '../config.dart'; // Sesuaikan import ini dengan lokasi model Product Anda

class ProductCard extends StatelessWidget {
  final Product product;
  // Callback functions dibuat nullable (?) agar widget ini fleksibel bisa dipakai tanpa fungsi tombol
  final Function(Product)? navigateToPdp; 
  final Function(int)? handleFavoriteToggle;
  final Function(Product)? handleAddToCart;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    this.navigateToPdp,
    this.handleFavoriteToggle,
    this.handleAddToCart,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isGrid ? null : 160,
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(right: 16), // Tambahkan margin jika list horizontal
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => navigateToPdp?.call(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AREA GAMBAR ---
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.asset(
                      product.imageUrl, // <--- PERBAIKAN: Gunakan property imageUrl langsung!
                      fit: BoxFit.cover, // Gunakan cover agar kotak terisi penuh
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey.shade400),
                            const SizedBox(height: 4),
                            Text(
                              'File not found:\n${product.imageUrl}', // Debugging: Tampilkan path yang dicari
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Badge Limited Edition
                if (product.isLimited)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'LIMITED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // Ikon Favorit
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => handleFavoriteToggle?.call(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite ? LucideIcons.heart : LucideIcons.heart, // Logic icon
                        size: 16,
                        color: product.isFavorite ? const Color(0xffff80bf) : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- AREA DETAIL TEXT ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand, 
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40, // Tinggi fixed untuk judul agar layout rata
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () => handleAddToCart?.call(product),
                        child: Container(
                          padding: const EdgeInsets.all(6), // Padding diperkecil sedikit agar proporsional
                          decoration: BoxDecoration(
                            color: const Color(0xffff80bf), // customPink
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