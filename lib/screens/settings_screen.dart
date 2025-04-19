import 'package:flutter/material.dart';
import 'package:neoflex_quiz/providers/providers.dart';
import 'package:neoflex_quiz/widgets/gradient_button.dart';
import 'package:provider/provider.dart';

import '../widgets/base_scaffold.dart';
import '../widgets/custom_text_field.dart';

/// виджет страницы с редактированием аккаунта
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();

  bool _isUsernameError = false;
  bool _isAgeError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _usernameFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  /// кнопка валидации заполненных полей
  ///
  /// 1. получаю данные с аккаунта
  /// 2. обрезаю пробелы с полей
  /// 3. проверяю поля
  /// 4.1 если ошибки есть - показываю error
  /// 4.2 фокус переношу
  /// 5. если проблем нет - обновляем данные
  Future<void> _validateAndSubmit() async {
    final provider = context.read<AccountProvider>();
    String name = _usernameController.text.trim();
    String ageText = _ageController.text.trim();

    /// имя от 2 символов
    /// возраст от 6 до 140
    int? age = int.tryParse(ageText);
    bool isNameValid = name.isEmpty || name.length >= 2;
    bool isAgeValid =
        ageText.isEmpty || (age != null && age >= 6 && age <= 140);

    setState(() {
      _isUsernameError = !isNameValid;
      _isAgeError = !isAgeValid;
    });

    if (!isNameValid) {
      _usernameFocus.requestFocus();
      return;
    } else if (!isAgeValid) {
      _ageFocus.requestFocus();
      return;
    }

    /// если поля пустые, надо уведомить, что надо хоть что-то написать или выйти
    if (name.isEmpty && ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заполните хотя бы одно поле для обновления.'),
          backgroundColor: Colors.black.withOpacity(0.65),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
        ),
      );
      return;
    }

    int result = await provider.updateAccountFields(
      nickname: name.isNotEmpty ? name : null,
      age: ageText.isNotEmpty ? int.parse(ageText) : null,
    );

    if (result != -1) {
      await provider.loadAccount();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обновлении.'),
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
  void initState() {
    super.initState();
    loadTextField();
  }

  /// заполняет поля тем, что уже есть в аккаунте
  void loadTextField() async {
    final provider = context.read<AccountProvider>();
    final account = provider.account;
    if (account.nickname.isNotEmpty) {
      _usernameController.text = account.nickname;
    }
    _ageController.text = account.age.toString();
  }

  @override
  Widget build(BuildContext context) {
    /// переменная для отслеживания появления клавиатуры и скрытия кнопки
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BaseScaffold(
        title: "Настройки",
        showLeading: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                  child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CustomTextField(
                          controller: _usernameController,
                          label: "Изменить имя",
                          errorLabel: "Содержит 2 или более букв",
                          placeholder: "Твое имя",
                          isError: _isUsernameError,
                          currentFocus: _usernameFocus,
                          nextFocus: _ageFocus,
                          necessarily: false),
                      CustomTextField(
                          controller: _ageController,
                          label: "Изменить возраст",
                          errorLabel: "Возраст от 6 до 140 лет",
                          placeholder: "Твой возраст",
                          isError: _isAgeError,
                          currentFocus: _ageFocus,
                          nextFocus: null,
                          necessarily: false),
                    ]),
              )),
            ),
            if (!isKeyboardOpen)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: GradientButton(
                  onPressed: () => _validateAndSubmit(),
                  buttonText: "Сохранить",
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, 0.50),
                    end: Alignment(1.00, 0.50),
                    colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                  ),
                ),
              )
          ],
        ));
  }
}