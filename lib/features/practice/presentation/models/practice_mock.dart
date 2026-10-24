import 'package:lengoal/features/practice/presentation/models/practice_question.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';

class PracticeMockSession {
  const new({
    required this.title,
    required this.solvedCount,
    required this.totalCount,
    required this.isCompleted,
    this.questions = mockPracticeQuestions,
    this.answers = const {},
  });

  final String title;
  final int solvedCount;
  final int totalCount;
  final bool isCompleted;
  final List<PracticeQuestion> questions;
  final Map<int, int> answers;

  PracticeTopic toTopic() => PracticeTopic(
    title: title,
    solvedCount: solvedCount,
    totalCount: totalCount,
    status: isCompleted
        ? PracticeTopicStatus.completed
        : PracticeTopicStatus.notStarted,
    questions: questions,
    answers: answers,
    isMock: true,
  );
}

class PracticeMock {
  const new({
    required this.label,
    required this.title,
    required this.description,
    required this.instructions,
    required this.minutesPerQuestion,
    required this.passPercent,
    this.priceLabel,
    this.isPaid = false,
    this.sessions = const [],
    this.subjectGroups = const [],
  });

  final String label;
  final String title;
  final String description;
  final List<String> instructions;
  final int minutesPerQuestion;
  final int passPercent;
  final String? priceLabel;
  final bool isPaid;
  final List<PracticeMockSession> sessions;
  final List<PracticeSubject> subjectGroups;

  int get questionCount =>
      sessions.isNotEmpty ? sessions.first.questions.length : 50;
}

const _instructionSlip =
    'Two copies (printed) of your Jamb exam slip, one for yourself, the '
    'other for your invigilator respectively.';

const _instructionPencil =
    'Pencil/eraser: You might need to make sketches and erase a lot as the '
    'case may be.';

const _instructionCash =
    'Last but not the least, make sure you are with enough cash with you: '
    'This is not a requirement from Jamb but just incase of unforeseen '
    'circumstances, you would want to be prepared for eventualities.';

const List<String> _mockInstructions = [
  _instructionSlip,
  _instructionPencil,
  _instructionCash,
];

const _mockDescription =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
    'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
    'ad minim veniam';

const mockPracticeMocks = [
  PracticeMock(
    label: 'Mock 1',
    title: 'Introduction to Radiopharmacy',
    description: _mockDescription,
    instructions: _mockInstructions,
    minutesPerQuestion: 2,
    passPercent: 70,
    priceLabel: '₦35,000',
    isPaid: true,
    sessions: [
      PracticeMockSession(
        title: 'Morning session',
        solvedCount: 20,
        totalCount: 200,
        isCompleted: true,
        answers: {0: 2, 1: 1, 2: 0, 3: 1, 4: 1},
      ),
      PracticeMockSession(
        title: 'Afternoon session',
        solvedCount: 20,
        totalCount: 200,
        isCompleted: false,
      ),
    ],
  ),
  PracticeMock(
    label: 'Mock 2',
    title: 'Introduction to Radiopharmacy',
    description: _mockDescription,
    instructions: _mockInstructions,
    minutesPerQuestion: 2,
    passPercent: 70,
    priceLabel: '₦35,000',
    subjectGroups: [
      PracticeSubject(
        title: 'JAMB',
        solvedCount: 200,
        totalCount: 559,
        progressPercent: 36,
        topics: [
          PracticeTopic(
            title: 'English',
            solvedCount: 0,
            totalCount: 100,
            status: PracticeTopicStatus.notStarted,
            isMock: true,
          ),
          PracticeTopic(
            title: 'Physics',
            solvedCount: 0,
            totalCount: 100,
            status: PracticeTopicStatus.notStarted,
            isMock: true,
          ),
          PracticeTopic(
            title: 'Chemistry',
            solvedCount: 0,
            totalCount: 100,
            status: PracticeTopicStatus.notStarted,
            isMock: true,
          ),
          PracticeTopic(
            title: 'Biology',
            solvedCount: 0,
            totalCount: 100,
            status: PracticeTopicStatus.notStarted,
            isMock: true,
          ),
        ],
      ),
    ],
  ),
];
