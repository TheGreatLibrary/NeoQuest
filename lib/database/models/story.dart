class Story {
  final int id;
  final int quizId;
  final String text;
  final String? choices;

  Story({
    required this.id,
    required this.quizId,
    required this.text,
    this.choices,
  });

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
        id: map['id'] as int,
        quizId: map['quiz_id'] as int,
        text: map['text'] as String,
        choices: map['choices'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'text': text,
      'choices': choices,
    };
  }

  Story copyWith({
    int? id,
    int? quizId,
    String? text,
    String? choices,
  }) {
    return Story(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      text: text ?? this.text,
      choices: choices ?? this.choices,
    );
  }
}
