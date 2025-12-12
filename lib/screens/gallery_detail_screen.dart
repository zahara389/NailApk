import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class GalleryDetailScreen extends StatelessWidget {
  final VoidCallback goBack;
  final GalleryItem? item;
  final Function(int) toggleFavorite;
  final Function(String, {dynamic data}) navigate;

  const GalleryDetailScreen({
    super.key,
    required this.goBack,
    required this.item,
    required this.toggleFavorite,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return const Scaffold(
        body: Center(
          child: Text('Item Galeri tidak ditemukan.'),
        ),
      );
    }

    final currentItem = item!;
    
    // Hitung tinggi total bottom bars
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 60.0; // tinggi bottom navigation
    final actionBarHeight = 82.0; // tinggi button bar (padding + button)
    final totalBottomHeight = bottomNavHeight + actionBarHeight + bottomPadding;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Colors.white,

                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: goBack,
                ),

                title: Text(
                  currentItem.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                actions: [
                  InkWell(
                    onTap: () => toggleFavorite(currentItem.id),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        LucideIcons.heart,
                        size: 28,
                        color:
                            currentItem.isFavorite ? customPink : Colors.black,
                      ),
                    ),
                  )
                ],
              ),

              // CONTENT dengan padding bottom yang cukup
              SliverPadding(
                padding: EdgeInsets.only(bottom: totalBottomHeight),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Foto Utama
                    Image.asset(
                      currentItem.imgUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 400,
                        color: customPinkLight,
                        child: const Center(
                          child: Text('Gambar tidak ditemukan di Assets'),
                        ),
                      ),
                    ),

                    // DETAIL CONTENT
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentItem.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Info Dasar
                          Text('Desainer: ${currentItem.designer}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Gaya Utama: ${currentItem.style}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Disukai: ${currentItem.likes} orang',
                              style: const TextStyle(fontSize: 16)),

                          const SizedBox(height: 24),

                          // Tags
                          const Text(
                            'Tags:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: currentItem.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(
                                      '#$tag',
                                      style: TextStyle(
                                          color: customPink, fontSize: 12),
                                    ),
                                    backgroundColor: customPinkLight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 20),

                          // Deskripsi
                          const Text(
                            'Tentang Gaya:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Gaya ini menampilkan perpaduan harmonis antara '
                            '${currentItem.style} dengan sentuhan '
                            '${currentItem.tags.join(', ')}. Sangat cocok untuk acara santai maupun formal, memberikan kesan elegan dan modern.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // BUTTON - Positioned di atas bottom navigation
          Positioned(
            bottom: bottomNavHeight + bottomPadding,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => navigate('Booking'),
                icon: const Icon(LucideIcons.calendar, color: Colors.white),
                label: const Text(
                  'Book Appointment',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}