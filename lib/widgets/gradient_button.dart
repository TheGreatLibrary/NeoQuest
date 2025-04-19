import 'package:flutter/material.dart';

/// градиентная кнопка, используется по всему приложению
class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final LinearGradient gradient;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.gradient
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: borderRadius)),
        overlayColor:  WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.pressed) ? Colors.white.withOpacity(0.2) : null),
        elevation: WidgetStateProperty.all(0), // Убираем тень
      ),
      child: Ink(
        decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: Theme.of(context)
              .textButtonTheme
              .style
              ?.textStyle
              ?.resolve({}),
          ),
        ),
      ),
    );
  }
}