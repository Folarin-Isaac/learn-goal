import 'package:lengoal/core/core.dart';

class ResetPasswordSuccessPage extends StatelessWidget {
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
              const Gap(AppSpacing.s24),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(),
              ),
              const Gap(AppSpacing.s24),
              SuccessPop(
                child: Assets.icons.successCheckIcon.svg(width: 96, height: 96),
              ),
              const Gap(AppSpacing.s24),
              Text(
                context.l10n.resetPasswordSuccessTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Gap(AppSpacing.s4),
              Text(
                context.l10n.resetPasswordSuccessBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Gap(AppSpacing.s32),
              AppButton(
                label: context.l10n.resetPasswordSuccessContinue,
                onPressed: () {
                  AppHaptics.selection();
                  context.goNamed(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
