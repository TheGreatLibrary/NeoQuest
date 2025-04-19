import 'package:flutter/widgets.dart';

class OnboardingProvider with ChangeNotifier {
  final PageController controller = PageController();
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void nextPage() {
    if (_currentIndex < 3) {
      _currentIndex++;
      controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}