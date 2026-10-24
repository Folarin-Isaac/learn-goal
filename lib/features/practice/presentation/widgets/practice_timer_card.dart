import 'package:lengoal/core/core.dart';

class PracticeTimerCard extends StatelessWidget {
  const new({required this.remaining, super.key});

  final Duration remaining;

  String get _formatted {
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '${hours}hr : ${minutes}mins : ${seconds}secs';
  }

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Column(
        children: [
          Text(
            context.l10n.practiceTimeLabel,
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const Gap(AppSpacing.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatted,
              style: context.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
