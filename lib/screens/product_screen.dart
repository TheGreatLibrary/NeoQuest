import 'package:flutter/material.dart';
import 'package:neoflex_quiz/database/models/product.dart';
import 'package:neoflex_quiz/widgets/gradient_border_button.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/delay_loading_image.dart';
import '../widgets/gradient_button.dart';

class ProductScreen extends StatelessWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.cartItems.any((cartItem) => cartItem.productId == product.id);

    return BaseScaffold(
      showLeading: true,
      title: null,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DelayLoadingImage(imagePath: 'assets/image/${product.image}.webp', width: 800, height: 300, delay: 400)
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE8772F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        product.feature,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      textAlign: TextAlign.center,
                      style:  Theme.of(context).textTheme.titleSmall
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Image.asset('assets/image/ic_monet.png', width: 28, height: 28),
                        Text(
                          '${product.price} ',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 24)
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.labelMedium
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      onPressed: () => cartProvider.addProductToCart(product.id, 1, context),
                      buttonText: !isInCart ? 'Добавить в корзину' : 'Добавить еще',
                      gradient: const LinearGradient(
                        begin: Alignment(-1.00, 0.00),
                        end: Alignment(1, 0),
                        colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isInCart) GradientBorderButton(
                        onPressed: () => cartProvider.removeItem(cartProvider.cartItems.firstWhere((item) => item.productId == product.id)),
                        buttonText: 'Удалить из корзины',
                        gradient: const LinearGradient(
                          begin: Alignment(-1.00, 0.00),
                          end: Alignment(1, 0),
                          colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                        ),
                      )
                    else const SizedBox(height: 50)
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}