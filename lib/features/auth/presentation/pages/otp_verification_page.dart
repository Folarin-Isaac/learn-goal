import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';

class OtpVerificationPage extends StatelessWidget {
  const new({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpBloc(
        email: email,
        verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
        resendOtpUseCase: getIt<ResendOtpUseCase>(),
      ),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state.status == OtpStatus.failure) {
            AppHaptics.error();
            AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
          }
          if (state.status == OtpStatus.success) {
            AppHaptics.success();
            context.pushReplacementNamed(
              RouteNames.emailConfirmed,
              extra: state.email,
            );
          }
          if (state.resendStatus == OtpResendStatus.sent) {
            AppSnackbar.info(context.l10n.otpResendSuccess);
          }
          if (state.resendStatus == OtpResendStatus.failure) {
            AppHaptics.error();
            AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(AppSpacing.s24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(),
                    ),
                    const Gap(AppSpacing.s8),
                    Text(
                      context.l10n.otpTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Gap(AppSpacing.s4),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(text: context.l10n.otpSentPrefix),
                          TextSpan(
                            text: state.email,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: context.l10n.otpSentSuffix),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.s32),
                    OtpInput(value: state.code, length: state.length),
                    const Gap(AppSpacing.s16),
                    if (state.status == OtpStatus.submitting)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const Gap(AppSpacing.s8),
                            Text(
                              context.l10n.otpVerifying,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    else
                      Center(
                        child: Wrap(
                          children: [
                            Text(
                              '${context.l10n.otpResendPrompt} ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: state.canResend
                                  ? () {
                                      AppHaptics.selection();
                                      context.read<OtpBloc>().add(
                                        const OtpResendRequested(),
                                      );
                                    }
                                  : null,
                              child: CrossFadeSwap(
                                child: Text(
                                  state.resendCooldown > 0
                                      ? context.l10n.otpResendCooldown(
                                          state.resendCooldown,
                                        )
                                      : context.l10n.otpResendLink,
                                  key: ValueKey(state.resendCooldown > 0),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: state.canResend
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Gap(AppSpacing.s32),
                    IgnorePointer(
                      ignoring: state.status == OtpStatus.submitting,
                      child: Opacity(
                        opacity: state.status == OtpStatus.submitting ? 0.4 : 1,
                        child: NumericKeypad(
                          onKeyTap: (digit) {
                            AppHaptics.selection();
                            context.read<OtpBloc>().add(OtpDigitEntered(digit));
                          },
                          onBackspace: () {
                            AppHaptics.selection();
                            context.read<OtpBloc>().add(
                              const OtpDigitRemoved(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
