import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/goal_setup/goal_setup.dart';
import 'package:lengoal/features/goal_setup/presentation/bloc/active_goal/active_goal_cubit.dart';

class GoalStagePage extends StatefulWidget {
  const new({super.key});

  @override
  State<GoalStagePage> createState() => _GoalStagePageState();
}

class _GoalStagePageState extends State<GoalStagePage> {
  final _dateController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<GoalSetupBloc, GoalSetupState>(
      listenWhen: (previous, current) =>
          previous.saveStatus != current.saveStatus,
      listener: _onSaveStatus,
      builder: (context, state) {
        final category = state.selectedCategory;
        final goal = state.selectedGoal;
        final date = state.targetDate;
        final formatted = date == null ? '' : _dateFormat.format(date);
        if (_dateController.text != formatted) {
          _dateController.text = formatted;
        }
        return GoalStepLayout(
          step: 3,
          body: [
            Entrance(
              index: 1,
              child: Text(
                l10n.goalStageTitle,
                style: context.textTheme.headlineMedium,
              ),
            ),
            const Gap(AppSpacing.s8),
            if (category != null && goal != null)
              Entrance(
                index: 2,
                child: SelectionBreadcrumb(
                  crumbs: [category.name, goal.goalName],
                ),
              ),
            const Gap(AppSpacing.s4),
            if (goal != null)
              Entrance(
                index: 3,
                child: Text(
                  _prompt(context, goal),
                  style: context.textTheme.bodyMedium,
                ),
              ),
            const Gap(AppSpacing.s24),
            if (goal != null && _showsLevels(goal)) ...[
              GoalChoiceList.levels(
                levels: goal.levels,
                selectedLevelId: state.selectedLevelId,
                selectedSubjectIds: state.levelSubjectIds,
                onLevelTap: (id) =>
                    context.read<GoalSetupBloc>().add(GoalLevelTapped(id)),
                onSubjectToggle: (id) => context.read<GoalSetupBloc>().add(
                  GoalLevelSubjectToggled(id),
                ),
              ),
              const Gap(AppSpacing.s24),
            ] else if (goal != null && _showsSubjects(goal)) ...[
              GoalChoiceList.subjects(
                subjects: goal.subjects,
                selectedSubjectIds: state.subjectIds,
                onSubjectToggle: (id) =>
                    context.read<GoalSetupBloc>().add(GoalSubjectToggled(id)),
              ),
              const Gap(AppSpacing.s24),
            ],
            AppTextField(
              controller: _dateController,
              label: l10n.goalTargetDateLabel,
              hint: 'DD/MM/YYYY',
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(context, date),
            ),
          ],
          footer: [
            AppButton(
              label: l10n.goalSaveGoal,
              isLoading: state.saveStatus == GoalSaveStatus.saving,
              onPressed: !state.canSave
                  ? null
                  : () {
                      AppHaptics.selection();
                      context.read<GoalSetupBloc>().add(
                        const GoalSaveRequested(),
                      );
                    },
            ),
            if (getIt<AuthRepository>().needsGoalSetup) ...[
              const Gap(AppSpacing.s8),
              AppButton(
                label: l10n.goalSetupLater,
                isOutlined: true,
                foregroundColor: context.colors.primary,
                onPressed: state.saveStatus == GoalSaveStatus.saving
                    ? null
                    : () {
                        AppHaptics.selection();
                        unawaited(getIt<AuthRepository>().completeGoalSetup());
                        context.goNamed(RouteNames.explore);
                      },
              ),
            ],
          ],
        );
      },
    );
  }

  static bool _showsLevels(ExamGoal goal) =>
      goal.goalsHaveLevel && goal.levels.isNotEmpty;

  static bool _showsSubjects(ExamGoal goal) =>
      !_showsLevels(goal) && goal.goalsHaveSubject && goal.subjects.isNotEmpty;

  String _prompt(BuildContext context, ExamGoal goal) {
    final l10n = context.l10n;
    if (_showsLevels(goal)) return l10n.goalStageLevelPrompt(goal.goalName);
    if (_showsSubjects(goal)) {
      return l10n.goalStageSubjectPrompt(goal.goalName);
    }
    return l10n.goalStageSubtitle(goal.goalName);
  }

  void _onSaveStatus(BuildContext context, GoalSetupState state) {
    switch (state.saveStatus) {
      case GoalSaveStatus.failure:
        AppHaptics.error();
        AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
      case GoalSaveStatus.success:
        AppHaptics.success();
        AppSnackbar.success(context.l10n.goalCreated);
        unawaited(getIt<AuthRepository>().completeGoalSetup());
        unawaited(getIt<ActiveGoalCubit>().load());
        context.goNamed(RouteNames.explore);
      case GoalSaveStatus.initial:
      case GoalSaveStatus.saving:
        break;
    }
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && context.mounted) {
      AppHaptics.selection();
      context.read<GoalSetupBloc>().add(GoalTargetDateChanged(picked));
    }
  }
}
