import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_mock.dart';

class PracticeMockCard extends StatelessWidget {
  const new({required this.mock, required this.onTap, super.key});

  final PracticeMock mock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mock.label, style: context.textTheme.bodyLarge),
          const Gap(AppSpacing.s16),
          Text(
            mock.title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppSpacing.s8),
          Text(
            mock.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const Gap(AppSpacing.s16),
          Row(
            children: [
              if (mock.priceLabel != null) ...[
                _Tag(
                  label: mock.priceLabel!,
                  background: AppColors.tagBlueSurface,
                  foreground: AppColors.tagBlueText,
                  icon: Assets.icons.premiumTagIcon,
                ),
                const Gap(AppSpacing.s8),
              ],
              if (mock.isPaid)
                _Tag(
                  label: context.l10n.practicePaid,
                  background: AppColors.tagGreenSurface,
                  foreground: AppColors.successGreen,
                ),
            ],
          ),
          const Gap(AppSpacing.s16),
          Align(
            alignment: Alignment.centerRight,
            child: Pressable(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
                onTap: () {
                  AppHaptics.selection();
                  onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.practiceStartMock,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(AppSpacing.s8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.accentBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const new({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.r4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!.svg(width: 12, height: 12),
            const Gap(AppSpacing.s4),
          ],
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
