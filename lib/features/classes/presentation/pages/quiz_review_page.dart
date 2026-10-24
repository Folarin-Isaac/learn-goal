import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_session.dart';

class QuizReviewPage extends StatefulWidget {
  const new({
    required this.session,
    required this.answers,
    this.startIndex = 0,
    super.key,
  });

  final QuizSession session;
  final Map<int, int> answers;
  final int startIndex;

  @override
  State<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends State<QuizReviewPage> {
  late int _currentIndex = widget.startIndex;

  @override
  Widget build(BuildContext context) {
    final questions = widget.session.questions;
    final question = questions[_currentIndex];
    final selectedOption = widget.answers[_currentIndex];
    final isCorrect = selectedOption == question.correctOptionIndex;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      context.l10n.classDetailsTabQuiz,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.s16),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentIndex + 1}. ${question.text}',
                            style: context.textTheme.bodyLarge,
                          ),
                          const Gap(AppSpacing.s16),
                          for (var i = 0; i < question.options.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s8,
                              ),
                              child: _ReviewOptionTile(
                                letter: String.fromCharCode(65 + i),
                                label: question.options[i],
                                isCorrectOption:
                                    i == question.correctOptionIndex,
                                isUserWrongPick:
                                    i == selectedOption && !isCorrect,
                              ),
                            ),
                          const Gap(AppSpacing.s8),
                          _SolutionPanel(
                            isCorrect: isCorrect,
                            answer:
                                question.options[question.correctOptionIndex],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.s16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.l10n.quizPrevious,
                      isOutlined: true,
                      onPressed: _currentIndex == 0
                          ? null
                          : () {
                              AppHaptics.selection();
                              setState(() => _currentIndex--);
                            },
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: AppButton(
                      label: context.l10n.quizNext,
                      onPressed: _currentIndex == questions.length - 1
                          ? null
                          : () {
                              AppHaptics.selection();
                              setState(() => _currentIndex++);
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewOptionTile extends StatelessWidget {
  const new({
    required this.letter,
    required this.label,
    required this.isCorrectOption,
    required this.isUserWrongPick,
  });

  final String letter;
  final String label;
  final bool isCorrectOption;
  final bool isUserWrongPick;

  @override
  Widget build(BuildContext context) {
    final color = isCorrectOption
        ? const Color(0xFF0E8C43)
        : isUserWrongPick
        ? Colors.red
        : context.colors.outlineVariant;
    final isHighlighted = isCorrectOption || isUserWrongPick;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(color: color, width: isHighlighted ? 2 : 1),
        color: isHighlighted ? color.withValues(alpha: 0.08) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isHighlighted
                ? color
                : context.colors.surfaceContainerHighest,
            foregroundColor: isHighlighted
                ? Colors.white
                : context.colors.onSurfaceVariant,
            child: isHighlighted
                ? Icon(
                    isCorrectOption ? Icons.check_rounded : Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  )
                : Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const Gap(AppSpacing.s8),
          Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SolutionPanel extends StatelessWidget {
  const new({required this.isCorrect, required this.answer});

  final bool isCorrect;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF0E8C43) : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 18,
              ),
              const Gap(AppSpacing.s4),
              Text(
                context.l10n.quizReviewSolution,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.s4),
          Text(
            context.l10n.quizReviewCorrectAnswer(answer),
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
