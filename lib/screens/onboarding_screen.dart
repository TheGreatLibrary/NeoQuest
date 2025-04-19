import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neoflex_quiz/providers/providers.dart';
import 'package:neoflex_quiz/screens/account_screen.dart';
import 'package:neoflex_quiz/widgets/base_scaffold.dart';
import 'package:neoflex_quiz/widgets/custom_check_box.dart';
import 'package:neoflex_quiz/widgets/gradient_button.dart';
import 'package:neoflex_quiz/widgets/gradient_text.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main_page.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_top_dialog.dart';
import '../widgets/delay_loading_image.dart';


/// онбординг приложения
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// подписка на изменения провайдера
    final provider = context.watch<OnboardingProvider>();

    /// список страниц
    final pages = [
      const _OnboardingPage(
        title: "Добро пожаловать в путеводитель по миру компании Neoflex!",
        subtitle: "",
        image: 'assets/image/onboard1.png',
      ),
      const _OnboardingPage(
        title: "Открой мир Neoflex",
        subtitle:
        "Здесь всё, что тебе нужно: история, секреты компании и лёгкий способ разобраться, как тут всё устроено.",
        image: 'assets/image/onboard2.png',
      ),
      const _OnboardingPage(
        title: "Играй, учись, получай!",
        subtitle:
        "Здесь не только история, но и игра! Проходи квизы, копи баллы и забирай мерч. Начнем?",
        image: 'assets/image/onboard3.png',
      ),
      const _RegistrationPage()
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: PageView.builder(
          controller: provider.controller,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pages.length,
          itemBuilder: (_, index) => pages[index],
        ),
      ),
    );
  }
}

/// индикатор прогресса
class _ProgressIndicatorWidget extends StatelessWidget {
  const _ProgressIndicatorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 63,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 8,
                  color: Colors.transparent,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth * (context.read<OnboardingProvider>().currentIndex + 1) / 3,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment(0.00, 0.50),
                          end: Alignment(1.00, 0.50),
                          colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// градиентная кнопка для продолжения дальше
class _GradientNextButton extends StatelessWidget {
  const _GradientNextButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    return GradientButton(
      onPressed: provider.nextPage,
      buttonText: provider.currentIndex == 2 ? "Начать путешествие" : "Продолжить",
      gradient: const LinearGradient(
        begin: Alignment(-1.00, 0.00),
        end: Alignment(1, 0),
        colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
      ),
    );
  }
}

/// страница без формы
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const _ProgressIndicatorWidget(),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                GradientText(text: title, align: TextAlign.center, gradient: const [Color(0xFFD1005B), Color(0xFFE8772F)], style: Theme.of(context).textTheme.displayMedium!),
                const SizedBox(height: 16),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 80),
              ],
            ),
          ),
          DelayLoadingImage(imagePath: image, width: 280, height: 280, delay: 300),
          // OnboardingImage(path: image),
          const SizedBox(height: 80),
          const _GradientNextButton(),
        ],
      ),
    );
  }
}

/// страница с формой регистрации
class _RegistrationPage extends StatelessWidget {
  const _RegistrationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 60, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const _RegistrationHeader(),
              const _RegistrationForm(),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// регистрационная шапка
class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        spacing: 15,
        children: [
          const DelayLoadingImage(imagePath: 'assets/image/onboard4.png', width: 280, height: 280, delay: 300),


         // OnboardingImage(path:'assets/image/onboard4.png'),
          GradientText(text: "Регистрация", align: TextAlign.center, gradient: const [Color(0xFFD1005B), Color(0xFFE8772F)], style: Theme.of(context).textTheme.displayMedium!),
        ],
      ),
    );
  }
}

/// форма регистрации
class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();

  bool _isUsernameError = false;
  bool _isAgeError = false;
  bool _isCheckBoxError = false;
  bool _isChecked = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _usernameFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  /// валидация полей регистрации по нажатии на кнопку
  void _validateAndSubmit() async {
    /// обрезание пробелов
    final name = _usernameController.text.trim();
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);

    /// валидация
    final isNameValid = name.isNotEmpty && name.length >= 2;
    final isAgeValid = age != null && age >= 6 && age <= 140;
    final isCheckboxValid = _isChecked;

    /// установка ошибок, если есть
    setState(() {
      _isUsernameError = !isNameValid;
      _isAgeError = !isAgeValid;
      _isCheckBoxError = !isCheckboxValid;
    });

    /// фокусирование на поле с ошибкой
    if (!isNameValid) {
      _usernameFocus.requestFocus();
      return;
    }
    if (!isAgeValid) {
      _ageFocus.requestFocus();
      return;
    }
    if (isNameValid && isAgeValid && isCheckboxValid) {
      await _registerAccount(name, age);
    }
  }

  /// метод для регистрации аккаунта
  ///
  /// 1. подписывается на провайдеры аккаунта и достижений
  /// 2. создает аккаунт
  /// 3. меняем 2 фразы в 1 истории под имя пользователя
  /// 4. переход на MainPage
  Future<void> _registerAccount(String name, int age) async {
    final accountProvider = context.read<AccountProvider>();
    final achievementProvider = context.read<AchievementProvider>();

    final success = await accountProvider.createAccount(name, age);
    await accountProvider.replaceStoryDialogs(name);

    if (success) {
      await achievementProvider.updateAchieveStatus(1, 1);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
      final title = achievementProvider.achievements[0].title;
      CustomTopDialog.show(context, 'Получено достижение “$title”', BaseScaffold(body: AccountScreen(), showLeading: false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка регистрации или учетная запись не найдена'),
          backgroundColor: Colors.black.withOpacity(0.65),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
            controller: _usernameController,
            label: "Имя",
            errorLabel: "Содержит 2 или более букв",
            placeholder: "Твое имя",
            isError: _isUsernameError,
            currentFocus: _usernameFocus,
            nextFocus: _ageFocus),
        CustomTextField(
            controller: _ageController,
            label: "Возраст",
            errorLabel: "Возраст от 6 до 140 лет",
            placeholder: "Твой возраст",
            isError: _isAgeError,
            currentFocus: _ageFocus,
            nextFocus: null),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            CustomCheckBox(
              value: _isChecked,
              isError: _isCheckBoxError,
              onChanged: (value) {
                setState(() {
                  _isChecked = value;
                  _isCheckBoxError = false;
                });
              },
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: 'Я принимаю ',
                        style: Theme.of(context).textTheme.labelSmall),
                    TextSpan(
                        text: 'условия использования',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final url = Uri.parse('https://picnic-bk.ru/alex/neoflex_quiz/terms_of_use.html');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                    ),
                    TextSpan(
                        text: ' и ',
                        style: Theme.of(context).textTheme.labelSmall),
                    TextSpan(
                        text: 'политику конфиденциальности',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final url = Uri.parse('https://picnic-bk.ru/alex/neoflex_quiz/privacy_policy.html');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        GradientButton(
            onPressed: _validateAndSubmit,
            buttonText: "Создать аккаунт",
            gradient: const LinearGradient(
                begin: Alignment(-1.00, 0.00),
                end: Alignment(1, 0),
                colors: [Color(0xFFD1005B), Color(0xFFE8772F)])),
      ],
    );
  }
}