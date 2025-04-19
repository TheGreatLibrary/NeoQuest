import 'package:flutter/material.dart';

class PriceMonet extends StatelessWidget {
  final String title;
  final String text;

  const PriceMonet({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(49),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(49),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 3),
            Image.asset(
              'assets/image/ic_monet.png',
              width: 24,
              height: 24,
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
