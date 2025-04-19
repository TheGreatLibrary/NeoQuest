import 'package:flutter/material.dart';
import 'package:neoflex_quiz/widgets/base_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "О приложении",
      showLeading: true,
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NeoQuest приветствует вас и искренне благодарит за установку. Мы надеемся, что прохождение квизов доставит вам радость и немного вдохновения.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Это прекрасное приложение создано усилиями всего двух человек:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                '— дизайнер 1 штука',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '— кодер 1 штука',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Над визуальной частью и подбором содержимого работал ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextSpan(
                        text: '*&(!!!@#>><?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    TextSpan(
                      text: ' — талантливый дизайнер.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Над кодосодержащим продуктом пыхтел ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextSpan(
                        text: '%!#??*&!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    TextSpan(
                      text: ' — фанатик программирования.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Версия приложения: 1.0 beta',
                style: Theme.of(context).textTheme.labelMedium
              )
            ],
          )
      ),
    );
  }
}