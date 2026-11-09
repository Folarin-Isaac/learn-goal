import 'package:lengoal/core/core.dart';

class ClassCertificateTab extends StatelessWidget {
  const new({required this.hasCertificate, super.key});

  final bool hasCertificate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasCertificate) ...[
            Text(
              context.l10n.classDetailsCertificateLocked,
              style: context.textTheme.titleLarge,
            ),
            const Gap(AppSpacing.s24),
          ] else ...[
            const _CertificatePreview(),
            const Gap(AppSpacing.s24),
          ],
          AppButton(
            label: context.l10n.classDetailsDownloadCertificate,
            isOutlined: true,
            onPressed: () {
              AppHaptics.selection();
              AppSnackbar.info(context.l10n.dashboardComingSoon);
            },
          ),
        ],
      ),
    );
  }
}

class _CertificatePreview extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CERTIFICATE',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Text(
              'OF ACHIEVEMENT',
              style: context.textTheme.bodySmall?.copyWith(letterSpacing: 2),
            ),
            const Gap(AppSpacing.s16),
            Icon(
              Icons.workspace_premium_rounded,
              color: context.colors.primary,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}
