import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/goal_setup/goal_setup.dart';

class GoalStagePage extends StatefulWidget {
  const new({super.key});

  @override
  State<GoalStagePage> createState() => _GoalStagePageState();
}

class _GoalStagePageState extends State<GoalStagePage> {
  final _dateController = TextEditingController();
  final _dateFormat = DateFormat('d MMMM y');

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Entrance(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBackButton(),
                    StepBadge(step: 3, totalSteps: 3),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              Entrance(
                index: 1,
                child: Text(
                  context.l10n.goalStageTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const Gap(AppSpacing.s8),
              Entrance(
                index: 2,
                child: BlocBuilder<GoalSetupBloc, GoalSetupState>(
                  buildWhen: (previous, current) =>
                      previous.selectedCategory != current.selectedCategory ||
                      previous.selectedGoal != current.selectedGoal,
                  builder: (context, state) {
                    final category = state.selectedCategory;
                    final goal = state.selectedGoal;
                    if (category == null || goal == null) {
                      return const SizedBox.shrink();
                    }
                    return SelectionBreadcrumb(
                      crumbs: [category.name, goal.goalName],
                    );
                  },
                ),
              ),
              const Gap(AppSpacing.s4),
              Entrance(
                index: 3,
                child: BlocBuilder<GoalSetupBloc, GoalSetupState>(
                  buildWhen: (previous, current) =>
                      previous.selectedGoal != current.selectedGoal,
                  builder: (context, state) {
                    final examName = state.selectedGoal?.goalName ?? '';
                    return Text(
                      context.l10n.goalStageSubtitle(examName),
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
              ),
              const Gap(AppSpacing.s24),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocConsumer<GoalSetupBloc, GoalSetupState>(
                    listenWhen: (previous, current) =>
                        previous.stagesStatus != current.stagesStatus ||
                        previous.saveStatus != current.saveStatus,
                    listener: (context, state) {
                      if (state.stagesStatus == GoalOptionsStatus.failure ||
                          state.saveStatus == GoalSaveStatus.failure) {
                        AppHaptics.error();
                        AppSnackbar.error(
                          state.errorMessage ?? context.l10n.errorGeneric,
                        );
                      }
                      if (state.saveStatus == GoalSaveStatus.success) {
                        AppHaptics.success();
                        getIt<AuthRepository>().completeGoalSetup();
                        context.goNamed(RouteNames.dashboard);
                      }
                    },
                    builder: (context, state) {
                      if (state.stagesStatus == GoalOptionsStatus.loading ||
                          state.stagesStatus == GoalOptionsStatus.initial) {
                        return const StageSelectorSkeleton();
                      }
                      if (state.stagesStatus == GoalOptionsStatus.failure) {
                        return ErrorView(
                          message:
                              state.errorMessage ?? context.l10n.errorGeneric,
                          retryLabel: context.l10n.commonRetry,
                          onRetry: () => context.read<GoalSetupBloc>().add(
                            const GoalStageStepEntered(),
                          ),
                        );
                      }

                      if (state.targetDate != null) {
                        final formatted = _dateFormat.format(state.targetDate!);
                        if (_dateController.text != formatted) {
                          _dateController.text = formatted;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StageSelector(
                            stages: state.stages,
                            selectedStage: state.selectedStage,
                            selectedTopicIds: state.selectedTopicIds,
                            onStageSelected: (stage) => context
                                .read<GoalSetupBloc>()
                                .add(GoalStageSelected(stage)),
                            onTopicToggled: (topicId) => context
                                .read<GoalSetupBloc>()
                                .add(GoalTopicToggled(topicId)),
                          ),
                          const Gap(AppSpacing.s24),
                          AppTextField(
                            controller: _dateController,
                            label: context.l10n.goalTargetDateLabel,
                            hint: _dateFormat.format(DateTime.now()),
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            onTap: () => _pickDate(context, state.targetDate),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Gap(AppSpacing.s8),
              BlocBuilder<GoalSetupBloc, GoalSetupState>(
                buildWhen: (previous, current) =>
                    previous.canSave != current.canSave ||
                    previous.saveStatus != current.saveStatus,
                builder: (context, state) {
                  return AppButton(
                    label: context.l10n.goalSaveGoal,
                    isLoading: state.saveStatus == GoalSaveStatus.saving,
                    onPressed: !state.canSave
                        ? null
                        : () {
                            AppHaptics.selection();
                            context.read<GoalSetupBloc>().add(
                              const GoalSaveRequested(),
                            );
                          },
                  );
                },
              ),
              const Gap(AppSpacing.s8),
              AppButton(
                label: context.l10n.goalSetupLater,
                isOutlined: true,
                onPressed: () {
                  AppHaptics.selection();
                  getIt<AuthRepository>().completeGoalSetup();
                  context.goNamed(RouteNames.dashboard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && context.mounted) {
      AppHaptics.selection();
      context.read<GoalSetupBloc>().add(GoalTargetDateChanged(picked));
    }
  }
}
