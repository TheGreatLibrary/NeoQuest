import 'dart:convert';
import 'dart:math';

class Question {
  final int id;
  final int quizId;
  final String question;
  final List<String> answers;
  final String correctAnswer;

  Question(
      {
        required this.id,
        required this.quizId,
        required this.question,
        required this.answers,
        required this.correctAnswer
      });

  factory Question.fromMap(Map<String, dynamic> map) {
    final shuffledOptions = shuffleOptions(map['answers']);
    return Question(
      id: map['id'] as int,
      quizId: map['quiz_id'] as int,
      question: map['question'] as String,
      answers: shuffledOptions,
      correctAnswer: map['correct_answer'] as String,
    );
  }

  static List<String> shuffleOptions(String jsonOptions) {
    List<String> options = List<String>.from(json.decode(jsonOptions));
    options.shuffle(Random());
    return options;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question': question,
      'answers': jsonEncode(answers),
      'correct_answer': correctAnswer
    };
  }
}