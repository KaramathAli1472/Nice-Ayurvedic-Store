class Product {
  String? id;
  String name;
  String description;
  double price;
  String imageUrl;
  String category;
  int stock;
  double rating;
  DateTime createdAt;
  
  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.rating,
    required this.createdAt,
  });
  
  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Create Product from Firebase Document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}