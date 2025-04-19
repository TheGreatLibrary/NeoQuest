import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'count_monet.dart';

/// модернизированный scaffold
///
/// используется почти на всех страницах.
/// есть вариации со стрелочкой и заголовком и без
class BaseScaffold extends StatelessWidget {
  final Widget body;
  final bool showLeading;
  final String? title;

  const BaseScaffold(
      {super.key, required this.body, required this.showLeading, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: showLeading
            ? IconButton(
                icon: SvgPicture.asset('assets/icons/ic_arrow.svg',
                    width: 32, height: 32),
                onPressed: () => Navigator.pop(context))
            : null,
        title: title != null
            ? Text(
                title!,
                textAlign: TextAlign.center,
              )
            : null,
        actions: const [
          CountMonet(),
        ],
      ),
      body: body,
    );
  }
}
