import 'package:flutter/material.dart';

import '../database/data_based_helper.dart';
import '../database/models/quiz_cards.dart';

class QuizCardsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<QuizCards> _cards = [];

  List<QuizCards> get cards => _cards;

  Future<void> loadCards() async {
   _cards = await _dbHelper.getCards();
    notifyListeners();
  }

  void updateCardState(int id, int newState) async {
    final index = _cards.indexWhere((card) => card.quizId == id);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(state: newState);
      notifyListeners();

      await _dbHelper.updateCardState(id, newState);
    }
  }
}