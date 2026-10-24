import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_filter.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_tile.dart';

class MyClassesHubPage extends StatefulWidget {
  const new({super.key});

  @override
  State<MyClassesHubPage> createState() => _MyClassesHubPageState();
}

class _MyClassesHubPageState extends State<MyClassesHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  ClassFilterOption? _filter;

  static const List<ClassSummary> _allItems = [
    ...mockMyClasses,
    ...mockRecommendedClasses,
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ClassSummary> get _subscribed => _allItems
      .where((item) => item.isSubscribed)
      .where((item) => matchesClassFilter(item, _filter))
      .toList();

  List<ClassSummary> get _saved => _allItems
      .where((item) => item.isFavorite)
      .where((item) => matchesClassFilter(item, _filter))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s24,
                AppSpacing.s24,
                0,
              ),
              child: Entrance(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.dashboardMyClasses,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        AppHaptics.selection();
                        AppSnackbar.info(context.l10n.dashboardComingSoon);
                      },
                      icon: Assets.icons.searchIcon.svg(width: 20, height: 20),
                    ),
                  ],
                ),
              ),
            ),
            Entrance(
              index: 1,
              child: AppTabBar(
                controller: _tabController,
                labels: [
                  context.l10n.dashboardSubscribedClasses,
                  context.l10n.dashboardSavedClasses,
                ],
              ),
            ),
            const Gap(AppSpacing.s16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Entrance(
                index: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ClassFilterChip(
                    current: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.s16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildList(_subscribed), _buildList(_saved)],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 1),
    );
  }

  Widget _buildList(List<ClassSummary> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          context.l10n.dashboardNoFilterResults,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        0,
        AppSpacing.s24,
        AppSpacing.s24,
      ),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) => Entrance(
        index: index + 3,
        child: ClassListTile(
          item: items[index],
          showFavorite: true,
          onTap: () => context.pushNamed(
            RouteNames.classDetails,
            extra: detailFor(items[index]),
          ),
        ),
      ),
    );
  }
}
