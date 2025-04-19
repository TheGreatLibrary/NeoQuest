class QuizCards {
  final int quizId;
  final String title;
  final String subtitle;
  final int state; // 1 - закрыто, 2 - открыто, 3 - выполнено
  final int sumPrice;

  QuizCards({
    required this.quizId,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.sumPrice
  });

  factory QuizCards.fromMap(Map<String, dynamic> map) {
    return QuizCards(
      quizId: map['quiz_id'] as int,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      state: map['state'] as int,
      sumPrice: map['sum_price'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quiz_id': quizId,
      'title': title,
      'subtitle': subtitle,
      'state': state,
      'sum_price': sumPrice,
    };
  }

  QuizCards copyWith({int? quizId, String? title, String? subtitle, int? state, int? sumPrice}) {
    return QuizCards(
      quizId: quizId ?? this.quizId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      state: state ?? this.state,
      sumPrice: sumPrice ?? this.sumPrice
    );
  }
}