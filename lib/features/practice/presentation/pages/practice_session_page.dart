import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_question_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_question_palette.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_timer_card.dart';

class PracticeSessionPage extends StatefulWidget {
  const new({required this.topic, super.key});

  final PracticeTopic topic;

  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  late final Map<int, int> _answers = Map<int, int>.from(widget.topic.answers);
  late final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  Duration _remaining = const Duration(hours: 1, minutes: 3, seconds: 22);
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

  Future<void> _confirmSubmit() async {
    AppHaptics.selection();
    final confirmed = await AppConfirmDialog.show(
      context,
      title: context.l10n.practiceSubmitDialogTitle,
      body: context.l10n.practiceSubmitDialogBody,
      warning: context.l10n.practiceSubmitDialogWarning,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.practiceSubmit,
    );
    if (!(confirmed ?? false) || !mounted) return;
    AppHaptics.success();
    context.pushReplacementNamed(
      RouteNames.practiceReview,
      extra: (
        topic: PracticeTopic(
          title: widget.topic.title,
          solvedCount: widget.topic.solvedCount,
          totalCount: widget.topic.totalCount,
          status: PracticeTopicStatus.completed,
          questions: widget.topic.questions,
          answers: Map<int, int>.from(_answers),
        ),
        startIndex: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.topic.questions;

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
                  Entrance(child: PracticeTimerCard(remaining: _remaining)),
                  const Gap(AppSpacing.s16),
                  Entrance(
                    index: 1,
                    child: PracticeQuestionCard(
                      number: _currentIndex + 1,
                      question: questions[_currentIndex],
                      selectedOption: _answers[_currentIndex],
                      onSelect: (option) =>
                          setState(() => _answers[_currentIndex] = option),
                      onSave: () {
                        AppHaptics.selection();
                        AppSnackbar.success(context.l10n.practiceAnswerSaved);
                      },
                      onPrevious: _currentIndex == 0
                          ? null
                          : () => _goTo(_currentIndex - 1),
                      onNext: _currentIndex == questions.length - 1
                          ? null
                          : () => _goTo(_currentIndex + 1),
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  Entrance(
                    index: 2,
                    child: PracticeQuestionPalette(
                      count: questions.length,
                      currentIndex: _currentIndex,
                      answeredIndexes: _answers.keys.toSet(),
                      onSelect: _goTo,
                    ),
                  ),
                  const Gap(AppSpacing.s24),
                  AppButton(
                    label: context.l10n.practiceSubmit,
                    onPressed: _confirmSubmit,
                  ),
                  const Gap(AppSpacing.s16),
                  AppButton(
                    label: context.l10n.practiceSaveAndContinueLater,
                    isOutlined: true,
                    foregroundColor: AppColors.brandPrimary,
                    onPressed: () {
                      AppHaptics.selection();
                      context.pop();
                    },
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
