import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Для проверки платформы
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:neoflex_quiz/main_page.dart';
import 'package:neoflex_quiz/providers/onboarding_provider.dart';
import 'package:neoflex_quiz/screens/onboarding_screen.dart';

import 'package:provider/provider.dart';
import 'database/data_based_helper.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  bool isRegistered = await DatabaseHelper().isUserRegistered();

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AccountProvider()),
          ChangeNotifierProvider(create: (context) => CoinProvider()..updateCoins()),
          ChangeNotifierProvider(
              create: (context) => OrdersProvider(
                  updateCoins: () =>
                      Provider.of<CoinProvider>(context, listen: false)
                          .updateCoins())),
          ChangeNotifierProvider(create: (context) => AchievementProvider()),

          ChangeNotifierProvider(create: (context) => SelectedIndexPage()),


          ChangeNotifierProvider(create: (context) => QuizCardsProvider()),
          ChangeNotifierProvider(create: (context) => ProductProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider()),
    ], child: NeoflexQuizApp(isRegistered: isRegistered)),
  );
}

class NeoflexQuizApp extends StatelessWidget {
  final bool isRegistered;

  const NeoflexQuizApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'Nunito',
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFFFF),
            titleTextStyle: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 20,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
            // заголовки страниц
            displayMedium: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.10,
            ),
            // заголовок onboard
            displaySmall: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.10,
            ),
            // заголовок диалога
            titleLarge: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 0.79,
            ),
            // заголовок карточки
            titleMedium: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 0.92,
            ),
            // заголовок вопроса
            bodyLarge: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.10,
            ),
            // основой текст вопросов и онборда
            headlineMedium: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
              height: 1.38,
            ),
            // подпись карточек


            headlineLarge: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.10,
            ),
            // ответы и диалог истории


            labelLarge: TextStyle(
              color: Color(0xFF2C2A2E),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.22,
            ),
            // цифра рядом с монетой


            labelMedium: TextStyle(
              color: Color(0xFF585858),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.20,
            ),
            // дата в заказе


            titleSmall: TextStyle(
              color: Color(0xFF2C2B2F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.10,
            ),
            // заголовок товара (NEO)
            bodyMedium: TextStyle(
              color: Color(0xFF2C2B2F),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
            // подпись заголовков страниц
            bodySmall: TextStyle(
              color: Color(0xFF2C2B2F),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.10,
            ),
            // текст диалога
            headlineSmall: TextStyle(
              color: Color(0xFF2C2B2F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.38,
            ),
            // заголовок корзины товара
            labelSmall: TextStyle(
              color: Color(0xFF2C2B2F),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.20,
            ),
            // текст достижения
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.10,
            )),
          ),
          progressIndicatorTheme:
              const ProgressIndicatorThemeData(color: Color(0xFFE8772F))),
      home: isRegistered ? MainPage() : ChangeNotifierProvider(
        create: (_) => OnboardingProvider(),
    child: const OnboardingScreen(),
    ),
      debugShowCheckedModeBanner: false,
    );
  }
}
