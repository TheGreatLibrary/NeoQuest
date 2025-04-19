import 'package:flutter/material.dart';
import 'package:neoflex_quiz/widgets/constrained_box.dart';

/// уведомление о получении достижения
///
/// показывается поверх всего с возможность свапнуть в бок и перейти по нажатию
class CustomTopDialog extends StatefulWidget {
  final String text;
  final OverlayEntry entry;
  final Widget? routeWidget;

  const CustomTopDialog({super.key, required this.text, required this.entry, required this.routeWidget});


  static void show(BuildContext context, String text, Widget? routeWidget) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => CustomTopDialog(text: text, entry: entry, routeWidget: routeWidget),
    );

    overlay.insert(entry);
  }

  @override
  State<CustomTopDialog> createState() => _CustomTopDialogState();
}

class _CustomTopDialogState extends State<CustomTopDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  bool _isClosed = false;


  /// инициализация данных по анимации
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Автоматическое скрытие через 2 секунды
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isClosed && mounted) {
        _controller.reverse().then((_) => _close());
      }
    });
  }

  void _close() {
    if (!_isClosed) {
      _isClosed = true;
      widget.entry.remove();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: const Key('top_dialog'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) {
                if (!_isClosed) {
                  _controller.reverse().then((_) => _close());
                }
              },
              child: GestureDetector(
                onTap: () {
                  widget.routeWidget != null ?
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => widget.routeWidget!),
                  ) : null;
                  _controller.reverse().then((_) => _close());
                },
                child: CustomConstrainedBox(
                  child: Container(
                    height: 68,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
