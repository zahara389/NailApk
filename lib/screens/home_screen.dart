import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart' as config;
import '../components/product_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(String, {dynamic data}) navigate;
  final String userDisplayName;
  final int cartCount;
  final List<config.Product> newArrivals;
  final Function(List<config.Product>) setNewArrivals;
  final Function(config.Product) handleAddToCart;

  const HomeScreen({
    super.key,
    required this.navigate,
    required this.userDisplayName,
    required this.cartCount,
    required this.newArrivals,
    required this.setNewArrivals,
    required this.handleAddToCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<config.Product> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<config.Product> get filteredProducts {
    if (_selectedCategory.isEmpty) return widget.newArrivals;

    final c = _selectedCategory.toLowerCase();
    return widget.newArrivals.where((p) {
      final n = p.name.toLowerCase();
      if (c == 'nail polish') return n.contains('polish') || n.contains('gel');
      if (c == 'nail tools') return n.contains('brush') || n.contains('lamp') || n.contains('tool');
      if (c == 'nail care') return n.contains('oil') || n.contains('remover') || n.contains('care');
      if (c == 'nail kit') return n.contains('kit') || n.contains('set');
      return false;
    }).toList();
  }

  void _handleSearch(String query) {
    final searchQuery = query.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = widget.newArrivals.where((product) {
      final productName = product.name.toLowerCase();
      final brandName = product.brand.toLowerCase();
      // Cari berdasarkan nama produk atau brand
      return productName.contains(searchQuery) || brandName.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _showSearch() {
    setState(() {
      _isSearching = true;
      _searchController.clear();
      _searchResults = [];
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext modalContext) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Search Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) {
                        _handleSearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        prefixIcon: const Icon(LucideIcons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _handleSearch('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: config.customPink, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchResults = [];
                        _searchController.clear();
                      });
                      Navigator.pop(modalContext);
                    },
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.search, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Mulai ketik untuk mencari produk',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cari berdasarkan nama atau brand',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.packageOpen, 
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Produk tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Coba kata kunci lain',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              child: Text(
                                'Ditemukan ${_searchResults.length} produk',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: _searchResults.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.68,
                                ),
                                itemBuilder: (context, i) {
                                  final p = _searchResults[i];
                                  return ProductCard(
                                    product: p,
                                    navigateToPdp: (prod) {
                                      Navigator.pop(modalContext);
                                      widget.navigate('PDP', data: prod);
                                    },
                                    handleFavoriteToggle: (id) {
                                      widget.setNewArrivals(widget.newArrivals.map((x) {
                                        if (x.id == id) {
                                          return x.copyWith(isFavorite: !x.isFavorite);
                                        }
                                        return x;
                                      }).toList());
                                      _handleSearch(_searchController.text);
                                    },
                                    handleAddToCart: widget.handleAddToCart,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                userDisplayName: widget.userDisplayName,
                onSearchTap: _showSearch,
              ),

              const SizedBox(height: 16),

              /// 🔥 HERO BANNER SECTION
              const _HeroBanner(),

              const SizedBox(height: 24),

              /// KATEGORI
              _CategoriesSection(
                selected: _selectedCategory,
                onTap: (c) => setState(() => _selectedCategory = c),
              ),

              const SizedBox(height: 24),

              /// TITLE + LIHAT SEMUA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory.isEmpty 
                          ? 'Produk Terbaru' 
                          : _selectedCategory,
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.navigate('AllProducts'),
                      child: const Text('Lihat semua'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// PRODUK GRID
              filteredProducts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(LucideIcons.packageOpen, 
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada produk di kategori ini',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (context, i) {
                          final p = filteredProducts[i];
                          return ProductCard(
                            product: p,
                            navigateToPdp: (prod) =>
                                widget.navigate('PDP', data: prod),
                            handleFavoriteToggle: (id) {
                              widget.setNewArrivals(widget.newArrivals.map((x) {
                                if (x.id == id) {
                                  return x.copyWith(isFavorite: !x.isFavorite);
                                }
                                return x;
                              }).toList());
                            },
                            handleAddToCart: widget.handleAddToCart,
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= HEADER ================= */

class _Header extends StatelessWidget {
  final String userDisplayName;
  final VoidCallback onSearchTap;
  
  const _Header({
    required this.userDisplayName,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $userDisplayName 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan produk nail art terbaik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.search, size: 20, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= HERO BANNER ================= */

class _HeroBanner extends StatefulWidget {
  const _HeroBanner();

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              _HeroCard(
                title: 'Professional Nail Art',
                subtitle: 'Koleksi lengkap untuk para profesional',
                imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800&q=80',
                colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
              ),
              _HeroCard(
                title: 'New Trends 2025',
                subtitle: 'Warna & style terkini tahun ini',
                imageUrl: 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&q=80',
                colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              ),
              _HeroCard(
                title: 'Premium Quality',
                subtitle: 'Kualitas terjamin & terpercaya',
                imageUrl: 'https://images.unsplash.com/photo-1610992015732-2449b76344bc?w=800&q=80',
                colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? config.customPink 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> colors;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                  ),
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
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

/* ================= CATEGORIES ================= */

class _CategoriesSection extends StatelessWidget {
  final String selected;
  final Function(String) onTap;

  const _CategoriesSection({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kategori',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildCategoryChip(
                'Semua',
                selected.isEmpty,
                () => onTap(''),
              ),
              ...config.categories.map((c) {
                final isActive = selected == c;
                return _buildCategoryChip(
                  c,
                  isActive,
                  () => onTap(isActive ? '' : c),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? config.customPink : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? config.customPink : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive) ...[
                const Icon(LucideIcons.check, size: 16, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade700,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}