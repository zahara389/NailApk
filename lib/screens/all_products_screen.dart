import 'package:flutter/material.dart';
import 'dart:io';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../components/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<Product> newArrivals;
  final Function(Product) handleAddToCart;
  final Function(List<Product>) setNewArrivals;

  final Future<void> Function()? onRefresh;
  final Future<Product?> Function(
    Map<String, dynamic> payload, {
    String? imagePath,
  })? onCreate;

  final Future<Product?> Function(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  })? onUpdate;

  final Future<bool> Function(int id)? onDelete;

  const AllProductsScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.newArrivals,
    required this.handleAddToCart,
    required this.setNewArrivals,
    this.onRefresh,
    this.onCreate,
    this.onUpdate,
    this.onDelete,
  });

  // ================= FAVORITE =================
  void _handleFavoriteToggle(int productId) {
    final updated = newArrivals.map((p) {
      if (p.id == productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();

    setNewArrivals(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: goBack,
        ),
        title: Text(
          'Semua Produk (${newArrivals.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),

      // ================= GRID =================
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newArrivals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65, // PAS DENGAN ProductCard
        ),
        itemBuilder: (context, index) {
          final product = newArrivals[index];

          return GestureDetector(
            onLongPress: () =>
                _showItemOptions(context, product),
            child: ProductCard(
              product: product,
              navigateToPdp: (p) => navigate('PDP', data: p),
              handleFavoriteToggle: _handleFavoriteToggle, // ✅ FIX ERROR
              handleAddToCart: handleAddToCart,
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= OPTIONS =================
  void _showItemOptions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus'),
              onTap: () async {
                Navigator.pop(context);
                if (onDelete != null) {
                  await onDelete!(product.id);
                  setNewArrivals(
                    newArrivals.where((p) => p.id != product.id).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= CREATE =================
  void _showCreateDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String? imagePath;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
              onPressed: () async {
                final picker = ImagePicker();
                final file =
                    await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  imagePath = file.path;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (onCreate != null) {
                final product = await onCreate!(
                  {
                    'name': nameCtrl.text,
                    'price': int.tryParse(priceCtrl.text) ?? 0,
                  },
                  imagePath: imagePath,
                );

                if (product != null) {
                  setNewArrivals([...newArrivals, product]);
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ================= EDIT =================
  void _showEditDialog(BuildContext context, Product product) async {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl =
        TextEditingController(text: product.price.toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (onUpdate != null) {
                final updated = await onUpdate!(
                  product.id,
                  {
                    'name': nameCtrl.text,
                    'price':
                        int.tryParse(priceCtrl.text) ?? product.price,
                  },
                );

                if (updated != null) {
                  setNewArrivals(
                    newArrivals
                        .map((p) => p.id == updated.id ? updated : p)
                        .toList(),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
