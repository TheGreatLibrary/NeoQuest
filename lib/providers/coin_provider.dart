import 'package:flutter/material.dart';

import '../database/data_based_helper.dart';

class CoinProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _coinCount = 0;

  int get coinCount => _coinCount;

  Future<void> updateCoins() async {
    final newCount = await _dbHelper.getMoney();
    if (_coinCount != newCount) {
      _coinCount = newCount;
      notifyListeners();
    }
  }
}
