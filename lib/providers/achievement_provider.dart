import 'package:flutter/material.dart';

import '../database/data_based_helper.dart';
import '../database/models/achievement.dart';

/// провайдер для обновления данных достижений
class AchievementProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  List<Achievement> _achievements = [];

  List<Achievement> get achievements => _achievements;

  /// загрузка списка достижений
  Future<void> loadAchievements() async {
    _achievements = await _dbHelper.getAchievements();
    notifyListeners();
  }

  /// обновление статуса достижения
  Future<void> updateAchieveStatus(int id, int newStatus) async {
    await loadAchievements();
    final index = _achievements.indexWhere((achieve) => achieve.id == id);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(status: newStatus);
      notifyListeners();

      await _dbHelper.updateAchieveStatus(id, newStatus);
    }
  }

  Future<int> getStatus(int id) async {
    await loadAchievements();
    return await _dbHelper.getAchieveStatus(id);
  }
}
