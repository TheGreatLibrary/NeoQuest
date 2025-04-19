import 'package:flutter/material.dart';

/// картинка с заданной задержкой плавного проявления для красивого эффекта
class DelayLoadingImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final int delay;
  final ValueKey? valueKey;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;

  const DelayLoadingImage(
      {super.key,
      required this.imagePath,
      this.width,
      this.height,
      required this.delay,
      this.valueKey,
      this.cacheWidth,
      this.cacheHeight,
      this.fit = BoxFit.cover});

  @override
  _DelayLoadingImageState createState() => _DelayLoadingImageState();
}

class _DelayLoadingImageState extends State<DelayLoadingImage> {
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _isImageLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isImageLoaded ? 1.0 : 0.0,
      duration: Duration(milliseconds: widget.delay),
      curve: Curves.easeIn,
      child: Image.asset(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        key: widget.valueKey,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        fit: widget.fit,
      ),
    );
  }
}
