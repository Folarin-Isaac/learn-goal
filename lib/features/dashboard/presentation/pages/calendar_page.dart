import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_session.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/day_strip.dart';

class CalendarPage extends StatefulWidget {
  const new({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selected = DateUtils.dateOnly(DateTime.now());

  DateTime get _weekStart =>
      _selected.subtract(Duration(days: _selected.weekday % 7));

  List<DateTime> get _week => [
    for (var i = 0; i < 7; i++) DateUtils.addDaysToDate(_weekStart, i),
  ];

  void _shiftWeek(int weeks) {
    AppHaptics.selection();
    setState(() => _selected = DateUtils.addDaysToDate(_selected, weeks * 7));
  }

  Future<void> _pickDate() async {
    AppHaptics.selection();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selected = DateUtils.dateOnly(picked));
    }
  }

  String _weekLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final start = _week.first;
    final end = _week.last;
    final year = DateFormat.y(locale).format(end);
    if (start.month == end.month) {
      return '${DateFormat.MMMd(locale).format(start)} - ${end.day}, $year';
    }
    final startText = start.year == end.year
        ? DateFormat.MMMd(locale).format(start)
        : DateFormat.yMMMd(locale).format(start);
    return '$startText - ${DateFormat.MMMd(locale).format(end)}, $year';
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _weekLabel(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyLarge,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _shiftWeek(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () => _shiftWeek(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              Expanded(
                child: ClassListLoader(
                  source: ClassListSource.subscribed,
                  loading: const Center(child: LoadingIndicator()),
                  builder: _buildSchedule,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedule(BuildContext context, List<LengoalClass> classes) {
    final entries = [
      for (final lengoalClass in classes)
        for (final session in lengoalClass.sessions)
          (lengoalClass: lengoalClass, session: session),
    ]..sort((a, b) => a.session.startDate.compareTo(b.session.startDate));

    final daysWithSessions = {
      for (final entry in entries) DateUtils.dateOnly(entry.session.startDate),
    };
    final today = entries
        .where((e) => DateUtils.isSameDay(e.session.startDate, _selected))
        .toList();
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Entrance(
          index: 2,
          child: DayStrip(
            days: [
              for (final date in _week)
                CalendarDay(
                  date: date,
                  hasSessions: daysWithSessions.contains(date),
                ),
            ],
            selectedDate: _selected,
            onSelected: (date) => setState(() => _selected = date),
          ),
        ),
        const Gap(AppSpacing.s24),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                refreshClassLists(const [ClassListSource.subscribed]),
            child: today.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Center(
                          child: Text(
                            context.l10n.calendarNoSessions,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: today.length,
                    separatorBuilder: (context, index) =>
                        const Gap(AppSpacing.s16),
                    itemBuilder: (context, index) {
                      final entry = today[index];
                      return Entrance(
                        index: index + 3,
                        child: CalendarSessionCard(
                          session: _sessionFor(
                            entry.lengoalClass,
                            entry.session,
                            now,
                          ),
                          onTap: () => context.pushNamed(
                            RouteNames.classDetails,
                            extra: entry.lengoalClass,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  CalendarSession _sessionFor(
    LengoalClass lengoalClass,
    ClassSession session,
    DateTime now,
  ) {
    final host = lengoalClass.educatorName.isEmpty
        ? null
        : lengoalClass.educatorName;
    final base = calendarSessionFor(session, host, now);
    final topic = session.topic.trim();
    return CalendarSession(
      title: topic.isEmpty || topic == lengoalClass.cohortName
          ? lengoalClass.cohortName
          : '${lengoalClass.cohortName} · $topic',
      day: base.day,
      dateLabel: base.dateLabel,
      timeRange: base.timeRange,
      status: base.status,
      meetingUrl: base.meetingUrl,
      host: base.host,
      id: base.id,
      hasReplay: base.hasReplay,
    );
  }
}
