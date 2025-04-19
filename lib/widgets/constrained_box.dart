import 'package:flutter/material.dart';

class CustomConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CustomConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = 550,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
        ),
    );
  }
}