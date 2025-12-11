import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/product_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final String userDisplayName;
  final int cartCount;
  final List<Product> newArrivals;
  final Function(List<Product>) setNewArrivals;
  final Function(Product) handleAddToCart;
  final String currentView;

  const HomeScreen({
    super.key,
    required this.navigate,
    required this.userDisplayName,
    required this.cartCount,
    required this.newArrivals,
    required this.setNewArrivals,
    required this.handleAddToCart,
    required this.currentView,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearchActive = false;
  String _searchTerm = '';
  String _selectedCategory = '';

  void _handleFavoriteToggle(int productId) {
    bool wasFavorite = false;
    final updatedList = widget.newArrivals.map((p) {
      if (p.id == productId) {
        wasFavorite = p.isFavorite;
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
    widget.setNewArrivals(updatedList);
    if (!wasFavorite) {
      widget.navigate('Favorites');
    }
  }

  void _handleCategoryClick(String cat) {
    setState(() {
      _selectedCategory = _selectedCategory == cat ? '' : cat;
      _searchTerm = '';
    });
  }

  List<Product> _getFilteredProducts() {
    List<Product> products = widget.newArrivals;
    final lowerCaseSearch = _searchTerm.toLowerCase();

    if (_searchTerm.isNotEmpty) {
      products = products.where((product) =>
          product.name.toLowerCase().contains(lowerCaseSearch) ||
          product.brand.toLowerCase().contains(lowerCaseSearch)).toList();
    }

    if (_selectedCategory.isNotEmpty) {
      final categoryFilter = _selectedCategory.toLowerCase();
      products = products.where((product) {
        final name = product.name.toLowerCase();
        
        if (categoryFilter == 'nail polish') {
          return name.contains('polish') || name.contains('coat');
        }
        if (categoryFilter == 'nail tools') {
          return name.contains('brush') || name.contains('lamp') || name.contains('set');
        }
        if (categoryFilter == 'nail care') {
          return name.contains('oil') || name.contains('remover');
        }
        if (categoryFilter == 'nail kit') {
          return name.contains('kit') || name.contains('set');
        }
        return false;
      }).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              isSearchActive: _isSearchActive,
              userDisplayName: widget.userDisplayName,
              searchTerm: _searchTerm,
              onSearchToggle: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                  if (!_isSearchActive) _searchTerm = '';
                  _selectedCategory = '';
                });
              },
              onSearchChange: (value) {
                setState(() {
                  _searchTerm = value;
                  _selectedCategory = '';
                });
              },
            ),
            const SizedBox(height: 8),

            if (!_isSearchActive) _FeaturedSection(navigate: widget.navigate),

            const SizedBox(height: 16),
            _CategoriesSection(
              selectedCategory: _selectedCategory,
              onCategoryClick: _handleCategoryClick,
            ),
            const SizedBox(height: 24),

            _NewArrivalsSection(
              searchTerm: _searchTerm,
              selectedCategory: _selectedCategory,
              products: filteredProducts,
              navigateToPdp: (product) => widget.navigate('PDP', data: product),
              handleFavoriteToggle: _handleFavoriteToggle,
              handleAddToCart: widget.handleAddToCart,
              navigate: widget.navigate,
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isSearchActive;
  final String userDisplayName;
  final String searchTerm;
  final VoidCallback onSearchToggle;
  final Function(String) onSearchChange;

  const _Header({
    required this.isSearchActive,
    required this.userDisplayName,
    required this.searchTerm,
    required this.onSearchToggle,
    required this.onSearchChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isSearchActive)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Cari produk kuku...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: customPink)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: customPink)),
                      ),
                      onChanged: onSearchChange,
                      controller: TextEditingController(text: searchTerm),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onSearchToggle,
                    child: const Icon(LucideIcons.x, size: 24, color: Colors.grey),
                  ),
                ],
              ),
            )
          else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                Text(userDisplayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            InkWell(
              onTap: onSearchToggle,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(LucideIcons.search, size: 24, color: Colors.black),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  final Function(String, {dynamic data}) navigate;
  const _FeaturedSection({required this.navigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Banner 1: Remover
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            height: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CLEANSE & PROTECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Pure Acetone Remover',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: -10,
                  child: Image.network(
                    'https://i.ibb.co/b3w6mYx/remover-bottle.png',
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(height: 140, child: Center(child: Text('REMOVER'))),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                    onPressed: () => print('Shop Remover'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPink,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(80, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('SHOP NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          // Banner 2: LED UV Lamp
          InkWell(
            onTap: () => navigate('PDP', data: initialNewArrivals[4]),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KUKEI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                      const SizedBox(height: 4),
                      const Text(
                        'Pro Nail LED UV Lamp',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.1, color: Color(0xFF0D47A1)),
                      ),
                      const SizedBox(height: 8),
                      Text('Keringkan Gel Polish lebih cepat dan merata.', style: TextStyle(fontSize: 10, color: Colors.blue.shade800)),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: -5,
                    child: Image.network(
                      'https://i.ibb.co/hK5XjT0/uv-lamp.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(height: 100, child: Center(child: Text('LAMP'))),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Text('15% OFF | BELI SEKARANG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(LucideIcons.plus, size: 16, color: Color(0xFF0D47A1)),
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

class _CategoriesSection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryClick;

  const _CategoriesSection({
    required this.selectedCategory,
    required this.onCategoryClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onCategoryClick(cat),
                    child: Chip(
                      label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontSize: 14)),
                      backgroundColor: isSelected ? customPink : Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? customPink : Colors.grey.shade200),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewArrivalsSection extends StatelessWidget {
  final String searchTerm;
  final String selectedCategory;
  final List<Product> products;
  final void Function(Product) navigateToPdp;
  final void Function(int) handleFavoriteToggle;
  final void Function(Product) handleAddToCart;
  final Function(String, {dynamic data}) navigate;

  const _NewArrivalsSection({
    required this.searchTerm,
    required this.selectedCategory,
    required this.products,
    required this.navigateToPdp,
    required this.handleFavoriteToggle,
    required this.handleAddToCart,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    final title = searchTerm.isNotEmpty
        ? 'Hasil untuk "$searchTerm"'
        : selectedCategory.isNotEmpty
            ? 'Produk Kategori: $selectedCategory'
            : 'Produk Terbaru';

    final showNoResults = products.isEmpty && (searchTerm.isNotEmpty || selectedCategory.isNotEmpty);
    final showAllButton = searchTerm.isEmpty && selectedCategory.isEmpty && products.isNotEmpty;
    
    final displayProducts = (searchTerm.isNotEmpty || selectedCategory.isNotEmpty) 
        ? products
        : products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (showAllButton)
                TextButton(
                  onPressed: () => navigate('AllProducts'),
                  child: Text('Lihat semua', style: TextStyle(color: Colors.grey.shade500)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (showNoResults)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Text('Tidak ada produk ditemukan untuk kriteria ini.', style: TextStyle(color: Colors.grey.shade500)),
                    Text('Coba hapus filter atau ganti kata kunci.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: displayProducts.map((product) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProductCard(
                    product: product,
                    navigateToPdp: navigateToPdp,
                    handleFavoriteToggle: handleFavoriteToggle,
                    handleAddToCart: handleAddToCart,
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}