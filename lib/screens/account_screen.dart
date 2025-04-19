import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neoflex_quiz/providers/providers.dart';
import 'package:neoflex_quiz/screens/settings_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../widgets/shimmer_widget.dart';
import 'about_screen.dart';

/// виджет для страницы аккаунта
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  /// построение виджета из вспомогательных виджетов
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AccountProfile(),
            SizedBox(height: 28),
            _AccountStatistic(),
            SizedBox(height: 24),
            _AccountAchievements(),
            SizedBox(height: 16),
            _AccountSettings(),
            SizedBox(height: 112),
          ],
        ),
      ),
    );
  }
}

/// виджет с иконкой, именем и возрастом
class _AccountProfile extends StatelessWidget {
  const _AccountProfile();

  /// метод для склонения суффикса к возрасту в профиле
  String _ageWithSuffix(int age) {
    int lastDigit = age % 10;
    int lastTwoDigits = age % 100;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return '$age лет';
    }

    switch (lastDigit) {
      case 1:
        return '$age год';
      case 2:
      case 3:
      case 4:
        return '$age года';
      default:
        return '$age лет';
    }
  }

  @override
  Widget build(BuildContext context) {
    /// загрузка данных с провайдера
    return FutureBuilder(
      future: context.read<AccountProvider>().loadAccount(),
      builder: (context, snapshot) {
        /// пока данных нет - показывается загрушка шимммер
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AccountProfileShimmer();
        }

        final account = context.watch<AccountProvider>().account;

        /// отображает данные
        return Column(
          children: [
            const _AvatarPicker(),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                ).createShader(bounds);
              },
              child: Text(account.nickname,
                  style: Theme.of(context).textTheme.displaySmall),
            ),
            const SizedBox(height: 8),
            Text(_ageWithSuffix(account.age),
                style: Theme.of(context).textTheme.labelMedium),
          ],
        );
      },
    );
  }
}

/// класс для отрисовки аватара (иконки)
class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker();

  @override
  _AvatarPickerState createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  File? _image;

  /// иницализация данных
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// 1. считывает данные из провайдера для получения адреса картинки
  /// 2. если картинка есть - она загружается в переменную (адрес)
  Future<void> _loadImage() async {
    final provider = context.read<AccountProvider>();
    final path = provider.account.imagePath;
    if (path != null && File(path).existsSync()) {
      setState(() => _image = File(path));
    }
  }

  /// сохраняет картинку
  ///
  /// 1. Получаю доступ к провайдеру (аккаунту)
  /// 2. Создаю имя файла
  /// 3. Компрессирую фотографию для меньшего качества
  /// 4. Сохраняю фото в локальное хранилище
  /// 5. Обновляю переменную в бд
  Future<void> _pickImage() async {
    final provider = context.read<AccountProvider>();

    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.webp';
    final savedImagePath = '${directory.path}/$fileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      savedImagePath,
      quality: 90,
      minWidth: 256,
      minHeight: 256,
      format: CompressFormat.webp,
    );
    if (result == null) {
      return;
    }

    final oldImagePath = provider.account.imagePath;
    if (oldImagePath != null && File(oldImagePath).existsSync()) {
      await File(oldImagePath).delete();
    }

    provider.updateAccountFields(imagePath: result.path);
    setState(() => _image = File(result.path));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 140,
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: CircleAvatar(
                radius: 59,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                backgroundColor: const Color(0xFFD8D8D8),
                child: _image == null
                    ? Icon(Icons.person, size: 59, color: Color(0xFF9A9A9A))
                    : null,
              )),
          Positioned(
            left: 50,
            top: 108,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(5),
                width: 25,
                height: 25,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.50),
                    end: Alignment(1.00, 0.50),
                    colors: [const Color(0xFFD1005B), const Color(0xFFE8772F)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: SvgPicture.asset('assets/icons/change.svg',
                    width: 10,
                    height: 10,
                    colorFilter:
                    ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// виджет заглушка для профиля
class _AccountProfileShimmer extends StatelessWidget {
  const _AccountProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerWidget.circle(width: 118, height: 118),
        SizedBox(height: 8),
        ShimmerWidget.rectangular(height: 28, width: 160),
        SizedBox(height: 8),
        ShimmerWidget.rectangular(height: 18, width: 60),
      ],
    );
  }
}

/// виджет блок со статистикой
class _AccountStatistic extends StatelessWidget {
  const _AccountStatistic();

  @override
  Widget build(BuildContext context) {
    /// загрузка данных по статистике пройденных квизов и историй
    return FutureBuilder(
      future: context.read<AccountProvider>().loadQuizStatistic(),
      builder: (context, snapshot) {
        /// пока данных нет- заглушка
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AccountStatisticShimmer();
        }
        final stats = context.watch<AccountProvider>().quizStat;

        /// отображение контента
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 17,
          children: [
            _ContainerScope(scope: stats[0], description: "историй пройдено"),
            _ContainerScope(scope: stats[1], description: "квизов пройдено"),
          ],
        );
      },
    );
  }
}

/// виджет статистики
class _ContainerScope extends StatelessWidget {
  final int scope;
  final String description;

  const _ContainerScope(
      {required this.scope, required this.description});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFF585858),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Text(scope.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 32, height: 1)),
            Text(description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// виджет заглушка для статистики
class _AccountStatisticShimmer extends StatelessWidget {
  const _AccountStatisticShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 17,
        children: [
          Expanded(child: ShimmerWidget.rectangular(height: 110)),
          Expanded(child: ShimmerWidget.rectangular(height: 110)),
        ]);
  }
}

/// виджет с достижениями
class _AccountAchievements extends StatelessWidget {
  const _AccountAchievements();

  /// метод для получения нужного градиента по индексу
  static LinearGradient? _getGradientForIndex(int index, int status) {
    if (status != 1) return null;

    switch (index % 3) {
      case 0:
        return const LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
        );
      case 1:
        return const LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [Color(0xFF411485), Color(0xFF800F44)],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [Color(0xFFE0902C), Color(0xFFD1005B)],
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// загрузка данных по достижениям
    return FutureBuilder(
      future: context.read<AchievementProvider>().loadAchievements(),
      builder: (context, snapshot) {
        /// заглушка пока нет данных
        if (snapshot.connectionState != ConnectionState.done) {
          return const ShimmerWidget.rectangular(height: 150);
        }
        final achievements = context.watch<AchievementProvider>().achievements;

        /// постройка контента
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFF585858),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text('Достижения',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 20,
                  children: achievements.asMap().entries.map((entry) {
                    int index = entry.key;
                    var achievement = entry.value;
                    final gradient = _getGradientForIndex(index, achievement.status);

                    return _AchievementWidget(
                      image: achievement.image,
                      title: achievement.title,
                      gradient: achievement.status == 1 ? gradient : null,
                    );
                  }).toList(),
                )
              ],
            ));
      },
    );
  }
}

/// виджет достижения
class _AchievementWidget extends StatelessWidget {
  final String image;
  final String title;
  final LinearGradient? gradient;

  const _AchievementWidget(
      {required this.image,
        required this.title,
        required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          spacing: 8,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(
                gradient: gradient ??
                    LinearGradient(
                      colors: [const Color(0xFFF6F6F6), const Color(0xFFF6F6F6)],
                    ),
                shape: OvalBorder(),
              ),
              child: gradient != null
                  ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Image.asset(image, width: 48, height: 48))
                  : null,
            ),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall)
          ],
        ));
  }
}

/// виджет с основными настройками
class _AccountSettings extends StatelessWidget {
  const _AccountSettings();

  /// метод для отправки письма в техподдержку
  ///
  /// здесь происходит переход в приложение, если оно имеется на телефоне,
  /// а затем происходит ввод шаблона, который можно отредактировать и отправить.
  /// после отправки игрок возвращается назад в приложение.
  Future<void> _sendSupportEmail() async {
    final String subject =
        Uri.encodeComponent('Техподдержка: проблема с приложением');
    final String body = Uri.encodeComponent(
        'Здравствуйте, у меня возникла проблема с приложением...');

    final Uri emailUri = Uri.parse(
        'mailto:programming.creature@gmail.com?subject=$subject&body=$body');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Не удалось открыть почтовое приложение';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RowSettingWidget(
          prefixIcon: 'assets/icons/setting.svg',
          title: "Настройки профиля",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        _RowSettingWidget(
          prefixIcon: 'assets/icons/support.svg',
          title: "Написать в поддержку",
          onPressed: _sendSupportEmail,
        ),
        _RowSettingWidget(
          prefixIcon: 'assets/icons/about.svg',
          title: "О приложении",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
        _RowSettingWidget(
          prefixIcon: 'assets/icons/ic_terms.svg',
          title: "Условия использования",
          onPressed: () async {
            final url = Uri.parse('https://picnic-bk.ru/alex/neoflex_quiz/privacy_policy.html');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        _RowSettingWidget(
          prefixIcon: 'assets/icons/ic_policy.svg',
          title: "Политика конфиденциальности",
          onPressed: () async {
            final url = Uri.parse('https://picnic-bk.ru/alex/neoflex_quiz/terms_of_use.html');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ],
    );
  }
}

/// виджет строчки с настройками
class _RowSettingWidget extends StatelessWidget {
  final String prefixIcon;
  final String title;
  final VoidCallback onPressed;

  const _RowSettingWidget(
      {required this.prefixIcon,
      required this.title,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => onPressed(),
      splashColor: Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible( // или Expanded
              child: Row(
                children: [
                  SvgPicture.asset(prefixIcon, width: 32, height: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/arrow_forward.svg',
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}