import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neoflex_quiz/providers/product_provider.dart';
import 'package:neoflex_quiz/screens/product_screen.dart';
import 'package:neoflex_quiz/widgets/base_scaffold.dart';
import 'package:provider/provider.dart';

import '../database/models/models.dart';
import '../providers/orders_provider.dart';
import '../widgets/delay_loading_image.dart';
import '../widgets/shimmer_widget.dart';

/// страница с заказами
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// инициализация и обновление списка с заказами
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().checkAndUpdateOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// подписка на чтение данные с провайдера заказов
    final ordersProvider = context.read<OrdersProvider>();

    return BaseScaffold(
      title: "Заказы",
      showLeading: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RefreshIndicator(
          color: const Color(0xFFE8772F),
          backgroundColor: Colors.white,
          onRefresh: () async {
            await ordersProvider.checkAndUpdateOrders();
          },
          child: ordersProvider.isLoading
              ? const _ShimmerOrderList()
              : ordersProvider.orders.isEmpty
                  ? const Center(child: Text("Заказов нет"))
                  : Consumer<OrdersProvider>(
                      builder: (context, provider, _) {
                        /// список заказов
                        return ListView.builder(
                          itemCount: provider.orders.length,
                          padding: const EdgeInsets.only(top: 24),
                          itemBuilder: (context, index) {
                            final order = provider.orders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _OrderItem(order: order),
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

/// виджет заказа
class _OrderItem extends StatefulWidget {
  final Order order;

  const _OrderItem({
    required this.order,
  });

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<_OrderItem> {
  /// список товаров в заказе
  List<OrderItemWithProduct> items = [];

  /// раскрыт или нет - состояние
  bool isExpanded = false;

  /// процесс загрузки данных
  bool isLoading = false;

  /// инициализация данных по определенному заказу
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading = true;
      items =
          await context.read<OrdersProvider>().loadItemByOrder(widget.order.id);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF585858)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              behavior: HitTestBehavior.translucent,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Заказ №${widget.order.orderNumber}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 18)),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: SvgPicture.asset(
                        'assets/icons/arrow_open.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ])),
          Text('Создан ${widget.order.createdAt.split(' ')[0]}',
              style: Theme.of(context).textTheme.labelMedium),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: isExpanded
                ? (items.isEmpty && isLoading
                    ? CircularProgressIndicator()
                    : _OrderItemList(items: items, order: widget.order))
                : SizedBox(height: 16),
          ),
          const SizedBox(height: 8),
          Text(getStatus(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: getStatus() == "Доставляется"
                      ? const Color(0xFFE8772F)
                      : getStatus() == "Срок истек"
                          ? const Color(0xFFD1005B)
                          : const Color(0xFF0BA928))),
        ],
      ),
    );
  }

  /// получение статуса заказа
  String getStatus() {
    String status = widget.order.status;
    switch (status) {
      case "Доставляется":
        return status;
      case "Доставлен":
        return '$status ${widget.order.deliveryDate.split(' ')[0]}';
      default:
        return status;
    }
  }
}

/// список товаров заказа
class _OrderItemList extends StatelessWidget {
  final List<OrderItemWithProduct> items;
  final Order order;

  const _OrderItemList({required this.items, required this.order});

  /// метод для копирования номера трека при нажатии на трек
  Future<void> copyTrack(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: order.trackingNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Текст скопирован в буфер обмена'),
        backgroundColor: Colors.black.withOpacity(0.65),
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(spacing: 8, children: [
      const SizedBox(height: 8),
      if (order.status != "Срок истек")
        Row(children: [
          Text('Трэк-номер: ', style: Theme.of(context).textTheme.labelMedium),
          GestureDetector(
              onTap: () async => await copyTrack(context),
              child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                    ).createShader(bounds);
                  },
                  child: Text(order.trackingNumber,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: const Color(0xFFFFFFFF))))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () async => await copyTrack(context),
            child: SvgPicture.asset(
              'assets/icons/ic_copy.svg',
              width: 18,
              height: 18,
            ),
          ),
        ]),
      ...List.generate(items.length, (index) {
        final item = items[index];
        return _OrderItemListWidget(item: item);
      }),
    ]);
  }
}

/// виджет товара в заказе
class _OrderItemListWidget extends StatelessWidget {
  final OrderItemWithProduct item;

  const _OrderItemListWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    /// читает данные провайдера
    final productProvider = context.read<ProductProvider>();

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 16,
        children: [
          GestureDetector(
            onTap: () async {
              final product =
                  await productProvider.getProductById(item.productId);
              if (product != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductScreen(product: product)));
              }
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: DelayLoadingImage(
                    imagePath: 'assets/image/${item.image}.webp',
                    width: 120,
                    height: 120,
                    delay: 400),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(item.title,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ),
                  Text(
                    '${item.quantity} шт.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Image.asset('assets/image/ic_monet.png',
                      width: 19, height: 19),
                  Text(
                    '${item.price}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// заглушка списка товаров
class _ShimmerOrderList extends StatelessWidget {
  const _ShimmerOrderList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 24),
      ...List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerWidget.rectangular(
            height: 120,
            borderRadius: 15,
          ),
        ),
      ),
    ]);
  }
}
