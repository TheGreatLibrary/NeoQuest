import "package:flutter/material.dart";
import 'package:flutter_svg/svg.dart';
import 'package:neoflex_quiz/database/models/product.dart';
import 'package:neoflex_quiz/screens/cart_screen.dart';
import 'package:neoflex_quiz/screens/order_screen.dart';
import 'package:neoflex_quiz/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/delay_loading_image.dart';
import '../widgets/gradient_text.dart';
import 'product_screen.dart';

/// страница магазина
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool _isPrecached = false;

  /// инициализация данных
  ///
  /// 1. прогрузка товаров магазина
  /// 2. прекэширование фотографий карточек товаров в магазине
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProductProvider>();
      await provider.loadProducts();

      final cards = provider.products;
      if (cards.isNotEmpty) {
        await Future.wait(cards.map((product) {
          return precacheImage(
              AssetImage('assets/image/${product.image}.webp'), context);
        }));
      }

      setState(() {
        _isPrecached = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LayoutBuilder(builder: (context, constraints) {
              final widthWindow = constraints.maxWidth;

              return CustomScrollView(slivers: [
                const SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  expandedHeight: 105,
                  floating: true,
                  snap: true,
                  pinned: false,
                  flexibleSpace: _Header(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16, bottom: 120),
                  sliver: Builder(
                    builder: (context) {
                      final provider = context.watch<ProductProvider>();
                      final cards = provider.products;

                      /// пока данные грузятся - заглушка
                      if (provider.isLoading || !_isPrecached) {
                        return SliverGridMarket(
                          width: widthWindow,
                          body: SliverChildBuilderDelegate(
                            (context, index) => const _ShimmerProductCard(),
                            childCount: 4,
                          ),
                        );
                      }

                      /// если товаров нет (в результате поиска например), итог
                      if (cards.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 150,
                            child: Center(
                              child: Text("Товары не найдены"),
                            ),
                          ),
                        );
                      }

                      /// товары
                      return SliverGridMarket(
                        width: widthWindow,
                        body: SliverChildBuilderDelegate(
                          (context, index) {
                            return _ProductCard(
                              key: ValueKey(cards[index].id),
                              product: cards[index],
                            );
                          },
                          childCount: cards.length,
                        ),
                      );
                    },
                  ),
                ),
              ]);
            })));
  }
}

/// шапка магазина
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          _HeaderWithButtons(),
          SizedBox(height: 16),
          _SearchTextField(),
        ],
      ),
    );
  }
}

/// кнопки корзины и заказов
class _HeaderWithButtons extends StatelessWidget {
  const _HeaderWithButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GradientText(
          text: 'Магазин',
          gradient: const [Color(0xFFD1005B), Color(0xFFE8772F)],
          style: Theme.of(context).textTheme.displayLarge!,
          align: TextAlign.left,
        ),
        Row(
          children: [
            Selector<CartProvider, bool>(
              selector: (context, cartProvider) => cartProvider.cartEmpty,
              builder: (context, cartEmpty, _) {
                return _HeaderButton(
                  icon: cartEmpty
                      ? "assets/icons/ic_cart_empty.svg"
                      : "assets/icons/ic_cart.svg",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            _HeaderButton(
              icon: 'assets/icons/order.svg',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// кнопка в шапке
class _HeaderButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _HeaderButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: SvgPicture.asset(
        icon,
        width: 32,
        height: 32,
      ),
    );
  }
}

/// поисковая строка в шапке магазина
class _SearchTextField extends StatelessWidget {
  const _SearchTextField();

  @override
  Widget build(BuildContext context) {
    return Selector<ProductProvider, String>(
      selector: (context, provider) => provider.searchController.text,
      builder: (context, searchText, _) {
        final productProvider = context.watch<ProductProvider>();

        return TextSelectionTheme(
          data: const TextSelectionThemeData(
            selectionColor: Color(0x7EE8772F),
            cursorColor: Color(0xFFE8772F),
            selectionHandleColor: Color(0x7EE8772F),
          ),
          child: TextField(
            controller: productProvider.searchController,
            focusNode: productProvider.focusNode,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w200),
            decoration: InputDecoration(
              hintText: 'Найти товар',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, left: 16, right: 8),
                child: SvgPicture.asset(
                  'assets/icons/search.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.only(
                            top: 7, bottom: 7, left: 8, right: 16),
                        child: SvgPicture.asset(
                          'assets/icons/close.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      onPressed: () {
                        productProvider.clearSearch();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
              ),
            ),
            onTapOutside: (_) => productProvider.unfocusSearch(),
            onChanged: (text) {
              productProvider.filterProducts(text);
            },
          ),
        );
      },
    );
  }
}

/// список товаров
class SliverGridMarket extends StatelessWidget {
  final double width;
  final SliverChildBuilderDelegate body;

  const SliverGridMarket({super.key, required this.body, required this.width});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (width / 180).floor().clamp(2, 4),
            childAspectRatio: (width / 2) / 270,
            crossAxisSpacing: 16,
            mainAxisSpacing: 2),
        delegate: body);
  }
}

/// заглушка товара
class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerWidget.rectangular(width: 151, height: 151, borderRadius: 20),
        SizedBox(height: 8),
        ShimmerWidget.rectangular(width: 100, height: 20, borderRadius: 20),
        SizedBox(height: 8),
        ShimmerWidget.rectangular(width: 60, height: 20, borderRadius: 20),
      ],
    );
  }
}

/// карточка товара
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductScreen(product: product)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _ProductImage(image: product.image),
              Positioned(
                bottom: 15,
                right: 0,
                child: _BuildAddButton(product: product),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Row(
            children: [
              Image.asset('assets/image/ic_monet.png', width: 24, height: 24),
              Text(
                '${product.price} ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// картинка товара
class _ProductImage extends StatelessWidget {
  final String image;

  const _ProductImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DelayLoadingImage(
            imagePath: 'assets/image/$image.webp',
            cacheWidth: 350,
            cacheHeight: 350,
            valueKey: ValueKey(image),
            width: 151,
            height: 151,
            delay: 300),
      ),
    );
  }
}

/// кнопка добавления товара в корзину
class _BuildAddButton extends StatelessWidget {
  final Product product;

  const _BuildAddButton({required this.product});

  @override
  Widget build(BuildContext context) {
    /// чтение данных провайдера корзины
    final provider = context.read<CartProvider>();

    return Opacity(
      opacity: 0.75, // от 0.0 (полностью прозрачный) до 1.0 (полностью видимый)
      child: ElevatedButton(
        onPressed: () => provider.addProductToCart(product.id, 1, context),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          shape: WidgetStateProperty.all(CircleBorder()),
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          // важно!
          shadowColor: WidgetStateProperty.all(
              Colors.transparent), // чтобы не было теней
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/icons/ic_cart_plus.svg',
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }
}
