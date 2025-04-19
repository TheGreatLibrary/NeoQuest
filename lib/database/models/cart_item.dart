class CartItem {
  final int id;
  final int productId;
  final String title;
  late final int quantity;
  final String image;
  final int price;

  CartItem(
      {required this.id,
      required this.productId,
      required this.title,
      required this.quantity,
      required this.image,
      required this.price});

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['cart_id'] as int,
      productId: map['product_id'] as int,
      title: map['title'] as String,
      image: map['image'] as String,
      quantity: map['quantity'] as int,
      price: map['price'] as int,
    );
  }
}
