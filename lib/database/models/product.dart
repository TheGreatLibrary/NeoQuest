class Product {
  final int id;
  final String title;
  final String description;
  final String feature;
  final String image;
  final int price;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.feature,
      required this.image,
      required this.price});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      feature: map['feature'] as String,
      image: map['image'] as String,
      price: map['price'] as int,
    );
  }
}
