import 'package:flutter/material.dart';

/// градиентный текст
class GradientText extends StatelessWidget {
  final String text;
  final List<Color> gradient;
  final TextAlign align;
  final TextStyle style;

  const GradientText({super.key,
    required this.text,
    required this.gradient,
    required this.style, required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradient,
      ).createShader(bounds),
      child: Text(text, textAlign: align, style: style),
    );
  }
}