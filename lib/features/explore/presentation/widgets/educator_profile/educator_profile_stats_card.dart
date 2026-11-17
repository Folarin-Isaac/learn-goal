import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';

class EducatorProfileStatsCard extends StatelessWidget {
  const new({required this.profile, super.key});

  final EducatorProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final number = NumberFormat.decimalPattern(locale);
    final stats = [
      (number.format(profile.learnersTaught), l10n.educatorProfileStatLearners),
      (
        number.format(profile.hoursTaught.round()),
        l10n.educatorProfileStatHours,
      ),
      (
        number.format(profile.cohortsDelivered),
        l10n.educatorProfileStatCohorts,
      ),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats[i].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(2),
                    Text(stats[i].$2, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
