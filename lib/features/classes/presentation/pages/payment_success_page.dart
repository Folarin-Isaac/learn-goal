import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';

class PaymentSuccessPage extends StatelessWidget {
  const new({required this.detail, super.key});

  final ClassDetail detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SuccessPop(
                child: Assets.icons.successCheckIcon.svg(width: 96, height: 96),
              ),
              const Gap(AppSpacing.s24),
              Text(
                context.l10n.paymentReceivedTitle,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium,
              ),
              const Gap(AppSpacing.s4),
              Text(
                context.l10n.paymentReceivedBody,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
              const Gap(AppSpacing.s32),
              AppButton(
                label: context.l10n.paymentProceedButton,
                onPressed: () {
                  AppHaptics.selection();
                  context.pushReplacementNamed(
                    RouteNames.classDetails,
                    extra: detail.source,
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
