import 'package:flutter/material.dart';

// =================================================================================
// KONFIGURASI DAN DATA GLOBAL
// =================================================================================

// Warna Kustom
const Color customPink = Color(0xffff80bf);
const Color customPinkLight = Color(0xffffe0f0);

// Model Produk
class Product {
  final int id;
  final String brand;
  final String name;
  final int price;
  final String imageUrl;
  final bool isLimited;
  bool isFavorite;

  Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isLimited,
    this.isFavorite = false,
  });

  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      brand: brand,
      name: name,
      price: price,
      imageUrl: imageUrl,
      isLimited: isLimited,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Data Produk (Dummy)
List<Product> initialNewArrivals = [
  Product(id: 1, brand: 'Madam Glam', name: 'Gel Polish Basic White (15ml)', price: 89000, imageUrl: 'https://i.ibb.co/6P0jL6k/white-gel-polish.png', isLimited: true),
  Product(id: 2, brand: 'OPI', name: 'Top Coat High Shine Formula', price: 149000, imageUrl: 'https://i.ibb.co/VMyhV61/top-coat-opi.png', isLimited: false),
  Product(id: 3, brand: 'Born Pretty', name: 'Nail Art Brush Set (5pcs)', price: 75000, imageUrl: 'https://i.ibb.co/YkjV4xX/brush-set-nail.png', isLimited: false),
  Product(id: 4, brand: 'CND', name: 'Cuticle Oil Repair & Care', price: 65000, imageUrl: 'https://i.ibb.co/4K413s5/cuticle-oil.png', isLimited: false),
  Product(id: 5, brand: 'KUKEI', name: 'Pro Nail LED UV Lamp 54W', price: 450000, imageUrl: 'https://i.ibb.co/hK5XjT0/uv-lamp.png', isLimited: false),
  Product(id: 6, brand: 'Madam Glam', name: 'Polish Remover Acetone 100ml', price: 30000, imageUrl: 'https://i.ibb.co/b3w6mYx/remover-bottle.png', isLimited: false),
];

// Data Kategori
const List<String> categories = ['Nail Polish', 'Nail tools', 'Nail care', 'Nail kit'];

// Model Riwayat Pembelian
class PurchaseHistory {
  final String id;
  final String date;
  final int total;
  final String status;
  final int items;

  PurchaseHistory({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });
}

final List<PurchaseHistory> dummyPurchaseHistory = [
  PurchaseHistory(id: 'ORD001', date: '2025-11-20', total: 249000, status: 'Shipped', items: 2),
  PurchaseHistory(id: 'ORD002', date: '2025-11-25', total: 65000, status: 'Delivered', items: 1),
  PurchaseHistory(id: 'ORD003', date: '2025-12-01', total: 480000, status: 'Processing', items: 3),
];

// Model Cart Item
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}

// Model Pembayaran
class PaymentDetails {
  final String methodKey;
  final int totalAmount;
  final String shippingMethod;
  final Address shippingAddress;

  PaymentDetails({
    required this.methodKey,
    required this.totalAmount,
    required this.shippingMethod,
    required this.shippingAddress,
  });
}

// Model Alamat
class Address {
  final String name;
  final String phone;
  final String address;

  Address({
    required this.name,
    required this.phone,
    required this.address,
  });

  Address copyWith({String? name, String? phone, String? address}) {
    return Address(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

// =================================================================================
// HELPER FUNCTION
// =================================================================================

String formatRupiah(int amount) {
  // Regex untuk menambahkan titik sebagai pemisah ribuan
  final formatter = amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return 'Rp $formatter';
}