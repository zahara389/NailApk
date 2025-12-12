import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class GalleryScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final VoidCallback goBack;
  final List<GalleryItem> galleryItems;
  final Function(int) toggleFavorite;

  const GalleryScreen({
    super.key,
    required this.navigate,
    required this.goBack,
    required this.galleryItems,
    required this.toggleFavorite,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _searchTerm = '';

  List<GalleryItem> get _filteredItems {
    if (_searchTerm.isEmpty) return widget.galleryItems;

    final q = _searchTerm.toLowerCase();
    return widget.galleryItems.where((item) =>
      item.title.toLowerCase().contains(q) ||
      item.designer.toLowerCase().contains(q) ||
      item.tags.any((tag) => tag.toLowerCase().contains(q))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        title: Text(
          'Inspirasi Galeri (${filteredItems.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari gaya atau tag...',
                prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: customPink),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (value) => setState(() => _searchTerm = value),
            ),
          ),

          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Tidak ada hasil untuk "$_searchTerm".',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                // ====== Stable GridView version (2 columns) ======
                : GridView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 8),
                    itemCount: filteredItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // childAspectRatio: width / height. Taller cards to prevent overflow.
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      return _GalleryCard(
                        item: filteredItems[index],
                        navigate: widget.navigate,
                        toggleFavorite: widget.toggleFavorite,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final GalleryItem item;
  final Function(String, {dynamic data}) navigate;
  final Function(int) toggleFavorite;

  const _GalleryCard({
    required this.item,
    required this.navigate,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // Balanced image height so the grid stays within its aspect ratio
    final fallbackHeight = 170 + (item.id % 3) * 10;

    return InkWell(
      onTap: () => navigate('GalleryDetail', data: item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 5),
          ],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image area with fixed height so grid doesn't depend on intrinsic image size
              SizedBox(
                height: fallbackHeight.toDouble(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // PERUBAHAN: Menggunakan Image.asset untuk foto lokal
                    Image.asset(
                      item.imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: customPinkLight,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.image, color: Colors.grey),
                              const SizedBox(height: 4),
                              Text(
                                "Asset not found\n${item.title}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay + text at bottom
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'by ${item.designer}',
                            style: TextStyle(color: Colors.grey.shade300, fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer + metadata row
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => toggleFavorite(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3)],
                        ),
                        child: Icon(
                          LucideIcons.heart,
                          size: 16,
                          color: item.isFavorite ? customPink : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}