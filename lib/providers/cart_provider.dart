import 'package:flutter/material.dart';
import 'package:neoflex_quiz/database/models/cart_item.dart';

import '../database/data_based_helper.dart';

class CartProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  List<CartItem> _cartItems = [];
  int _totalPrice = 0;
  bool _cartEmpty = true;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get cartEmpty => _cartEmpty;
  List<CartItem> get cartItems => _cartItems;
  int get totalPrice => _totalPrice;

  CartProvider() {
    loadCart();
    checkCart();
  }

  Future<void> checkCart() async {
    final isEmpty = await _dbHelper.isCartEmpty();
    if (_cartEmpty != isEmpty) {
      _cartEmpty = isEmpty;
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    _isLoading = true;
    _cartItems = await _dbHelper.getCartItems();
    _totalPrice = _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(CartItem item, int quantity) async {
    if (item.quantity + quantity > 0) {
      await _dbHelper.addToCart(item.productId, quantity);
      await loadCart();
    }
  }

  Future<void> addProductToCart(int productId, int quantity, BuildContext context) async {
      int result = await _dbHelper.addToCart(productId, quantity);
      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Максимально за заказ может быть приобретено не больше 99 единиц одного товара'),
            backgroundColor: Colors.black.withOpacity(0.65),
            duration: Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20)),
            ),
          ),
        );
      }
        await loadCart();
        checkCart();
  }

  Future<void> removeItem(CartItem item) async {
    await _dbHelper.removeFromCart(item.id);
    _cartItems.remove(item);
    _totalPrice -= item.price * item.quantity;
    checkCart();
    notifyListeners();
  }

  Future<bool> checkMonet() async {
    int monet = await _dbHelper.getMoney();
    return _totalPrice + 10 > monet;
  }
}