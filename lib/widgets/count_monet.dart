import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/coin_provider.dart";

class CountMonet extends StatelessWidget {
  const CountMonet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(70),
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/image/ic_monet.png', width: 28, height: 28),
          const SizedBox(width: 5),
          Consumer<CoinProvider>(
            builder: (context, coinProvider, child) {
              return Text(
                '${coinProvider.coinCount}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)
              );
            },
          )
        ],
      ),
    );
  }
}
