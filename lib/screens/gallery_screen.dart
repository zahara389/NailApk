import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
    final lowerCaseSearch = _searchTerm.toLowerCase();
    return widget.galleryItems.where((item) =>
        item.title.toLowerCase().contains(lowerCaseSearch) ||
        item.designer.toLowerCase().contains(lowerCaseSearch) ||
        item.tags.any((tag) => tag.contains(lowerCaseSearch))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text('Inspirasi Galeri (${filteredItems.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: customPink)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              onChanged: (value) => setState(() => _searchTerm = value),
            ),
          ),
          
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Tidak ada hasil untuk "$_searchTerm".', style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  )
                : MasonryGridView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: filteredItems.length,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
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
    return InkWell(
      onTap: () => navigate('GalleryDetail', data: item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                item.imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200 + (item.id % 5) * 20, 
                  color: customPinkLight,
                  child: Center(child: Text(item.title, textAlign: TextAlign.center)),
                ),
              ),
              Positioned.fill(
                child: Container(
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
                      Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('by ${item.designer}', style: TextStyle(color: Colors.grey.shade300, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => toggleFavorite(item.id),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.heart,
                      size: 16,
                      color: item.isFavorite ? customPink : Colors.grey.shade400,
                      fill: item.isFavorite ? customPink : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}