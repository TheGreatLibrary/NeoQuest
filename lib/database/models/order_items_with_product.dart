class OrderItemWithProduct {
  final int productId;
  final int quantity;
  final String title;
  final int price;
  final String image;

  OrderItemWithProduct({
    required this.productId,
    required this.quantity,
    required this.title,
    required this.price,
    required this.image,
  });

  factory OrderItemWithProduct.fromMap(Map<String, dynamic> map) {
    return OrderItemWithProduct(
      productId: map['product_id'],
      quantity: map['quantity'],
      title: map['title'],
      price: map['price'],
      image: map['image'],
    );
  }
}