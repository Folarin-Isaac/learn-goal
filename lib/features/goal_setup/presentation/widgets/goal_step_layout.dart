import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/goal_setup/presentation/widgets/step_badge.dart';

class GoalStepLayout extends StatelessWidget {
  const new({
    required this.step,
    required this.body,
    required this.footer,
    super.key,
  });

  final int step;
  final List<Widget> body;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s24,
                AppSpacing.s24,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  Entrance(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppBackButton(),
                        StepBadge(step: step, totalSteps: 3),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  ...body,
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s16,
                  AppSpacing.s24,
                  AppSpacing.s24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: footer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
