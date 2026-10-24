import 'package:lengoal/core/core.dart';

class CalendarDay {
  const new({required this.date, required this.weekday});

  final int date;
  final String weekday;
}

const mockCalendarWeek = [
  CalendarDay(date: 19, weekday: 'Sun'),
  CalendarDay(date: 20, weekday: 'Mon'),
  CalendarDay(date: 21, weekday: 'Tue'),
  CalendarDay(date: 22, weekday: 'Wed'),
  CalendarDay(date: 23, weekday: 'Thu'),
];

class DayStrip extends StatelessWidget {
  const new({
    required this.days,
    required this.selectedDate,
    required this.onSelected,
    super.key,
  });

  final List<CalendarDay> days;
  final int selectedDate;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in days) ...[
          Expanded(
            child: _DayTile(
              day: day,
              isSelected: day.date == selectedDate,
              onTap: onSelected,
            ),
          ),
          if (day != days.last) const Gap(AppSpacing.s8),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const new({required this.day, required this.isSelected, required this.onTap});

  final CalendarDay day;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    '${day.date}',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: isSelected ? 20 : 18,
                    ),
                  ),
                  Text(day.weekday, style: context.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
