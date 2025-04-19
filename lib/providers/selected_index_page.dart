import 'package:flutter/material.dart';

/// управление 3 страницами в MainPage и хранение переменной
class SelectedIndexPage with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}