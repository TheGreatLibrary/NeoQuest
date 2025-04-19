import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:neoflex_quiz/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../database/models/story.dart';
import '../providers/story_provider.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/delay_loading_image.dart';

class StoryScreen extends StatelessWidget {
  final int id;
  final String title;

  const StoryScreen({required this.title, required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        title: title,
        showLeading: true,
        body: Container(
            color: title.split(' ')[1] == "1"
                ? Color(0xFF898A85)
                : title.split(' ')[1] == "2"
                    ? Color(0xFFE3E3E1)
                    : Color(0xFF919694),
            child: Stack(
              children: [
                Positioned.fill(
                  child: title.split(' ')[1] == "1"
                      ? DelayLoadingImage(
                          imagePath: "assets/image/bg_story1.webp",
                          width: null,
                          height: null,
                          delay: 300)
                      : title.split(' ')[1] == "2"
                          ? DelayLoadingImage(
                              imagePath: "assets/image/bg_story2.webp",
                              width: null,
                              height: null,
                              delay: 300)
                          : DelayLoadingImage(
                              imagePath: "assets/image/bg_story3.webp",
                              width: null,
                              height: null,
                              delay: 300),
                ),
                Stack(
                  children: [
                    const Positioned(
                      right: 0,
                      top: 0,
                      left: 0,
                      bottom: 150,
                      child: Center(
                        child: _FloatingRobot(),
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => StoryProvider(id, title),
                      child: Consumer<StoryProvider>(
                          builder: (context, provider, child) {
                        return provider.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : provider.stories.isEmpty
                                ? SizedBox()
                                : PageView.builder(
                                    controller: provider.pageController,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: provider.stories.length,
                                    itemBuilder: (context, index) {
                                      return _StoryPage(
                                        story: provider.stories[index],
                                        onNext: () async =>
                                            await provider.nextDialog(context),
                                      );
                                    },
                                  );
                      }),
                    ),
                  ],
                ),
              ],
            )));
  }
}

class _StoryPage extends StatelessWidget {
  final Story story;
  final VoidCallback onNext;

  const _StoryPage({required this.story, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: story.choices == null ? () => onNext() : null,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                      height: MediaQuery.of(context).size.height / 2.2,
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 16, bottom: 24),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Нео ',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 16),
                                width: double.infinity,
                                decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                      color: Color(0xFFD1005B),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      story.text,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                      speed: const Duration(milliseconds: 40),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                  displayFullTextOnTap: true,
                                  isRepeatingAnimation: false,
                                ),
                              ),
                            ],
                          ),
                          if (story.choices != null)
                            GradientButton(
                                onPressed: () => onNext(),
                                buttonText: story.choices!,
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFD1005B),
                                  Color(0xFFE8772F)
                                ])),
                        ],
                      ))),
            ),
          ],
        ));
  }
}

class _FloatingRobot extends StatefulWidget {
  const _FloatingRobot();

  @override
  _FloatingRobotState createState() => _FloatingRobotState();
}

class _FloatingRobotState extends State<_FloatingRobot> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  late final AnimationController _swayController;
  late final Animation<double> _swayAnimation;

  late final AnimationController _tiltController;
  late final Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(seconds: 2, milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -2, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _swayController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _swayAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );

    _tiltController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _tiltAnimation = Tween<double>(begin: -0.001, end: 0.001).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _swayController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _swayController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_swayAnimation.value, -_floatAnimation.value),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(_tiltAnimation.value),
            child: child,
          ),
        );
      },
      child: Image.asset(
        "assets/image/robot.png",
        height: 230,
        fit: BoxFit.contain,
      ),
    );
  }
}


// неудовлетворительный эксперимент с заменой анимации на webp анимацию. слишком много весит при таком качестве
// class RobotRecorderWebP extends StatefulWidget {
//   const RobotRecorderWebP({super.key});
//
//   @override
//   State<RobotRecorderWebP> createState() => _RobotRecorderWebPState();
// }
//
// class _RobotRecorderWebPState extends State<RobotRecorderWebP> with TickerProviderStateMixin {
//   late final AnimationController _floatController;
//   late final Animation<double> _floatAnimation;
//
//   late final AnimationController _swayController;
//   late final Animation<double> _swayAnimation;
//
//   late final AnimationController _tiltController;
//   late final Animation<double> _tiltAnimation;
//
//
//   GlobalKey repaintKey = GlobalKey();
//
//   List<String> framePaths = [];
//   late Timer timer;
//   int frame = 0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _floatController = AnimationController(
//       duration: Duration(seconds: 2, milliseconds: 100),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _floatAnimation = Tween<double>(begin: -2, end: 6).animate(
//       CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
//     );
//
//     _swayController = AnimationController(
//       duration: Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _swayAnimation = Tween<double>(begin: -2, end: 2).animate(
//       CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
//     );
//
//     _tiltController = AnimationController(
//       duration: Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _tiltAnimation = Tween<double>(begin: -0.01, end: 0.01).animate(
//       CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
//     );
//
//     Future.delayed(Duration(milliseconds: 1), () => startCapturingFrames());
//   }
//
//   Future<void> startCapturingFrames() async {
//     final dir = await getTemporaryDirectory();
//
//     timer = Timer.periodic(Duration(milliseconds: 33), (_) async {
//       if (frame >= 200) {
//         timer.cancel();
//         await exportToWebP(dir.path);
//         return;
//       }
//
//       final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       final image = await boundary.toImage(pixelRatio: 1.0);
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       final pngBytes = byteData!.buffer.asUint8List();
//
//       final path = '${dir.path}/frame_${frame.toString().padLeft(3, '0')}.png';
//       await File(path).writeAsBytes(pngBytes);
//       framePaths.add(path);
//
//       frame++;
//     });
//   }
//
//   Future<void> exportToWebP(String dirPath) async {
//     final inputPattern = '$dirPath/frame_%03d.png';
//     final directory = await getApplicationDocumentsDirectory();
//
//
//     final outputPath = '${directory.path}/robot_animation.webp';
//     final command = '-framerate 30 -i $inputPattern -loop 0 $outputPath';
//
//     await FFmpegKit.execute(command);
//
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('✅ Анимация сохранена как WebP:\n$outputPath'),
//       duration: Duration(seconds: 5),
//     ));
//
//     print('✔ WebP создан по пути: $outputPath');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//         key: repaintKey,
//         child: AnimatedBuilder(
//       animation: Listenable.merge([_floatController, _swayController]),
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(_swayAnimation.value, -_floatAnimation.value),
//           child: Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()..rotateZ(_tiltAnimation.value),
//             child: child,
//           ),
//         );
//       },
//       child: Image.asset(
//         "assets/image/robot.png",
//         height: 1200,
//         fit: BoxFit.contain,
//       ),
//     )
//     );
//   }
//
//   @override
//   void dispose() {
//     _floatController.dispose();
//     _swayController.dispose();
//     _tiltController.dispose();
//     super.dispose();
//   }
// }
//