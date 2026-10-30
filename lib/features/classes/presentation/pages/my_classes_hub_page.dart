import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_filter.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
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
  final _searchController = TextEditingController();
  ClassFilterOption? _filter;
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    AppHaptics.selection();
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    AppHaptics.selection();
    setState(() {
      _isSearching = false;
      _query = '';
      _searchController.clear();
    });
  }

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
                child: _isSearching
                    ? Row(
                        children: [
                          IconButton(
                            onPressed: _stopSearch,
                            icon: const Icon(Icons.close),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: InputDecoration(
                                hintText: context.l10n.dashboardSearchHint,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Assets.icons.searchIcon.svg(
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.dashboardMyClasses,
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: _startSearch,
                            icon: Assets.icons.searchIcon.svg(
                              width: 20,
                              height: 20,
                            ),
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
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ClassTab(
                    source: ClassListSource.subscribed,
                    filter: _filter,
                    query: _query,
                  ),
                  _ClassTab(
                    source: ClassListSource.saved,
                    filter: _filter,
                    query: _query,
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

class _ClassTab extends StatefulWidget {
  const new({required this.source, required this.filter, required this.query});

  final ClassListSource source;
  final ClassFilterOption? filter;
  final String query;

  @override
  State<_ClassTab> createState() => _ClassTabState();
}

class _ClassTabState extends State<_ClassTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const padding = EdgeInsets.fromLTRB(
      AppSpacing.s24,
      0,
      AppSpacing.s24,
      AppSpacing.s24,
    );
    final isSaved = widget.source == ClassListSource.saved;
    return RefreshIndicator(
      onRefresh: () => refreshClassLists([
        widget.source,
        if (isSaved) ClassListSource.subscribed,
      ]),
      child: ClassListLoader(
        source: widget.source,
        loading: const ClassTileListSkeleton(padding: padding),
        builder: (context, classes) {
          if (!isSaved) return _buildList(context, classes, padding);
          return BlocBuilder<ClassListBloc, ClassListState>(
            bloc: classListBlocFor(ClassListSource.subscribed),
            builder: (context, subscribedState) {
              final subscribedIds = {
                for (final c in subscribedState.classes) c.id,
              };
              final marked = classes
                  .map(
                    (c) => subscribedIds.contains(c.id) ? c.asSubscribed() : c,
                  )
                  .toList();
              return _buildList(context, marked, padding);
            },
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<LengoalClass> classes,
    EdgeInsets padding,
  ) {
    final isSaved = widget.source == ClassListSource.saved;
    final query = widget.query.trim().toLowerCase();
    final entries = [
      for (final c in classes)
        if (query.isEmpty ||
            c.cohortName.toLowerCase().contains(query) ||
            c.educatorName.toLowerCase().contains(query))
          (
            lengoalClass: c,
            summary: ClassSummary.fromClass(c, isFavorite: isSaved),
          ),
    ].where((e) => matchesClassFilter(e.summary, widget.filter)).toList();

    if (entries.isEmpty) {
      final message = classes.isEmpty
          ? context.l10n.classesEmpty
          : query.isNotEmpty
          ? context.l10n.dashboardNoResults
          : context.l10n.dashboardNoFilterResults;
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Text(message, style: context.textTheme.bodyMedium),
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: entries.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) => Entrance(
        index: index + 3,
        child: ClassListTile(
          item: entries[index].summary,
          showFavorite: true,
          onTap: () => context.pushNamed(
            RouteNames.classDetails,
            extra: entries[index].lengoalClass,
          ),
        ),
      ),
    );
  }
}
