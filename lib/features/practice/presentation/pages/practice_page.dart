import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_mock.dart';
import 'package:lengoal/features/practice/presentation/models/practice_stats.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_mock_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_stats_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_subject_card.dart';

class PracticePage extends StatefulWidget {
  const new({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s16,
                AppSpacing.s24,
                AppSpacing.s8,
              ),
              child: Entrance(
                child: Text(
                  context.l10n.practiceTitle,
                  style: context.textTheme.headlineSmall,
                ),
              ),
            ),
            Entrance(
              index: 1,
              child: AppTabBar(
                controller: _tabController,
                labels: [
                  context.l10n.practiceReviewQuestionsTab,
                  context.l10n.practiceMockTab,
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: context.theme.scaffoldBackgroundColor,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _SubjectListTab(subjects: mockPracticeSubjects),
                    _MockListTab(mocks: mockPracticeMocks),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 2),
    );
  }
}

class _SubjectListTab extends StatefulWidget {
  const new({required this.subjects});

  final List<PracticeSubject> subjects;

  @override
  State<_SubjectListTab> createState() => _SubjectListTabState();
}

class _SubjectListTabState extends State<_SubjectListTab>
    with AutomaticKeepAliveClientMixin {
  int? _expandedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        const Entrance(child: PracticeStatsCard(stats: mockPracticeStats)),
        const Gap(AppSpacing.s16),
        for (var i = 0; i < widget.subjects.length; i++) ...[
          Entrance(
            index: i + 1,
            child: PracticeSubjectCard(
              subject: widget.subjects[i],
              isExpanded: _expandedIndex == i,
              onToggle: () => setState(
                () => _expandedIndex = _expandedIndex == i ? null : i,
              ),
              onTopicTap: (topic) => unawaited(
                context.pushNamed(RouteNames.practiceTopic, extra: topic),
              ),
            ),
          ),
          const Gap(AppSpacing.s16),
        ],
      ],
    );
  }
}

class _MockListTab extends StatefulWidget {
  const new({required this.mocks});

  final List<PracticeMock> mocks;

  @override
  State<_MockListTab> createState() => _MockListTabState();
}

class _MockListTabState extends State<_MockListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        const Entrance(
          child: PracticeStatsCard(stats: mockPracticeStats, isMock: true),
        ),
        const Gap(AppSpacing.s16),
        for (var i = 0; i < widget.mocks.length; i++) ...[
          Entrance(
            index: i + 1,
            child: PracticeMockCard(
              mock: widget.mocks[i],
              onTap: () => unawaited(
                context.pushNamed(
                  RouteNames.practiceMockDetail,
                  extra: widget.mocks[i],
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.s16),
        ],
      ],
    );
  }
}
