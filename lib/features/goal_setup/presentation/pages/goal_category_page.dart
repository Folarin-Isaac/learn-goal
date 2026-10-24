import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/goal_setup/goal_setup.dart';

class GoalCategoryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final isFirstLogin =
        GoRouterState.of(context).uri.queryParameters['first'] == 'true';

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
                    StepBadge(step: 1, totalSteps: 3),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              Entrance(
                index: 1,
                child: Text(
                  isFirstLogin
                      ? context.l10n.goalFieldTitleFirstLogin
                      : context.l10n.goalFieldTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const Gap(AppSpacing.s4),
              Entrance(
                index: 2,
                child: Text(
                  context.l10n.goalCategorySubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Gap(AppSpacing.s24),
              Entrance(
                index: 3,
                child: GoalSearchField(
                  hint: context.l10n.goalCategorySearchHint,
                  onChanged: (query) => context.read<GoalSetupBloc>().add(
                    GoalCategoryQueryChanged(query),
                  ),
                ),
              ),
              const Gap(AppSpacing.s16),
              BlocConsumer<GoalSetupBloc, GoalSetupState>(
                listenWhen: (previous, current) =>
                    previous.categoriesStatus != current.categoriesStatus,
                listener: (context, state) {
                  if (state.categoriesStatus == GoalOptionsStatus.failure) {
                    AppSnackbar.error(
                      state.errorMessage ?? context.l10n.errorGeneric,
                    );
                  }
                },
                builder: (context, state) {
                  if (state.categoriesStatus == GoalOptionsStatus.loading ||
                      state.categoriesStatus == GoalOptionsStatus.initial) {
                    return const SelectableListSkeleton();
                  }
                  if (state.categoriesStatus == GoalOptionsStatus.failure) {
                    return ErrorView(
                      message: state.errorMessage ?? context.l10n.errorGeneric,
                      retryLabel: context.l10n.commonRetry,
                      onRetry: () => context.read<GoalSetupBloc>().add(
                        const GoalSetupStarted(),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GoalFilterChips(
                        items: state.categories,
                        labelOf: (category) => category.name,
                        selected: state.selectedCategory,
                        onSelected: (category) => context
                            .read<GoalSetupBloc>()
                            .add(GoalCategorySelected(category)),
                      ),
                      const Gap(AppSpacing.s16),
                      SelectableListCard(
                        items: state.filteredCategories,
                        labelOf: (category) => category.name,
                        selected: state.selectedCategory,
                        onSelected: (category) => context
                            .read<GoalSetupBloc>()
                            .add(GoalCategorySelected(category)),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<GoalSetupBloc, GoalSetupState>(
                buildWhen: (previous, current) =>
                    previous.selectedCategory != current.selectedCategory,
                builder: (context, state) {
                  return AppButton(
                    label: context.l10n.commonNext,
                    onPressed: state.selectedCategory == null
                        ? null
                        : () {
                            AppHaptics.selection();
                            context.read<GoalSetupBloc>().add(
                              const GoalStepTwoEntered(),
                            );
                            context.pushNamed(RouteNames.goalExam);
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
