import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_question.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_session.dart';

class QuizTakingPage extends StatefulWidget {
  const new({required this.session, super.key});

  final QuizSession session;

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  final Map<int, int> _answers = {};
  int _currentIndex = 0;
  late Duration _remaining = widget.session.totalDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= Duration.zero) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectOption(int optionIndex) {
    AppHaptics.selection();
    setState(() => _answers[_currentIndex] = optionIndex);
  }

  void _goTo(int index) {
    AppHaptics.selection();
    setState(() => _currentIndex = index);
  }

  Future<void> _confirmSubmit() async {
    AppHaptics.selection();
    final unanswered = widget.session.questions.length - _answers.length;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: context.l10n.quizSubmitDialogTitle,
      body: context.l10n.quizSubmitDialogUnanswered(unanswered),
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.quizSubmit,
    );
    if (confirmed ?? false) {
      if (!mounted) return;
      context.pushReplacementNamed(
        RouteNames.quizResults,
        extra: (session: widget.session, answers: Map<int, int>.from(_answers)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.session.questions;
    final question = questions[_currentIndex];

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
              _TimeCard(remaining: _remaining),
              const Gap(AppSpacing.s16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _QuestionCard(
                        index: _currentIndex,
                        question: question,
                        selectedOption: _answers[_currentIndex],
                        onSelect: _selectOption,
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
                                  : () => _goTo(_currentIndex - 1),
                            ),
                          ),
                          const Gap(AppSpacing.s8),
                          Expanded(
                            child: AppButton(
                              label: context.l10n.quizNext,
                              onPressed: _currentIndex == questions.length - 1
                                  ? null
                                  : () => _goTo(_currentIndex + 1),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.s24),
                      Text(
                        context.l10n.quizQuestionsPalette,
                        style: context.textTheme.titleLarge,
                      ),
                      const Gap(AppSpacing.s8),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          for (var i = 0; i < questions.length; i++)
                            _QuestionChip(
                              number: i + 1,
                              isCurrent: i == _currentIndex,
                              isAnswered: _answers.containsKey(i),
                              onTap: () => _goTo(i),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.s16),
              AppButton(
                label: context.l10n.quizSubmit,
                onPressed: _confirmSubmit,
              ),
              const Gap(AppSpacing.s8),
              AppButton(
                label: context.l10n.quizSaveForLater,
                isOutlined: true,
                onPressed: () {
                  AppHaptics.selection();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const new({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.quizTimeRemaining,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const Gap(AppSpacing.s4),
          Text(
            '${hours.toString().padLeft(2, '0')}hr:'
            '${minutes.toString().padLeft(2, '0')}mins:'
            '${seconds.toString().padLeft(2, '0')}secs',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const new({
    required this.index,
    required this.question,
    required this.selectedOption,
    required this.onSelect,
  });

  final int index;
  final QuizQuestion question;
  final int? selectedOption;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              '${index + 1}. ${question.text}',
              style: context.textTheme.bodyLarge,
            ),
            const Gap(AppSpacing.s16),
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: _OptionTile(
                  letter: String.fromCharCode(65 + i),
                  label: question.options[i],
                  isSelected: selectedOption == i,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const new({
    required this.letter,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            border: Border.all(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.06)
                : null,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected
                    ? context.colors.primary
                    : context.colors.surfaceContainerHighest,
                foregroundColor: isSelected
                    ? Colors.white
                    : context.colors.onSurfaceVariant,
                child: Text(
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
        ),
      ),
    );
  }
}

class _QuestionChip extends StatelessWidget {
  const new({
    required this.number,
    required this.isCurrent,
    required this.isAnswered,
    required this.onTap,
  });

  final int number;
  final bool isCurrent;
  final bool isAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isCurrent
        ? context.colors.primary
        : isAnswered
        ? context.colors.primary.withValues(alpha: 0.12)
        : Colors.transparent;
    final foreground = isCurrent
        ? Colors.white
        : isAnswered
        ? context.colors.primary
        : context.colors.onSurfaceVariant;

    return Pressable(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            border: Border.all(
              color: isCurrent
                  ? context.colors.primary
                  : context.colors.outlineVariant,
            ),
          ),
          child: Text(
            '$number',
            style: context.textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
