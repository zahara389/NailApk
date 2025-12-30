class Product {
  final int id;
  final String name;
  final int price;
  final String? image;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.isFavorite = false,
  });

  // Digunakan untuk fungsi toggle favorite di UI
  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      name: name,
      price: price,
      image: image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Product.fromApi(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      price: json['price'] is int ? json['price'] : int.parse(json['price'].toString()),
      image: json['image'],
    );
  }
}