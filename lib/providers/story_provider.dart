import 'package:flutter/material.dart';
import 'package:neoflex_quiz/providers/quiz_cards_provider.dart';
import 'package:neoflex_quiz/screens/account_screen.dart';
import 'package:provider/provider.dart';

import '../database/data_based_helper.dart';
import '../database/models/story.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_top_dialog.dart';
import 'account_provider.dart';
import 'achievement_provider.dart';
import 'coin_provider.dart';

class StoryProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  final PageController pageController = PageController();
  final int quizId;
  final String title;
  List<Story> _stories = [];
  bool _isLoading = false;
  int _currentSlide = 0;
  int _monet = 0;

  bool get isLoading => _isLoading;
  int get currentQuestion => _currentSlide;
  int get monet => _monet;
  List<Story> get stories => _stories;

  StoryProvider(this.quizId, this.title) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    _isLoading = true;
    _stories = await _dbHelper.getStoryDialogs(quizId);
    _isLoading = false;
    notifyListeners();
  }

  void onAnswerSelected() {
    notifyListeners();
  }

  Future<void> nextDialog(BuildContext context) async {
    if (_currentSlide < _stories.length - 1) {
      _currentSlide++;
      pageController.jumpToPage(_currentSlide);
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
            title: "Поздравляем!",
            description: "За прохождение истории ты получил $_monet монет!",
            gradient: LinearGradient(colors: [
              Color(0xFFE8772F),
              Color(0xFFD1005B)
            ]),
            icon: null,
            buttonText: ["Спасибо"],
            buttonPress: [() {
              Navigator.pop(context);
              Navigator.pop(context);
            }
            ],
          ),
    );
    final provider = context.read<AchievementProvider>();
    if (await provider.getStatus(2)==0) {
      await provider.updateAchieveStatus(2, 1);
      String name = provider.achievements[2].title;
      CustomTopDialog.show(context, 'Получено достижение “$name”',  BaseScaffold(body: AccountScreen(), showLeading: false));
    }
  }

  Future<void> rewardPlayer(BuildContext context) async {
    _monet = await _dbHelper.rewardPlayer(quizId: quizId);

    notifyListeners();
    Provider.of<CoinProvider>(context, listen: false).updateCoins();

    int? state = await _dbHelper.getCardState(quizId);
    if (state == null) return;

    await _dbHelper.updateCardState(quizId, 2);
    Provider.of<QuizCardsProvider>(context, listen: false).updateCardState(quizId, 2);
    Provider.of<AccountProvider>(context, listen: false).loadQuizStatistic();

    await _updateNextCardState(quizId, context);

  }

  Future<void> _updateNextCardState(int quizId, BuildContext context) async {
    int? nextState = await _dbHelper.getCardState(quizId + 1);
    if (nextState != null && nextState == 0) {
      await _dbHelper.updateCardState(quizId + 1, 1);
      Provider.of<QuizCardsProvider>(context, listen: false).updateCardState(quizId + 1, 1);
    }
  }
}