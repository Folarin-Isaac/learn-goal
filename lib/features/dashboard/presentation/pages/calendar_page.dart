import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/day_strip.dart';

class CalendarPage extends StatefulWidget {
  const new({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDate = mockCalendarWeek
      .firstWhere((day) => day.weekday == 'Tue')
      .date;

  @override
  Widget build(BuildContext context) {
    final sessions = mockCalendarSessions
        .where((session) => session.day == _selectedDate)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Entrance(
                child: Row(
                  children: [
                    const AppBackButton(),
                    const Gap(AppSpacing.s8),
                    Expanded(
                      child: Text(
                        context.l10n.calendarTitle,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s16),
              Entrance(
                index: 1,
                child: GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    AppSnackbar.info(context.l10n.dashboardComingSoon);
                  },
                  child: Row(
                    children: [
                      Text(
                        'June 19 - 23, 2023',
                        style: context.textTheme.bodyLarge,
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.s16),
              Entrance(
                index: 2,
                child: DayStrip(
                  days: mockCalendarWeek,
                  selectedDate: _selectedDate,
                  onSelected: (date) => setState(() => _selectedDate = date),
                ),
              ),
              const Gap(AppSpacing.s24),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.calendarNoSessions,
                          style: context.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (context, index) =>
                            const Gap(AppSpacing.s16),
                        itemBuilder: (context, index) => Entrance(
                          index: index + 3,
                          child: CalendarSessionCard(session: sessions[index]),
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
