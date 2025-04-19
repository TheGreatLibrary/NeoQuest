import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neoflex_quiz/database/models/quiz_cards.dart';
import 'package:neoflex_quiz/screens/quiz_screen.dart';
import 'package:neoflex_quiz/screens/story_screen.dart';
import 'package:neoflex_quiz/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_cards_provider.dart';
import '../widgets/delay_loading_image.dart';
import '../widgets/gradient_text.dart';

/// главная страница приложения, здесь расположена дорожная карта с квизами и историями
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _cardAssets = _CardAssets();

  /// инициализация данных по квизам
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizCardsProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// получение карточек квизов
    final cards = context.select<QuizCardsProvider, List<QuizCards>>((provider) => provider.cards);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            cards.isEmpty
                ? const _LoadingCardList()
                : _GameCardList(cards: cards),
            const SliverToBoxAdapter(child: _Footer()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),

          ],
        ),
      ),
    );
  }
}

/// градиенты, наклоны картинок и размеры
class _CardAssets {
  final List<String> imagePaths = const [
    'assets/image/card1.png',
    'assets/image/card2.png',
    'assets/image/card3.png',
    'assets/image/card4.png',
    'assets/image/card5.png',
    'assets/image/card6.png',
  ];

  final List<List<Color>> gradientColors = const [
    [Color(0xFFD1005B), Color(0xFFE8772F)],
    [Color(0xFF421485), Color(0xFF800F44)],
    [Color(0xFFE0902C), Color(0xFFD1005B)],
    [Color(0xFF800F44), Color(0xFFE9782E)],
    [Color(0xFFD1005B), Color(0xFFE8772F)],
    [Color(0xFF421485), Color(0xFF800F44)],
  ];

  final List<double> angles = const [
    -0.15,
    -0.05,
    0.48,
    -0.15,
    0.3,
    -0.55,
  ];

  final List<double> sizes = const [
    175,
    180,
    170,
    170,
    175,
    165,
  ];

  const _CardAssets();
}

/// шапка страницы
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          text: 'Поиграем?',
          gradient: const [Color(0xFFD1005B), Color(0xFFE8772F)],
          style: Theme.of(context).textTheme.displayLarge!,
          align: TextAlign.left,
        ),
        const SizedBox(height: 4),
        Text(
          'Выбери историю или квиз',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// заглушка список
class _LoadingCardList extends StatelessWidget {
  const _LoadingCardList();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (_, __) => const _ShimmerCard(),
        childCount: 3,
      ),
    );
  }
}

/// заглушка карточка
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 25, bottom: 20),
      child: ShimmerWidget.rectangular(height: 168, borderRadius: 16),
    );
  }
}

/// список карточек
class _GameCardList extends StatelessWidget {
  final List<QuizCards> cards;

  const _GameCardList({required this.cards});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (_, index) => _GameCard(
          key: ValueKey(cards[index].quizId),
          quizId: cards[index].quizId,
          gradientColors: _HomeScreenState._cardAssets.gradientColors[index],
          img: _HomeScreenState._cardAssets.imagePaths[index],
          angle: _HomeScreenState._cardAssets.angles[index],
          width: _HomeScreenState._cardAssets.sizes[index],
        ),
        childCount: cards.length,
      ),
    );
  }
}

/// карточка квиза
class _GameCard extends StatelessWidget {
  final int quizId;
  final List<Color> gradientColors;
  final String img;
  final double angle;
  final double width;

  const _GameCard({
    super.key,
    required this.quizId,
    required this.gradientColors,
    required this.img,
    required this.angle,
    required this.width,
  });

  /// метод для перехода на страницу по ее state
  ///
  /// если карточка еще не открыта, ее пройти нельзя
  void _handleCardTap(BuildContext context, QuizCards card) {
    if (card.state == 1 || card.state == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => card.title.split(' ')[0] == "Квиз"
              ? QuizScreen(title: card.title, id: card.quizId)
              : StoryScreen(title: card.title, id: card.quizId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<QuizCardsProvider, QuizCards>(
      selector: (_, provider) => provider.cards.firstWhere((c) => c.quizId == quizId),
      builder: (context, card, _) {
        return  RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 20),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _handleCardTap(context, card),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 168,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(colors: gradientColors),
                      ),
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 24, top: 16, right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.title, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(card.subtitle, style: Theme.of(context).textTheme.titleLarge),
                              SvgPicture.asset(
                                _getStatusIconPath(card.state),
                                width: 44,
                                height: 44,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: -55,
                      child: Transform.rotate(
                        angle: angle,
                        child: DelayLoadingImage(imagePath: img, width: width, height: null, delay: 300),
                        //Image.asset(img, width: width, fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// получение статуса карточки (иконка)
  String _getStatusIconPath(int state) {
    return switch (state) {
      0 => 'assets/icons/ic_status_block.svg',
      1 => 'assets/icons/ic_status_open.svg',
      2 => 'assets/icons/ic_status_complete.svg',
      _ => 'assets/icons/ic_status_block.svg',
    };
  }
}

/// подвал списка
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Скоро заданий будет ещё больше',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontSize: 20),
    );
  }
}