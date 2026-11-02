import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';

class CalendarDay {
  const new({required this.date, this.hasSessions = false});

  final DateTime date;
  final bool hasSessions;
}

class DayStrip extends StatelessWidget {
  const new({
    required this.days,
    required this.selectedDate,
    required this.onSelected,
    super.key,
  });

  final List<CalendarDay> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.s4),
          Expanded(
            child: _DayTile(
              day: days[i],
              isSelected: DateUtils.isSameDay(days[i].date, selectedDate),
              onTap: onSelected,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const new({required this.day, required this.isSelected, required this.onTap});

  final CalendarDay day;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Pressable(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          onTap(day.date);
        },
        child: Column(
          children: [
            Container(
              height: isSelected ? AppSpacing.s24 : AppSpacing.s8,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandPrimary
                    : AppColors.brandPrimary.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.r8),
                  topRight: Radius.circular(AppSpacing.r8),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.r8),
                  bottomRight: Radius.circular(AppSpacing.r8),
                ),
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${day.date.day}',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: isSelected ? 20 : 18,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat.E(locale).format(day.date),
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  const Gap(AppSpacing.s4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.hasSessions
                          ? AppColors.brandPrimary
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
