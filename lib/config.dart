import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform; // ✅ WAJIB ADA untuk cek Android Emulator

// =================================================================================
// KONFIGURASI GLOBAL
// =================================================================================

// Warna Kustom (Tema Pink)
const Color customPink = Color(0xffff80bf);
const Color customPinkLight = Color(0xffffe0f0);

// =================================================================================
// API CONFIG (FINAL & BENAR)
// =================================================================================

// Android Emulator   : http://10.0.2.2:8000
// iOS / Web / Desktop: http://127.0.0.1:8000
const String apiBaseUrl = "http://10.174.212.209:8000";

// FULL API PATH
const String apiPath = "$apiBaseUrl/api";

// Base URL untuk gambar produk (Default path)
const String imageBaseUrl = "$apiBaseUrl/images/products";

// =================================================================================
// DIO FACTORY
// =================================================================================
Dio createDio({String? token}) {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ),
  );
}

// =================================================================================
// MODEL PRODUCT
// =================================================================================

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

  /// Parsing dari API
  factory Product.fromApi(Map<String, dynamic> json) {
    final int id = (json['id'] is int)
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;

    final String name = json['name']?.toString() ?? 
                        json['product_name']?.toString() ?? 
                        '';

    // --- FIX HARGA (Agar tidak 0 dan handle String/Decimal) ---
    final dynamic priceVal = 
        json['unit_price'] ??       // Prioritas 1
        json['final_price'] ??      // Prioritas 2
        json['price'] ??            // Prioritas 3
        json['price_discounted'] ?? // Prioritas 4
        0;

    int price = 0;
    if (priceVal is num) {
      price = priceVal.toInt();
    } else {
      // Handle jika API kirim string "50000.00"
      final double? d = double.tryParse(priceVal.toString());
      price = d?.toInt() ?? 0;
    }

    // --- AMBIL STRING MENTAH SAJA (JANGAN TEMPEL URL DISINI) ---
    // Biarkan fungsi resolveApiImage yang menangani path lengkapnya nanti
    final String imageUrl =
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        '';

    final String brand = json['brand']?.toString() ?? '';
    final String status = json['status']?.toString() ?? '';
    final int stock = int.tryParse(json['stock']?.toString() ?? '') ?? 0;
    final bool isLimited = status.toLowerCase() == 'low stock' || stock < 5;

    return Product(
      id: id,
      brand: brand,
      name: name,
      price: price,
      imageUrl: imageUrl,
      isLimited: isLimited,
    );
  }
}

// =================================================================================
// MODEL CART ITEM
// =================================================================================

class CartItem {
  final int id;
  final Product product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// =================================================================================
// MODEL LAINNYA (GALLERY, ADDRESS, ETC)
// =================================================================================

class GalleryItem {
  final int id;
  final String title;
  final String style;
  final List<String> tags;
  final String designer;
  final int likes;
  final String imgUrl;
  bool isFavorite;

  GalleryItem({
    required this.id,
    required this.title,
    required this.style,
    required this.tags,
    required this.designer,
    required this.likes,
    required this.imgUrl,
    this.isFavorite = false,
  });

  GalleryItem copyWith({bool? isFavorite}) {
    return GalleryItem(
      id: id,
      title: title,
      style: style,
      tags: tags,
      designer: designer,
      likes: likes,
      imgUrl: imgUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

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

  PurchaseHistory copyWith({String? status}) {
    return PurchaseHistory(
      id: id,
      date: date,
      total: total,
      items: items,
      status: status ?? this.status,
    );
  }
}

class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String time;
  bool read;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
    required this.read,
  });

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      time: time,
      read: read ?? this.read,
    );
  }
}

class Address {
  final String name;
  final String phone;
  final String address;
  final String email;

  Address({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  Address copyWith({String? name, String? phone, String? address, String? email}) {
    return Address(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
    );
  }
}

class Booking {
  final String id;
  final String date;
  final String time;
  final String service;
  final String location;
  final String status;

  Booking({
    required this.id,
    required this.date,
    required this.time,
    required this.service,
    required this.location,
    required this.status,
  });
}

class Location {
  final String key;
  final String name;
  final String address;

  Location({required this.key, required this.name, required this.address});
}

class PaymentDetails {
  final String methodKey;
  final int totalAmount;
  final String shippingMethod;
  final Address shippingAddress;
  final PurchaseHistory newOrder;

  PaymentDetails({
    required this.methodKey,
    required this.totalAmount,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.newOrder,
  });
}

class Voucher {
  final int id;
  final String code;
  final String title;
  final String expiry;
  final String status;

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.expiry,
    required this.status,
  });
}

// =================================================================================
// HELPER FORMAT RUPIAH
// =================================================================================

String formatRupiah(int amount) {
  final formatted = amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return 'Rp $formatted';
}

// =================================================================================
// DUMMY DATA
// =================================================================================

List<Product> initialNewArrivals = [
  Product(id: 1, brand: 'Madam Glam', name: 'Gel Polish Basic White (15ml)', price: 89000, imageUrl: 'assets/images/product1.jpeg', isLimited: true),
  Product(id: 2, brand: 'OPI', name: 'Top Coat High Shine Formula', price: 149000, imageUrl: 'assets/images/product2.jpeg', isLimited: false),
  Product(id: 3, brand: 'Born Pretty', name: 'Nail Art Brush Set (5pcs)', price: 75000, imageUrl: 'assets/images/product3.jpeg', isLimited: false),
];

final List<GalleryItem> initialGalleryItems = [
  GalleryItem(id: 1, title: 'French Manicure Classic', style: 'Minimalis', tags: ['clean', 'white'], designer: 'Studio Nail', likes: 120, imgUrl: 'assets/images/gallery1.jpg'),
  GalleryItem(id: 2, title: 'Pink Glitter Glam', style: 'Glamour', tags: ['pink', 'glitter'], designer: 'Nail Artist', likes: 240, imgUrl: 'assets/images/gallery2.jpg'),
];

final List<PurchaseHistory> dummyPurchaseHistory = [
  PurchaseHistory(id: 'ORD001', date: '2025-11-20', total: 249000, status: 'Shipped', items: 2),
  PurchaseHistory(id: 'ORD002', date: '2025-11-25', total: 65000, status: 'Delivered', items: 1),
];

final List<NotificationItem> dummyNotifications = [
  NotificationItem(id: 1, type: 'Promo', title: 'Diskon 15% Semua Produk!', time: '2 jam lalu', read: false),
  NotificationItem(id: 2, type: 'Order', title: 'Pesanan kamu sudah dikirim', time: '1 hari lalu', read: true),
];

final List<Location> availableLocations = [
  Location(key: 'JKT-SEL', name: 'Studio Jakarta Selatan', address: 'Jl. Iskandarsyah Raya No. 10'),
  Location(key: 'BDG-UTR', name: 'Studio Bandung Utara', address: 'Jl. Ir. H. Djuanda No. 50'),
  Location(key: 'SBY-BRT', name: 'Studio Surabaya Barat', address: 'Jl. HR Muhammad No. 88'),
];

final List<Booking> dummyBookingHistory = [
  Booking(id: 'BKG001', date: '2025-12-28', time: '14:30', service: 'Manicure Gel Polish', location: 'Studio Jakarta Selatan', status: 'Confirmed'),
  Booking(id: 'BKG002', date: '2025-12-15', time: '10:00', service: 'Pedicure Basic', location: 'Studio Bandung Utara', status: 'Completed'),
];

final List<Voucher> dummyVouchers = [
  Voucher(id: 1, code: 'DISKON15', title: 'Diskon 15% Semua Produk', expiry: '2026-03-31', status: 'available'),
  Voucher(id: 2, code: 'FREEONGKIR', title: 'Gratis Ongkir Min. 100K', expiry: '2025-12-31', status: 'available'),
  Voucher(id: 3, code: 'WELCOME25', title: 'Potongan Rp 25.000', expiry: '2025-10-15', status: 'used'),
];

const List<String> categories = ['Nail Polish', 'Nail tools', 'Nail care', 'Nail kit'];

bool isAssetImage(String path) {
  return path.startsWith('assets/');
}

// =================================================================================
// 🔥 HELPER IMAGE PINTAR (FINAL & BENAR) 🔥
// =================================================================================

String resolveApiImage(String url) {
  if (url.isEmpty) return ''; 
  
  // 1. Cek aset lokal
  if (url.startsWith('assets/')) return url;

  String finalUrl = url;
  
  // 2. Jika belum ada HTTP (bukan URL lengkap)
  if (!url.startsWith('http')) {
    // Bersihkan slash di depan jika ada
    if (url.startsWith('/')) url = url.substring(1);

    // 🔥 CEK DOUBLE PATH (KUNCI PERBAIKAN) 🔥
    // Cek apakah url dari database SUDAH mengandung path 'images/products'
    // Logika: Jika mengandung 'images/', berarti itu path lengkap. Jangan tambah path lagi.
    if (url.contains('images/')) {
       // Jika DB menyimpan path lengkap: "images/products/foto.jpg"
       // Kita CUMA nambahin Base URL (http://127.0.0.1:8000)
       finalUrl = "$apiBaseUrl/$url";
    } else {
       // Jika DB hanya menyimpan nama file: "foto.jpg"
       // Baru kita pakai Image Base URL yang lengkap
       finalUrl = "$imageBaseUrl/$url";
    }
  }

  // 3. Fix Android Emulator (127.0.0.1 -> 10.0.2.2)
  try {
    if (Platform.isAndroid && finalUrl.contains('127.0.0.1')) {
      finalUrl = finalUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }
  } catch (e) {
    // Abaikan error di web/iosR
  }

  return finalUrl;
}