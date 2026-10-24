import 'package:lengoal/features/classes/presentation/models/quiz_session.dart';

enum QuizStatus { completed, pending }

class ClassQuiz {
  const new({
    required this.title,
    required this.dueDate,
    required this.status,
    required this.instructorName,
    this.session = mockQuizSession,
  });

  final String title;
  final String dueDate;
  final QuizStatus status;
  final String instructorName;
  final QuizSession session;
}
