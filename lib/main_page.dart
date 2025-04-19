import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neoflex_quiz/providers/orders_provider.dart';
import 'package:neoflex_quiz/providers/selected_index_page.dart';
import 'package:provider/provider.dart';

import 'widgets/base_scaffold.dart';
import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';

/// управляет 3 основными страницами и кэширует страницы
/// для следующих переходов
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  /// список с экранами
  late final List<Widget> _screens;

  /// инициализация данных
  ///
  /// 1. заполнение списка пустышками вместо страниц
  /// 2. прекэширование иконки монет, так как используется везде
  /// 3. явная инициализация OrderProvider для начала работы таймера
  @override
  void initState() {
    super.initState();

    _screens = List<Widget>.filled(3, SizedBox());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(
          const AssetImage('assets/image/ic_monet.png'), context);

      context.read<OrdersProvider>();
    });
  }

  /// Метод для получения виджета экрана по индексу
  /// При каких-то исключениях в некорректном индексе возвращается загрушка
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const _KeepAliveWrapper(
          key: ValueKey('Home'),
          child: HomeScreen(),
        );
      case 1:
        return const _KeepAliveWrapper(
          key: ValueKey('Market'),
          child: MarketScreen(),
        );
      case 2:
        return const _KeepAliveWrapper(
          key: ValueKey('Account'),
          child: AccountScreen(),
        );
      default:
        return const SizedBox();
    }
  }

  /// постройка виджета
  @override
  Widget build(BuildContext context) {
    /// переменная для отслеживания работы клавиатуры. Она обеспечивает сокрытие
    /// навигационной панели при появлении клавиатуры, чтобы навигация не портилась
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    /// выбранная страница берется из Provider
    final selectedIndex = context.watch<SelectedIndexPage>().selectedIndex;
    _screens[selectedIndex] = _buildScreen(selectedIndex);

    return BaseScaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _AnimatedScreenSwitcher(
              currentIndex: selectedIndex,
              children: _screens,
            ),
          ),
          if (!isKeyboardOpen) const _CustomBottomNavBar(),
        ],
      ),
      showLeading: false,
    );
  }
}

/// класс, отвечающий за переключение страницы с плавной анимацией за 300мс
class _AnimatedScreenSwitcher extends StatelessWidget {
  final int currentIndex;
  final List<Widget> children;

  const _AnimatedScreenSwitcher({
    required this.currentIndex,
    required this.children,
  });

  /// обеспечивает анимацию переключеня между страницами с плавным
  /// эффектом проявления за 300мс
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (index) {
        return AnimatedOpacity(
          opacity: currentIndex == index ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: currentIndex != index,
            child: children[index],
          ),
        );
      }),
    );
  }
}

/// класс навигационной панели
class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40, left: 55, right: 55),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(90),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Selector<SelectedIndexPage, int>(
          selector: (_, provider) => provider.selectedIndex,
          builder: (_, selectedIndex, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  iconPath: "assets/icons/ic_home.svg",
                  isSelected: selectedIndex == 0,
                  onTap: () =>
                      context.read<SelectedIndexPage>().selectedIndex = 0,
                ),
                _NavItem(
                  iconPath: "assets/icons/market.svg",
                  isSelected: selectedIndex == 1,
                  onTap: () =>
                      context.read<SelectedIndexPage>().selectedIndex = 1,
                ),
                _NavItem(
                  iconPath: "assets/icons/account.svg",
                  isSelected: selectedIndex == 2,
                  onTap: () =>
                      context.read<SelectedIndexPage>().selectedIndex = 2,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// виджет для создания одного элемента навигационной панели с анимацией
/// переключения и окраски
class _NavItem extends StatelessWidget {
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: isSelected
                  ? [Color(0xFFD1005B), Color(0xFFE8772F)]
                  : [Color(0xFF2C2B2F), Color(0xFF2C2B2F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: SvgPicture.asset(
            iconPath,
            width: 35,
            height: 35,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

/// отвечает за сохрание страницы, чтобы устранить лишние отрисовки
///
/// 3 основных страницы постоянно используются, так что их требуется кэшировать
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({
    required Key key,
    required this.child,
  }) : super(key: key);

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}
class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
