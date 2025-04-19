import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neoflex_quiz/database/data_based_helper.dart';

import '../database/models/order_items_with_product.dart';
import '../database/models/orders.dart';

class OrdersProvider with ChangeNotifier, WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final VoidCallback _updateCoins;
  List<Order> _orders = [];
  Timer? _timer;
  bool _isLoading = false;
  bool _isUpdating = false;

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;

  OrdersProvider({required void Function() updateCoins}) : _updateCoins = updateCoins {
    checkAndUpdateOrders();
    _startAutoUpdate();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> loadOrders() async {
    _orders = await _dbHelper.getOrders();
    notifyListeners();
  }

  Future<List<OrderItemWithProduct>> loadItemByOrder(int id) async {
    return _dbHelper.getOrderItemsWithProduct(id);
  }

  Future<void> checkAndUpdateOrders() async {
    _isLoading = true;
    await _dbHelper.updateOrdersStatus();
    await loadOrders();
    _updateCoins();
    _isLoading = false;
    notifyListeners();
  }


  void _startAutoUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_isUpdating) return;
      _isUpdating = true;
      try {
        print("Таймер сработал");
        await checkAndUpdateOrders();
      } catch (e, st) {
        print("Ошибка в таймере: $e\n$st");
      } finally {
        _isUpdating = false;
      }
    });
    print("Таймер ЗАПУЩЕН!");
  }

  void _stopAutoUpdate() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoUpdate();
    } else if (state == AppLifecycleState.paused) {
      _stopAutoUpdate();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoUpdate();
    super.dispose();
  }

  Future<int> createOrder(String date, String delivery, String cancellation, int price) async {
    int result = await _dbHelper.createOrder(date, delivery, cancellation, price);
    loadOrders();
    return result;
  }
}