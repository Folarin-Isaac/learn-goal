import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/goal_setup/goal_setup.dart';

class GoalExamPage extends StatelessWidget {
  const new({super.key});

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
                    StepBadge(step: 2, totalSteps: 3),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              Entrance(
                index: 1,
                child: Text(
                  context.l10n.goalExamTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const Gap(AppSpacing.s8),
              Entrance(
                index: 2,
                child: BlocBuilder<GoalSetupBloc, GoalSetupState>(
                  buildWhen: (previous, current) =>
                      previous.selectedCategory != current.selectedCategory,
                  builder: (context, state) {
                    final category = state.selectedCategory;
                    if (category == null) return const SizedBox.shrink();
                    return SelectionBreadcrumb(crumbs: [category.name]);
                  },
                ),
              ),
              const Gap(AppSpacing.s4),
              Entrance(
                index: 3,
                child: Text(
                  context.l10n.goalExamSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Gap(AppSpacing.s24),
              Entrance(
                index: 4,
                child: GoalSearchField(
                  hint: context.l10n.goalSearchHint,
                  onChanged: (query) => context.read<GoalSetupBloc>().add(
                    GoalQueryChanged(query),
                  ),
                ),
              ),
              const Gap(AppSpacing.s16),
              BlocConsumer<GoalSetupBloc, GoalSetupState>(
                listenWhen: (previous, current) =>
                    previous.goalsStatus != current.goalsStatus,
                listener: (context, state) {
                  if (state.goalsStatus == GoalOptionsStatus.failure) {
                    AppSnackbar.error(
                      state.errorMessage ?? context.l10n.errorGeneric,
                    );
                  }
                },
                builder: (context, state) {
                  if (state.goalsStatus == GoalOptionsStatus.loading ||
                      state.goalsStatus == GoalOptionsStatus.initial) {
                    return const SelectableListSkeleton();
                  }
                  if (state.goalsStatus == GoalOptionsStatus.failure) {
                    return ErrorView(
                      message: state.errorMessage ?? context.l10n.errorGeneric,
                      retryLabel: context.l10n.commonRetry,
                      onRetry: () => context.read<GoalSetupBloc>().add(
                        const GoalStepTwoEntered(),
                      ),
                    );
                  }
                  if (state.goals.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s24,
                      ),
                      child: Text(
                        context.l10n.goalExamEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return SelectableListCard(
                    items: state.filteredGoals,
                    labelOf: (goal) => goal.goalName,
                    selected: state.selectedGoal,
                    onSelected: (goal) =>
                        context.read<GoalSetupBloc>().add(GoalSelected(goal)),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<GoalSetupBloc, GoalSetupState>(
                buildWhen: (previous, current) =>
                    previous.selectedGoal != current.selectedGoal,
                builder: (context, state) {
                  return AppButton(
                    label: context.l10n.commonNext,
                    onPressed: state.selectedGoal == null
                        ? null
                        : () {
                            AppHaptics.selection();
                            context.read<GoalSetupBloc>().add(
                              const GoalStageStepEntered(),
                            );
                            context.pushNamed(RouteNames.goalStage);
                          },
                  );
                },
              ),
              const Gap(AppSpacing.s8),
              AppButton(
                label: context.l10n.goalSetupLater,
                isOutlined: true,
                foregroundColor: AppColors.brandPrimary,
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
}
