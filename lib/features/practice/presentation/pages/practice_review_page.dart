import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_question_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_question_palette.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_solution_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_timer_card.dart';

class PracticeReviewPage extends StatefulWidget {
  const new({required this.topic, required this.startIndex, super.key});

  final PracticeTopic topic;
  final int startIndex;

  @override
  State<PracticeReviewPage> createState() => _PracticeReviewPageState();
}

class _PracticeReviewPageState extends State<PracticeReviewPage> {
  late final ScrollController _scrollController = ScrollController();
  late int _currentIndex = widget.startIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _currentIndex = index);
    _scrollController.animateTo(
      0,
      duration: AppMotion.base,
      curve: AppMotion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.topic.questions;
    final question = questions[_currentIndex];
    final selected = widget.topic.answers[_currentIndex];
    final isCorrect = selected == question.correctOptionIndex;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: context.colors.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s24,
                AppSpacing.s16,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      widget.topic.title,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  const Entrance(
                    child: PracticeTimerCard(
                      remaining: Duration(hours: 1, minutes: 3, seconds: 22),
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  Entrance(
                    index: 1,
                    child: PracticeQuestionCard(
                      number: _currentIndex + 1,
                      question: question,
                      selectedOption: selected,
                      revealAnswer: true,
                      onPrevious: _currentIndex == 0
                          ? null
                          : () => _goTo(_currentIndex - 1),
                      onNext: _currentIndex == questions.length - 1
                          ? null
                          : () => _goTo(_currentIndex + 1),
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  if (selected != null)
                    Entrance(
                      index: 2,
                      child: PracticeSolutionCard(
                        question: question,
                        isCorrect: isCorrect,
                      ),
                    ),
                  const Gap(AppSpacing.s16),
                  Entrance(
                    index: 3,
                    child: PracticeQuestionPalette(
                      count: questions.length,
                      currentIndex: _currentIndex,
                      answeredIndexes: widget.topic.answers.keys.toSet(),
                      onSelect: _goTo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
