import 'package:flutter/material.dart';
import 'package:neoflex_quiz/providers/quiz_cards_provider.dart';
import 'package:neoflex_quiz/screens/account_screen.dart';
import 'package:provider/provider.dart';

import '../database/data_based_helper.dart';
import '../database/models/question.dart';
import '../screens/quiz_screen.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_top_dialog.dart';
import 'account_provider.dart';
import 'achievement_provider.dart';
import 'coin_provider.dart';

class QuizProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  final int quizId;
  final String title;
  final PageController pageController = PageController();
  List<Question> _questions = [];
  int _monet = 0;
  bool _isLoading = true;
  int _correctAnswersCount = 0;
  int _currentQuestion = 0;

  bool get isLoading => _isLoading;
  List<Question> get questions => _questions;
  int get correctAnswersCount => _correctAnswersCount;
  int get monet => _monet;
  int get currentQuestion => _currentQuestion;

  QuizProvider(this.quizId, this.title) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    _isLoading = true;
    _questions = await _dbHelper.getQuestions(quizId);
    _isLoading = false;
    notifyListeners();
  }

  void onAnswerSelected(bool isCorrect) {
    if (isCorrect) {
      _correctAnswersCount++;
    }
    notifyListeners();
  }

  Future<void> nextQuestion(BuildContext context) async {
    if (_currentQuestion < _questions.length - 1) {
      _currentQuestion++;
      pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
    else {
      await _showResultsDialog(context);
    }
    notifyListeners();
  }

  Future<void> _showResultsDialog(BuildContext context) async {
    await rewardPlayer(context);
    showDialog(
      context: context,
      builder: (context) =>
          CustomDialog(
            title: _correctAnswersCount >= 3
                ? "Поздравляем!"
                : "Упс...",
            description: _correctAnswersCount >= 3
                ? "Количество правильных ответов - $_correctAnswersCount из 4. Ты получаешь $_monet монет!"
                : "Количество правильных ответов - $_correctAnswersCount из 4. Попробуешь еще раз?",
            gradient: _correctAnswersCount >= 3
                ? LinearGradient(colors: [
              Color(0xFFE8772F),
              Color(0xFFD1005B)
            ])
                : LinearGradient(colors: [
              Color(0xFF800F44),
              Color(0xFF411485)
            ]),
            icon: null,
            buttonText: _correctAnswersCount >= 3 ? [
              "Спасибо"
            ] : ["Попробовать еще раз", "Вернуться в меню"],
            buttonPress: _correctAnswersCount >= 3
                ? [() {

              Navigator.pop(context);
              Navigator.pop(context);
            }
            ]
                : [
                  () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          QuizScreen(
                              title: title, id: quizId)),
                );
              },
                  () {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            ],
          ),
    );
  }

  Future<void> rewardPlayer(BuildContext context) async {
    _monet = await _dbHelper.rewardPlayer(quizId: quizId, correctAnswers: _correctAnswersCount);
    notifyListeners();
    Provider.of<CoinProvider>(context, listen: false).updateCoins();

    int? state = await _dbHelper.getCardState(quizId);
    if (state == null) return;

    if (_correctAnswersCount == 3) {
      await _updateNextCardState(quizId, context);
    } else if (state == 1 && _correctAnswersCount == 4) {
      await _dbHelper.updateCardState(quizId, 2);
      Provider.of<QuizCardsProvider>(context, listen: false).updateCardState(quizId, 2);

      await _updateNextCardState(quizId, context);
    }
    Provider.of<AccountProvider>(context, listen: false).loadQuizStatistic();
    final provider = context.read<AchievementProvider>();
    if (await provider.getStatus(3)==0 && correctAnswersCount == questions.length) {
      await provider.updateAchieveStatus(3, 1);
      String name = provider.achievements[1].title;
      CustomTopDialog.show(context, 'Получено достижение “$name”', BaseScaffold(body: AccountScreen(), showLeading: false));
    }
  }

  Future<void> _updateNextCardState(int quizId, BuildContext context) async {
    int? nextState = await _dbHelper.getCardState(quizId + 1);
    if (nextState != null && nextState == 0) {
      await _dbHelper.updateCardState(quizId + 1, 1);
      Provider.of<QuizCardsProvider>(context, listen: false).updateCardState(quizId + 1, 1);
    }
  }
}