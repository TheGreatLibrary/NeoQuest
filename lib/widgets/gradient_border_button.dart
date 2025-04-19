import 'package:flutter/material.dart';

class GradientBorderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final LinearGradient gradient;

  const GradientBorderButton(
      {super.key,
      required this.onPressed,
      required this.buttonText,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: gradient,
      ),
      padding: const EdgeInsets.all(1), // Обводка
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: borderRadius)),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? gradient.colors.first.withOpacity(0.2)
                  : null),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return gradient.createShader(bounds);
            },
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
      ),
    );
  }
}
