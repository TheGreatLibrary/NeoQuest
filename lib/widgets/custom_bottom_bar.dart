import 'package:flutter/material.dart';
import 'package:neoflex_quiz/widgets/price_monet.dart';

import 'gradient_button.dart';

/// кнопка с данными по заказу в корзине и офорфмлении заказов
class CustomBottomBar extends StatelessWidget {
  final int totalPrice;
  final VoidCallback onPressed;

  const CustomBottomBar({
    required this.totalPrice,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        const PriceMonet(title: 'Стоимость доставки:', text: '10'),
        PriceMonet(title: 'Итог:', text: '$totalPrice'),
        const SizedBox(height: 3),
        GradientButton(
          onPressed: onPressed,
          buttonText: 'Заказать',
          gradient: const LinearGradient(
            colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
          ),
        ),
      ],
    );
  }
}