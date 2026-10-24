import 'package:lengoal/features/practice/presentation/models/practice_question.dart';

enum PracticeTopicStatus { notStarted, inProgress, completed }

class PracticeTopic {
  const new({
    required this.title,
    required this.solvedCount,
    required this.totalCount,
    required this.status,
    this.scorePercent,
    this.questions = mockPracticeQuestions,
    this.answers = const {},
    this.isMock = false,
  });

  final String title;
  final int solvedCount;
  final int totalCount;
  final PracticeTopicStatus status;
  final int? scorePercent;
  final List<PracticeQuestion> questions;
  final Map<int, int> answers;
  final bool isMock;
}

class PracticeSubject {
  const new({
    required this.title,
    required this.solvedCount,
    required this.totalCount,
    required this.progressPercent,
    required this.topics,
  });

  final String title;
  final int solvedCount;
  final int totalCount;
  final int progressPercent;
  final List<PracticeTopic> topics;
}

const mockPracticeSubjects = [
  PracticeSubject(
    title: 'Anatomy',
    solvedCount: 200,
    totalCount: 559,
    progressPercent: 50,
    topics: [
      PracticeTopic(
        title: 'Gross Anatomy',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.completed,
        scorePercent: 80,
        answers: {0: 2, 1: 1, 2: 0, 3: 1, 4: 1},
      ),
      PracticeTopic(
        title: 'Histology',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.inProgress,
        answers: {0: 2, 1: 1},
      ),
      PracticeTopic(
        title: 'Embryology',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
      PracticeTopic(
        title: 'Surface Anatomy',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
    ],
  ),
  PracticeSubject(
    title: 'Physiology',
    solvedCount: 180,
    totalCount: 420,
    progressPercent: 50,
    topics: [
      PracticeTopic(
        title: 'Cell Physiology',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
      PracticeTopic(
        title: 'Cardiovascular Physiology',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
      PracticeTopic(
        title: 'Respiratory Physiology',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
    ],
  ),
  PracticeSubject(
    title: 'Biochemistry',
    solvedCount: 96,
    totalCount: 310,
    progressPercent: 31,
    topics: [
      PracticeTopic(
        title: 'Enzymes',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
      PracticeTopic(
        title: 'Metabolism',
        solvedCount: 20,
        totalCount: 42,
        status: PracticeTopicStatus.notStarted,
      ),
    ],
  ),
];

const mockPracticeMockSubjects = [
  PracticeSubject(
    title: 'Mock Exam 1',
    solvedCount: 40,
    totalCount: 120,
    progressPercent: 33,
    topics: [
      PracticeTopic(
        title: 'Paper A',
        solvedCount: 20,
        totalCount: 60,
        status: PracticeTopicStatus.notStarted,
      ),
      PracticeTopic(
        title: 'Paper B',
        solvedCount: 20,
        totalCount: 60,
        status: PracticeTopicStatus.notStarted,
      ),
    ],
  ),
  PracticeSubject(
    title: 'Mock Exam 2',
    solvedCount: 0,
    totalCount: 120,
    progressPercent: 0,
    topics: [
      PracticeTopic(
        title: 'Paper A',
        solvedCount: 0,
        totalCount: 60,
        status: PracticeTopicStatus.notStarted,
      ),
      PracticeTopic(
        title: 'Paper B',
        solvedCount: 0,
        totalCount: 60,
        status: PracticeTopicStatus.notStarted,
      ),
    ],
  ),
];
