class OrderItems {
  int id;
  int orderId;
  int productId;
  int quantity;

  OrderItems({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory OrderItems.fromMap(Map<String, dynamic> map) {
    return OrderItems(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
    );
  }
}