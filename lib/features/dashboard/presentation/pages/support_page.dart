import 'package:lengoal/core/core.dart';

const _supportPhone = '+2349053873945';
const _supportEmail = 'support@lengoal.com';

class SupportPage extends StatelessWidget {
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
              Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      context.l10n.profileSupport,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.icons.supportBadgeIcon.svg(
                          width: 120,
                          height: 120,
                        ),
                        const Gap(AppSpacing.s24),
                        Text(
                          context.l10n.profileSupportGotQuestion,
                          style: context.textTheme.titleLarge,
                        ),
                        const Gap(AppSpacing.s16),
                        Text.rich(
                          TextSpan(
                            style: context.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: context.l10n.profileSupportCallPrefix,
                              ),
                              const TextSpan(
                                text: _supportPhone,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: context.l10n.profileSupportEmailConnector,
                              ),
                              const TextSpan(
                                text: _supportEmail,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(AppSpacing.s16),
                        Text(
                          context.l10n.profileSupportOrDivider,
                          style: context.textTheme.titleMedium,
                        ),
                        const Gap(AppSpacing.s24),
                        AppButton(
                          label: context.l10n.profileSupportContactButton,
                          onPressed: () {
                            AppHaptics.selection();
                            AppSnackbar.info(context.l10n.dashboardComingSoon);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
