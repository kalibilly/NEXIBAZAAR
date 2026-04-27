class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String? categoryName;
  final int stock;
  final String? imageUrl;
  final bool isActive;
  final String? arModelUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    required this.stock,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      categoryId: json['category'],
      categoryName: json['category_name'],
      stock: json['stock'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      arModelUrl: json['ar_model_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'stock': stock,
      'image_url': imageUrl,
      'ar_model_url': arModelUrl,
      'is_active': isActive,
    };
  }
}
