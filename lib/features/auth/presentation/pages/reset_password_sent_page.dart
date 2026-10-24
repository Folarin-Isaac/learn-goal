import 'package:lengoal/core/core.dart';

class ResetPasswordSentPage extends StatelessWidget {
  const new({required this.email, required this.token, super.key});

  final String email;
  final String token;

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
              Assets.images.envelopeIllustration.image(width: 72, height: 72),
              const Gap(AppSpacing.s24),
              Text(
                context.l10n.resetPasswordSentTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Gap(AppSpacing.s4),
              Text(
                context.l10n.resetPasswordSentBody(email),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Gap(AppSpacing.s32),
              AppButton(
                label: context.l10n.resetPasswordSentContinue,
                onPressed: () {
                  AppHaptics.selection();
                  context.pushReplacementNamed(
                    RouteNames.resetPassword,
                    extra: (email: email, token: token),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
