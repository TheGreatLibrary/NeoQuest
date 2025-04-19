import 'package:flutter/cupertino.dart';

import '../database/data_based_helper.dart';
import '../database/models/account.dart';

/// логика управления аккаунтом по всем страницам
class AccountProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  late Account _account;
  List<int> _quizStat = [];

  Account get account => _account;
  List<int> get quizStat => _quizStat;

  /// загрузка данных по статистике
  Future<void> loadQuizStatistic() async {
    final cards = await _dbHelper.getCards();
    int story = 0;
    int quiz = 0;
    for (var card in cards) {
      if (card.state == 2) {
        if (card.title.split(' ')[0] == "История") {
          story++;
        }
        else {
          quiz++;
        }
      }
    }
    _quizStat = [ story, quiz ];
    notifyListeners();
  }

  /// загрузка данных аккаунта
  Future<void> loadAccount() async {
    _account = (await _dbHelper.getAccount());
    notifyListeners();
  }

  /// получение аккаунта
  Future<Account> getAccount() async {
    await loadAccount();
    return account;
  }

  /// создание аккаунта
  Future<bool> createAccount(String name, int age) async {
    final newAccount = Account(nickname: name, age: age);
    final result = await _dbHelper.insertOrUpdateAccount(newAccount);
    if (result != -1) {
      _account = newAccount;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// замена диалогов в истории с добавлением nickname
  Future<void> replaceStoryDialogs(String name) async {
    final dialogs = await _dbHelper.getStoryDialogs(1);

    for (final dialog in dialogs) {
      if (dialog.choices != null && dialog.choices!.contains('Меня зовут ')) {
        final updated = dialog.copyWith(
          choices: 'Меня зовут $name',
        );
        await _dbHelper.addStoryDialog(updated);
      }

      if (dialog.text.contains('? Окей, запомнил.')) {
        final updated = dialog.copyWith(
          text: '$name? Окей, запомнил.',
        );
        await _dbHelper.addStoryDialog(updated);
      }
    }
  }

  /// обновление полей аккаунта
  Future<int> updateAccountFields({
    String? nickname,
    int? age,
    String? fullName,
    String? phone,
    String? postalCode,
    String? imagePath,
  }) async {
    final previousNickname = _account.nickname;

    _account = _account.copyWith(
      nickname: nickname ?? _account.nickname,
      age: age ?? _account.age,
      fullName: fullName ?? _account.fullName,
      phone: phone ?? _account.phone,
      postalCode: postalCode ?? _account.postalCode,
      imagePath: imagePath ?? _account.imagePath
    );

    final result = await _dbHelper.insertOrUpdateAccount(_account);
    if (result != -1) {
      notifyListeners();

      if (nickname != null && nickname != previousNickname) {
        await replaceStoryDialogs(nickname);
      }
    }

    return result;
  }
}
