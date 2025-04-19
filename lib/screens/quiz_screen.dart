import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neoflex_quiz/widgets/base_scaffold.dart';
import 'package:neoflex_quiz/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

import '../database/models/question.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatelessWidget {
  final String title;
  final int id;

  const QuizScreen({required this.title, required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: title,
      showLeading: true,
      body: ChangeNotifierProvider(
        create: (_) => QuizProvider(id, title),
        child: Consumer<QuizProvider>(builder: (context, provider, child) {
          return provider.isLoading
              ? const _QuestionShimmer()
              : provider.questions.isEmpty
                  ? const Center(child: Text('Нет вопросов'))
                  : PageView.builder(
                      controller: provider.pageController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: provider.questions.length,
                      itemBuilder: (context, index) {
                        return _QuestionWidget(
                          question: provider.questions[index],
                          index: index,
                          length: provider.questions.length - 1,
                          onAnswerSelected: (isCorrect) =>
                              provider.onAnswerSelected(isCorrect),
                          onNext: () async =>
                              await provider.nextQuestion(context),
                        );
                      },
                    );
        }),
      ),
    );
  }
}

class _QuestionWidget extends StatefulWidget {
  final Question question;
  final VoidCallback onNext;
  final Function(bool) onAnswerSelected;
  final int index;
  final int length;

  const _QuestionWidget({
    required this.question,
    required this.onNext,
    required this.onAnswerSelected,
    required this.index,
    required this.length,
  });

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<_QuestionWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(1.00, 0.00),
                          end: Alignment(-1, 0),
                          colors: [Color(0xFFD1005B), Color(0xFFE8772F)],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Вопрос ${widget.index + 1}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 0.6, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.question.question,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ...List.generate(widget.question.answers.length, (index) {
                      final answer = widget.question.answers[index];
                      final isCorrect = selectedIndex != null && answer == widget.question.correctAnswer;
                      final isWrong = selectedIndex != null && index == selectedIndex && answer != widget.question.correctAnswer;

                      return GestureDetector(
                        onTap: selectedIndex == null
                            ? () {
                          setState(() {
                            selectedIndex = index;
                          });
                          widget.onAnswerSelected(answer == widget.question.correctAnswer);
                        }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: ShapeDecoration(
                            color: isCorrect ? const Color(0xFFE1F9E5) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: isCorrect
                                    ? const Color(0xFF0BA928)
                                    : isWrong
                                    ? const Color(0xFFE8772F)
                                    : Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  answer,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: isCorrect
                                        ? const Color(0xFF0BA928)
                                        : isWrong
                                        ? const Color(0xFFE8772F)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isCorrect)
                               SvgPicture.asset('assets/icons/check.svg', width: 20, height: 20)
                              else if (isWrong)
                                SvgPicture.asset('assets/icons/x.svg', width: 20, height: 20)
                              else
                                const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    if (selectedIndex != null) ElevatedButton(
                          onPressed: widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8772F),
                            overlayColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(49)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child:
                              Text(
                                widget.length == widget.index
                                    ? "Завершить"
                                    : "Дальше",
                                style: Theme.of(context)
                                    .textButtonTheme
                                    .style
                                    ?.textStyle
                                    ?.resolve({}),
                              ),
                          )
                    else SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionShimmer extends StatelessWidget {
  const _QuestionShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(children: [
          const ShimmerWidget.rectangular(height: 155, borderRadius: 20),
          const SizedBox(height: 24),
          ...List.generate(
              4,
              (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child:
                      ShimmerWidget.rectangular(height: 55, borderRadius: 15)))
        ]));
  }
}