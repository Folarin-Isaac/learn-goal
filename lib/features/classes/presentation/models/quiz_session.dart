import 'package:lengoal/features/classes/presentation/models/quiz_question.dart';

class QuizSession {
  const new({
    required this.title,
    required this.instructions,
    required this.minutesPerQuestion,
    required this.passPercent,
    required this.questions,
  });

  final String title;
  final List<String> instructions;
  final int minutesPerQuestion;
  final int passPercent;
  final List<QuizQuestion> questions;

  int get questionCount => questions.length;
  Duration get totalDuration =>
      Duration(minutes: minutesPerQuestion * questions.length);
}

const mockQuizSession = QuizSession(
  title: 'Anatomy Quiz',
  instructions: [
    'Find a quiet space with a stable internet connection before you begin.',
    'Each question has only one correct answer — pick the best option.',
    'You can move between questions and change your answers until you submit.',
  ],
  minutesPerQuestion: 2,
  passPercent: 70,
  questions: [
    QuizQuestion(
      text: 'Which bone is also known as the shoulder blade?',
      options: ['Clavicle', 'Scapula', 'Humerus', 'Sternum'],
      correctOptionIndex: 1,
    ),
    QuizQuestion(
      text: 'The axial skeleton includes all of the following except:',
      options: ['Skull', 'Vertebral column', 'Pelvic girdle', 'Ribs'],
      correctOptionIndex: 2,
    ),
    QuizQuestion(
      text: 'What is the primary function of bone marrow?',
      options: [
        'Produces blood cells',
        'Stores fat only',
        'Produces hormones',
        'Protects the brain',
      ],
      correctOptionIndex: 0,
    ),
    QuizQuestion(
      text: 'Which part of the skeleton facilitates limb movement?',
      options: [
        'Axial skeleton',
        'Appendicular skeleton',
        'Cranial skeleton',
        'Thoracic cage',
      ],
      correctOptionIndex: 1,
    ),
    QuizQuestion(
      text: 'The skull and ribs belong to which skeletal division?',
      options: [
        'Appendicular skeleton',
        'Peripheral skeleton',
        'Axial skeleton',
        'Girdle skeleton',
      ],
      correctOptionIndex: 2,
    ),
  ],
);
