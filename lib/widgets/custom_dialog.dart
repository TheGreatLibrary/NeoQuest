import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neoflex_quiz/widgets/constrained_box.dart';
import 'dart:ui';

import 'gradient_border_button.dart';
import 'gradient_button.dart';

/// диалоговое окно с полями для настройки под любой дизайн
class CustomDialog extends StatelessWidget {
  final LinearGradient gradient;
  final String title;
  final String? description;
  final String? icon;
  final List<String> buttonText;
  final List<VoidCallback> buttonPress;

  const CustomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.buttonText,
    required this.buttonPress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          CustomConstrainedBox(
            child: DialogContent(
              gradient: gradient,
              title: title,
              description: description,
              icon: icon,
              buttonText: buttonText,
              buttonPress: buttonPress,
            ),
          ),
        ],
      ),
    );
  }
}

class DialogContent extends StatelessWidget {
  final LinearGradient gradient;
  final String title;
  final String? description;
  final String? icon;
  final List<String> buttonText;
  final List<VoidCallback> buttonPress;

  const DialogContent({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.buttonText,
    required this.buttonPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                if (icon != null)
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return gradient.createShader(bounds);
                    },
                    child: SvgPicture.asset(icon!, width: 32, height: 32),
                  ),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return gradient.createShader(bounds);
                  },
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (description != null)
              Text(
                description!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            GradientButton(
              onPressed: buttonPress.first,
              buttonText: buttonText.first,
              gradient: gradient,
            ),
            if (buttonPress.length == 2 && buttonText.length == 2) ...[
              const SizedBox(height: 16),
              GradientBorderButton(
                onPressed: buttonPress.last,
                buttonText: buttonText.last,
                gradient: gradient,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
