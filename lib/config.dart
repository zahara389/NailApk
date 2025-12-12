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

// Model Galeri
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

// Data Produk (Deep copy dari yang di JS)
List<Product> initialNewArrivals = [
  Product(id: 1, brand: 'Madam Glam', name: 'Gel Polish Basic White (15ml)', price: 89000, imageUrl: 'product1.jpeg', isLimited: true),
  Product(id: 2, brand: 'OPI', name: 'Top Coat High Shine Formula', price: 149000, imageUrl: 'product2.jpeg', isLimited: false),
  Product(id: 3, brand: 'Born Pretty', name: 'Nail Art Brush Set (5pcs)', price: 75000, imageUrl: 'product3.jpeg', isLimited: false),
  Product(id: 4, brand: 'CND', name: 'Cuticle Oil Repair & Care', price: 65000, imageUrl: 'product4.jpeg', isLimited: false),
  Product(id: 5, brand: 'KUKEI', name: 'Pro Nail LED UV Lamp 54W', price: 450000, imageUrl: 'product5.jpeg', isLimited: false),
  Product(id: 6, brand: 'Madam Glam', name: 'Polish Remover Acetone 100ml', price: 30000, imageUrl: 'product6.jpeg', isLimited: false),
];

// Data Galeri
List<GalleryItem> initialGalleryItems = [
  GalleryItem(id: 101, title: 'French Manicure Klasik', style: 'Minimalis', tags: ['white', 'simple', 'gel'], designer: 'Studio A', likes: 120, imgUrl: 'https://placehold.co/200x300/ff80bf/ffffff?text=French+Klasik'),
  GalleryItem(id: 102, title: 'Summer Floral Pop', style: 'Floral', tags: ['warna', 'bunga', 'summer'], designer: 'Nailista', likes: 350, imgUrl: 'https://placehold.co/200x350/ffc0d9/333333?text=Floral+Pop'),
  GalleryItem(id: 103, title: 'Glittery Ombre Pink', style: 'Glamour', tags: ['glitter', 'pink', 'ombre'], designer: 'Glam Nail', likes: 500, imgUrl: 'https://placehold.co/200x250/ff80bf/ffffff?text=Ombre+Glitter'),
  GalleryItem(id: 104, title: 'Matte Nude Modern', style: 'Minimalis', tags: ['matte', 'nude', 'simple'], designer: 'Studio A', likes: 90, imgUrl: 'https://placehold.co/200x280/e6e6e6/333333?text=Matte+Nude'),
  GalleryItem(id: 105, title: 'Abstract Lines Art', style: 'Abstract', tags: ['garis', 'hitam', 'modern'], designer: 'Artisan Nails', likes: 210, imgUrl: 'https://placehold.co/200x320/cccccc/333333?text=Abstract+Lines'),
  GalleryItem(id: 106, title: 'Cosmic Pop Art Nails', style: 'Pop/Abstract', tags: ['bintang', 'kartun', 'warna-warni', 'abstract'], designer: 'Client Photo', likes: 450, imgUrl: 'https://placehold.co/200x300/ff80bf/ffffff?text=Cosmic+Art'),
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

final List<PurchaseHistory> dummyPurchaseHistory = [
  PurchaseHistory(id: 'ORD001', date: '2025-11-20', total: 249000, status: 'Shipped', items: 2),
  PurchaseHistory(id: 'ORD002', date: '2025-11-25', total: 65000, status: 'Delivered', items: 1),
  PurchaseHistory(id: 'ORD003', date: '2025-12-01', total: 480000, status: 'Processing', items: 3),
];

// Model Lokasi Layanan (Baru)
class Location {
  final String key;
  final String name;
  final String address;

  Location({required this.key, required this.name, required this.address});
}

final List<Location> availableLocations = [
  Location(key: 'JKT-SEL', name: 'Studio Jakarta Selatan (Jl. Iskandarsyah)', address: 'Jl. Iskandarsyah Raya No. 10'),
  Location(key: 'BDG-UTR', name: 'Studio Bandung Utara (Jl. Dago)', address: 'Jl. Ir. H. Djuanda No. 50'),
  Location(key: 'SBY-BRT', name: 'Studio Surabaya Barat (Jl. HR Muhammad)', address: 'Jl. HR Muhammad No. 88'),
];

// Model Booking
class Booking {
  final String id;
  final String date;
  final String time;
  final String service;
  final String location;
  final String status;

  Booking({required this.id, required this.date, required this.time, required this.service, required this.location, required this.status});
}

final List<Booking> dummyBookingHistory = [
  Booking(id: 'BKG001', date: '2025-12-28', time: '14:30', service: 'Manicure Gel Polish', location: 'Studio Jakarta Selatan', status: 'Confirmed'),
  Booking(id: 'BKG002', date: '2025-12-15', time: '10:00', service: 'Pedicure Basic', location: 'Studio Bandung Utara', status: 'Completed'),
];

// Model Voucher
class Voucher {
  final int id;
  final String code;
  final String title;
  final String expiry;
  final String status;

  Voucher({required this.id, required this.code, required this.title, required this.expiry, required this.status});
}

final List<Voucher> dummyVouchers = [
  Voucher(id: 1, code: 'DISKON15', title: 'Diskon 15% All Items', expiry: '2026-03-31', status: 'available'),
  Voucher(id: 2, code: 'FREEONGKIR', title: 'Gratis Ongkir Min. 100K', expiry: '2025-12-31', status: 'available'),
  Voucher(id: 3, code: 'WELCOMEBACK', title: 'Potongan Rp 25.000', expiry: '2025-10-15', status: 'used'),
];

// Model Notifikasi
class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String time;
  bool read;

  NotificationItem({required this.id, required this.type, required this.title, required this.time, required this.read});

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

final List<NotificationItem> dummyNotifications = [
  NotificationItem(id: 1, type: 'Promo', title: 'PROMO NATAL: Beli 2 Gratis 1 Top Coat!', time: '2h ago', read: false),
  NotificationItem(id: 2, type: 'Transaksi', title: 'Pesanan #ORD004 telah dikirim.', time: '1 day ago', read: true),
  NotificationItem(id: 3, type: 'Sistem', title: 'Perbarui aplikasi Anda untuk fitur booking.', time: '3 days ago', read: true),
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
  final PurchaseHistory newOrder;

  PaymentDetails({
    required this.methodKey,
    required this.totalAmount,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.newOrder,
  });
}

// Model Alamat
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

// =================================================================================
// HELPER FUNCTION
// =================================================================================

String formatRupiah(int amount) {
  final formatter = amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return 'Rp $formatter';
}