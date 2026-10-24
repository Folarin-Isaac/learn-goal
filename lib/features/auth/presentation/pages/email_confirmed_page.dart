import 'package:lengoal/core/core.dart';

class EmailConfirmedPage extends StatelessWidget {
  const new({required this.email, super.key});

  final String email;

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
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    const AppBackButton(),
                    const Gap(AppSpacing.s24),
                    SuccessPop(
                      child: Assets.images.envelopeIllustration.image(
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s24),
              Text(
                context.l10n.emailConfirmedTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Gap(AppSpacing.s4),
              Text(
                context.l10n.emailConfirmedBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Gap(AppSpacing.s32),
              AppButton(
                label: context.l10n.emailConfirmedContinue,
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
