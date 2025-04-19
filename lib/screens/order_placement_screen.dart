import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neoflex_quiz/screens/order_screen.dart';
import 'package:neoflex_quiz/widgets/base_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:neoflex_quiz/widgets/custom_bottom_bar.dart';
import 'package:provider/provider.dart';
import '../database/models/cart_item.dart';
import '../providers/providers.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_text_field.dart';

/// страница для оформления заказа
class OrderPlacementScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int totalPrice;

  const OrderPlacementScreen(
      {required this.cartItems, required this.totalPrice, super.key});

  @override
  State<OrderPlacementScreen> createState() => _OrderPlacementScreenState();
}

class _OrderPlacementScreenState extends State<OrderPlacementScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _postFocus = FocusNode();

  bool _isFullNameError = false;
  bool _isPhoneError = false;
  bool _isPostError = false;

  @override
  void initState() {
    super.initState();
    loadTextField();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _postController.dispose();
    _fullNameFocus.dispose();
    _phoneFocus.dispose();
    _postFocus.dispose();
    super.dispose();
  }

  /// загрузка данных в поля из аккаунта, если они есть
  void loadTextField() async {
    final account = await context.read<AccountProvider>().getAccount();

    if (account.fullName != null) {
      _fullNameController.text = account.fullName!;
    }
    if (account.phone != null) {
      _phoneController.text = account.phone!;
    }
    if (account.postalCode != null) {
      _postController.text = account.postalCode!;
    }
  }

  /// отдельный метод для валидации ФИО, так как надо проверить, что там не только имя
  bool validateFullName() {
    final parts = _fullNameController.text.split(RegExp(r'\s+'));
    final nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ]+$');

    return parts.length >= 2 &&
        parts.every((part) => part.isNotEmpty && nameRegex.hasMatch(part));
  }

  /// валидация полей при нажатии на кнопку.
  ///
  /// Если все окей, оформляется заказ
  void _validateAndSubmit() {
    /// поля обрезаются для избегания пробелов
    _fullNameController.text = _fullNameController.text.trim();
    _phoneController.text = _phoneController.text.trim();
    _postController.text = _postController.text.trim();

    /// если есть ошибки при валидации они отображаются под полями
    setState(() {
      _isFullNameError = !validateFullName();
      _isPhoneError =
          !RegExp(r'^(?:\+7|8)\d{10}$').hasMatch(_phoneController.text);
      _isPostError = !RegExp(r'^\d{6}$').hasMatch(_postController.text);
    });

    /// фокусировка на поле с ошибкой
    if (_isFullNameError) {
      _fullNameFocus.requestFocus();
    } else if (_isPhoneError) {
      _phoneFocus.requestFocus();
    } else if (_isPostError) {
      _postFocus.requestFocus();
    } else if (!_isFullNameError && !_isPhoneError && !_isPostError) {
      /// когда ошибок нет предлагается вариант отказаться от оформления заказа
      showDialog(
        context: context,
        builder: (_) => CustomDialog(
            title: "Точно оформить заказ?",
            description: null,
            gradient: const LinearGradient(
                colors: [Color(0xFFD1005B), Color(0xFFE8772F)]),
            icon: null,
            buttonText: [
              "Да",
              "Вернуться к оформлению"
            ],
            buttonPress: [
              () async {
                Navigator.pop(context);

                /// обновляются данные аккаунта
                int success = await context
                    .read<AccountProvider>()
                    .updateAccountFields(
                        fullName: _fullNameController.text,
                        phone: _phoneController.text,
                        postalCode: _postController.text);
                if (success != -1) {
                  /// создание заказа
                  context.read<OrdersProvider>().createOrder(
                      getCurrentDateTime(),
                      getDateTime(1),
                      getDateTime(2),
                      widget.totalPrice + 10);
                  /// обновление состояния аккаунта пользователя
                  context.read<CoinProvider>().updateCoins();
                  final cart = context.read<CartProvider>();
                  /// очистка корзины и обновление ее
                  cart.checkCart();
                  cart.loadCart();

                  showDialog(
                    context: context,
                    builder: (_) => CustomDialog(
                        title: "Заказ оформлен",
                        description: null,
                        gradient: const LinearGradient(
                            colors: [Color(0xFFD1005B), Color(0xFFE8772F)]),
                        icon: 'assets/icons/ic_status_complete.svg',
                        buttonText: [
                          "Хорошо",
                        ],
                        buttonPress: [
                          () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrdersScreen()));
                          }
                        ]),
                  );
                }
              },
              () => Navigator.pop(context)
            ]),
      );
    }
  }

  /// метод для получения текущей даты
  String getCurrentDateTime() {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()); // Например, 25.03.2025 14:30:00
  }

  /// метод для получения даты с каким-то добавочным числом
  String getDateTime(int minutes) {
    return DateFormat('dd.MM.yyyy HH:mm:ss')
        .format(DateTime.now().add(Duration(minutes: minutes)));
  }

  @override
  Widget build(BuildContext context) {
    /// переменная для проверки появления клавиатуры и скрытия кнопки
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BaseScaffold(
      title: "Заказ",
      showLeading: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: _fullNameController,
                      label: "ФИО",
                      errorLabel: "Содержит 2 или более слов",
                      placeholder: "Твое ФИО",
                      isError: _isFullNameError,
                      currentFocus: _fullNameFocus,
                      nextFocus: _phoneFocus,
                    ),
                    CustomTextField(
                      controller: _phoneController,
                      label: "Номер телефона",
                      errorLabel: "Содержит 11 цифр с +7 или 8",
                      placeholder: "Твой номер телефона",
                      isError: _isPhoneError,
                      currentFocus: _phoneFocus,
                      nextFocus: _postFocus,
                    ),
                    CustomTextField(
                      controller: _postController,
                      label: "Почтовый индекс",
                      errorLabel: "Содержит 6 цифр",
                      placeholder: "Твой почтовый индекс",
                      isError: _isPostError,
                      currentFocus: _postFocus,
                      nextFocus: null,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/warning_ic.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        'Доставка возможна только по России. Срок доставки: ',
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                                TextSpan(
                                    text: 'до 2 недель',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!isKeyboardOpen)
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 16,
                  right: 16,
                ),
                child: CustomBottomBar(
                  totalPrice: widget.totalPrice,
                  onPressed: _validateAndSubmit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
