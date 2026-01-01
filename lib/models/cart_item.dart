import 'product.dart';

class CartItem {
  /// ID dari tabel `cart_items`
  final int id;

  /// Produk terkait
  final Product product;

  /// Jumlah item
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  /// Untuk update quantity di UI
  CartItem copyWith({
    int? quantity,
    Product? product,
  }) {
    return CartItem(
      id: id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  /// OPTIONAL: Parsing langsung dari API
  factory CartItem.fromApi(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'], // cart_items.id
      quantity: json['quantity'] ?? 1,
      product: Product.fromApi(json['product']),
    );
  }
}
