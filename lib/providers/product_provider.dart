import 'dart:async';

import 'package:flutter/material.dart';

import '../database/data_based_helper.dart';
import '../database/models/product.dart';

/// провайдер для работы с логикой в магазине
class ProductProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  Timer? _debounce;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  FocusNode focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

  bool _isLoading = false;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;

  /// фильтрация списка товаров в магазине с задержкой в 500мс
  /// чтобы не дергать каждое нажатие на кавиатуру список товаров
  void filterProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      notifyListeners();
    });
  }

  /// первая подгрузка товаров в магазине
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _dbHelper.getProducts();
    _filteredProducts = List.from(_products);

    _isLoading = false;
    notifyListeners();
  }

  /// получение данных по id товара
  Future<Product?> getProductById(int productId) async {
    return await _dbHelper.getProductById(productId);
  }

  /// метод для кнопки крестика в поле поиска
  void clearSearch() {
    searchController.clear();
    unfocusSearch();
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  /// снятие фокусировки
  void unfocusSearch() {
    if (focusNode.hasFocus) focusNode.unfocus();
  }

  @override
  void dispose() {
    focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }
}