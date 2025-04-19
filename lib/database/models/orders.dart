class Order {
  int id;
  int orderNumber;
  String createdAt;
  String deliveryDate;
  String status;
  String trackingNumber;
  int amount;

  Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.deliveryDate,
    required this.status,
    required this.trackingNumber,
    required this.amount
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'created_at': createdAt,
      'delivery_date': deliveryDate,
      'status': status,
      'tracking_number': trackingNumber,
      'amount': amount
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderNumber: map['order_number'],
      createdAt: map['created_at'],
      deliveryDate: map['delivery_date'],
      status: map['status'],
      trackingNumber: map['tracking_number'],
      amount: map['amount']
    );
  }
}