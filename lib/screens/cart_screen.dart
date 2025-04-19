import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neoflex_quiz/providers/providers.dart';
import 'package:neoflex_quiz/screens/product_screen.dart';
import 'package:neoflex_quiz/widgets/base_scaffold.dart';
import 'package:neoflex_quiz/widgets/custom_bottom_bar.dart';
import 'package:provider/provider.dart';
import '../database/models/cart_item.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/delay_loading_image.dart';
import '../widgets/shimmer_widget.dart';
import 'order_placement_screen.dart';

/// экран корзины
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return BaseScaffold(
      title: "Корзина",
      showLeading: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          children: [
            Positioned.fill(
                child: cartProvider.isLoading
                    ? const _CartListShimmer()
                    : cartProvider.cartItems.isEmpty
                        ? Center(child: Text("Корзина пуста"))
                        : ListView.builder(
                            itemCount: cartProvider.cartItems.length + 1,
                            itemBuilder: (_, index) {
                              if (index == cartProvider.cartItems.length) {
                                return const SizedBox(height: 120);
                              }
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: _CartItemWidget(
                                      item: cartProvider.cartItems[index],
                                      cartProvider: cartProvider));
                            },
                          )),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomBar(
                  totalPrice: cartProvider.totalPrice,
                  onPressed: () async {
                    if (cartProvider.totalPrice == 0) {
                      return;
                    }
                    if (await cartProvider.checkMonet()) {
                      showDialog(
                        context: context,
                        builder: (_) => CustomDialog(
                            title: "Упс...",
                            description: "Для заказа не хватает монет :(",
                            gradient: LinearGradient(
                                colors: [Color(0xFF800F44), Color(0xFF411485)]),
                            icon: null,
                            buttonText: ["Вернуться в корзину"],
                            buttonPress: [() => Navigator.pop(context)]),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OrderPlacementScreen(
                                cartItems: cartProvider.cartItems,
                                totalPrice: cartProvider.totalPrice)),
                      );
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}

/// список из заглушек
class _CartListShimmer extends StatelessWidget {
  const _CartListShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(children: [
          const ShimmerWidget.rectangular(height: 155, borderRadius: 20),
          const SizedBox(height: 24),
          ...List.generate(
              4,
              (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child:
                      ShimmerWidget.rectangular(height: 55, borderRadius: 15)))
        ]));
  }
}

/// карточка товара в корзине
class _CartItemWidget extends StatelessWidget {
  final CartProvider cartProvider;
  final CartItem item;

  const _CartItemWidget(
      {required this.cartProvider, required this.item});

  @override
  Widget build(BuildContext context) {
    /// получение провайдера продуктов
    final productProvider = context.read<ProductProvider>();
    /// получение ширины и высоты экрана для адаптивности картинки под экран
    final imageWidth = MediaQuery.of(context).size.width * 0.43;
    final imageHeight = MediaQuery.of(context).size.height * 0.16;

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final product =
                  await productProvider.getProductById(item.productId);
              if (product != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(product: product),
                  ),
                );
              }
            },
            child: Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DelayLoadingImage(
                  imagePath: 'assets/image/${item.image}.webp',
                  width: imageWidth,
                  height: imageHeight,
                  delay: 300,
                  fit: null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Row(
                      children: [
                        Image.asset('assets/image/ic_monet.png', width: 24),
                        Text('${item.price}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontSize: 18))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _QuantityButton(
                              symbol: '-',
                              onPressed: () => cartProvider.addToCart(item, -1),
                              onLongPress: () =>
                                  cartProvider.addToCart(item, -1),
                            ),
                            Text(
                              item.quantity.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            _QuantityButton(
                              symbol: '+',
                              onPressed: () {
                                if (item.quantity < 99) {
                                  cartProvider.addToCart(item, 1);
                                } else {
                                  _showMaxSnackBar(context);
                                }
                              },
                              onLongPress: () {
                                if (item.quantity < 99) {
                                  cartProvider.addToCart(item, 1);
                                }
                              },
                            ),
                          ]),
                    ),
                    GestureDetector(
                      onTap: () => cartProvider.removeItem(item),
                      child: SvgPicture.asset('assets/icons/ic_trash.svg',
                          width: 32, height: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// сообщение о превышении лимита товара в корзине
  void _showMaxSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Максимально за заказ может быть приобретено не больше 99 единиц одного товара'),
        backgroundColor: Colors.black.withOpacity(0.65),
        duration: const Duration(seconds: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
      ),
    );
  }
}

/// виджет с кнопкой + и -
class _QuantityButton extends StatefulWidget {
  final String symbol;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const _QuantityButton({
    required this.symbol,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  Timer? _timer;
  int _interval = 100;

  /// ускорение таймера при долгом нажатии, чтобы быстрее увеличивать
  /// число товаров (или уменьшать)
  void _startHolding() {
    widget.onLongPress();
    _interval = 100;

    _timer = Timer.periodic(Duration(milliseconds: _interval), (timer) {
      if (_interval > 30) {
        _interval = (_interval * 0.75).toInt();
        timer.cancel();
        _startHolding();
      } else {
        widget.onLongPress();
      }
    });
  }

  /// остановка таймера
  void _stopHolding() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPressStart: (_) => _startHolding(),
      onLongPressEnd: (_) => _stopHolding(),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8772F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(32, 32),
        ),
        child: Text(
          widget.symbol,
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopHolding();
    super.dispose();
  }
}