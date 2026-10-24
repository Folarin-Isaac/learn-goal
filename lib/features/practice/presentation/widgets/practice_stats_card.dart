import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_stats.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_score_ring.dart';

class PracticeStatsCard extends StatelessWidget {
  const new({required this.stats, super.key, this.isMock = false});

  final PracticeStats stats;
  final bool isMock;

  List<_RingData> _rings(BuildContext context) {
    if (isMock) {
      return [
        _RingData(
          label: context.l10n.practicePercentileRank,
          percent: stats.percentileRank,
          value: '${stats.percentileRank}%',
          caption: context.l10n.practicePercentile,
        ),
        _RingData(
          label: context.l10n.practiceMockSolved,
          percent: stats.mockSolvedPercent,
          value: '${stats.mockSolvedPercent}%',
          caption: context.l10n.practicePercentile,
        ),
        _RingData(
          label: context.l10n.practiceAvgTimePerQuestion,
          percent: stats.avgSecondsPercent,
          value: '${stats.avgSeconds}',
          caption: context.l10n.practiceSeconds,
        ),
      ];
    }
    return [
      _RingData(
        label: context.l10n.practiceQuestionsSolved,
        percent: stats.solvedPercent,
        value: '${stats.solvedPercent}%',
        caption: context.l10n.practicePercentile,
      ),
      _RingData(
        label: context.l10n.practiceQuestionsSolved,
        percent: stats.mockPercent,
        value: '${stats.mockPercent}%',
        caption: context.l10n.practicePercentile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rings = _rings(context);
    final divider = Colors.white.withValues(alpha: 0.25);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.brandPrimary,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        image: DecorationImage(
          image: Assets.images.practiceStatsPattern.provider(),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMock
                          ? context.l10n.practiceMockAverageScore
                          : context.l10n.practiceAverageScore,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const Gap(AppSpacing.s4),
                    Text(
                      context.l10n.practicePercentValue(stats.averagePercent),
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              _ScoreTag(percent: stats.averagePercent),
            ],
          ),
          const Gap(AppSpacing.s16),
          Divider(height: 1, color: divider),
          const Gap(AppSpacing.s16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rings.length; i++) ...[
                  if (i != 0)
                    VerticalDivider(width: 1, thickness: 1, color: divider),
                  Expanded(
                    child: _StatColumn(ring: rings[i], isCompact: isMock),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingData {
  const new({
    required this.label,
    required this.percent,
    required this.value,
    required this.caption,
  });

  final String label;
  final int percent;
  final String value;
  final String caption;
}

class _ScoreTag extends StatelessWidget {
  const new({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7F8),
        borderRadius: BorderRadius.circular(AppSpacing.r4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: AppSpacing.s16, color: const Color(0xFFB4C8EA)),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: AppSpacing.s16,
            ),
            child: Text(
              '$percent%',
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const new({required this.ring, required this.isCompact});

  final _RingData ring;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 34,
          child: Text(
            ring.label,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
        const Gap(AppSpacing.s8),
        PracticeScoreRing(
          percent: ring.percent,
          value: ring.value,
          caption: ring.caption,
          size: isCompact ? 62 : 68,
        ),
      ],
    );
  }
}
