import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_tile.dart';

class _LoadMoreFooter extends StatelessWidget {
  const new({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: failed
          ? Column(
              children: [
                Text(
                  context.l10n.classesLoadMoreFailed,
                  style: context.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    AppHaptics.selection();
                    onRetry();
                  },
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            )
          : const LoadingIndicator(size: 24),
    );
  }
}

class ClassListScaffold extends StatefulWidget {
  const new({
    required this.title,
    required this.source,
    required this.showFavorite,
    super.key,
  });

  final String title;
  final ClassListSource source;
  final bool showFavorite;

  @override
  State<ClassListScaffold> createState() => _ClassListScaffoldState();
}

class _ClassListScaffoldState extends State<ClassListScaffold> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LengoalClass> _filter(List<LengoalClass> classes) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return classes;
    return classes
        .where(
          (c) =>
              c.cohortName.toLowerCase().contains(query) ||
              c.educatorName.toLowerCase().contains(query),
        )
        .toList();
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Entrance(
                child: _isSearching
                    ? _buildSearchRow(context)
                    : _buildHeaderRow(context),
              ),
              const Gap(AppSpacing.s16),
              Expanded(
                child: ClassListLoader(
                  source: widget.source,
                  loading: const ClassTileListSkeleton(),
                  builder: (context, classes) {
                    final items = _filter(classes);
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          classes.isEmpty
                              ? context.l10n.classesEmpty
                              : context.l10n.dashboardNoResults,
                          style: context.textTheme.bodyMedium,
                        ),
                      );
                    }
                    final bloc = classListBlocFor(widget.source);
                    return RefreshIndicator(
                      onRefresh: () => refreshClassLists([widget.source]),
                      child: BlocBuilder<ClassListBloc, ClassListState>(
                        bloc: bloc,
                        buildWhen: (previous, current) =>
                            previous.hasMore != current.hasMore ||
                            previous.isLoadingMore != current.isLoadingMore ||
                            previous.loadMoreFailed != current.loadMoreFailed,
                        builder: (context, paging) {
                          final showFooter =
                              widget.source.isPaged &&
                              (paging.isLoadingMore || paging.loadMoreFailed);
                          return NotificationListener<Notification>(
                            onNotification: (notification) {
                              _maybeLoadMore(notification, bloc);
                              return false;
                            },
                            child: SavedClassesBuilder(
                              builder: (context, savedIds) =>
                                  ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        items.length + (showFooter ? 1 : 0),
                                    separatorBuilder: (context, index) =>
                                        const Gap(AppSpacing.s16),
                                    itemBuilder: (context, index) {
                                      if (index == items.length) {
                                        return _LoadMoreFooter(
                                          failed: paging.loadMoreFailed,
                                          onRetry: () => bloc.add(
                                            const ClassListMoreRequested(),
                                          ),
                                        );
                                      }
                                      final isSaved = savedIds.contains(
                                        items[index].id,
                                      );
                                      return Entrance(
                                        index:
                                            (index % ClassListBloc.pageSize) +
                                            1,
                                        child: ClassListTile(
                                          item: ClassSummary.fromClass(
                                            items[index],
                                            isFavorite: isSaved,
                                          ),
                                          showFavorite: widget.showFavorite,
                                          onTap: () => context.pushNamed(
                                            RouteNames.classDetails,
                                            extra: items[index],
                                          ),
                                          onFavoriteTap: () => toggleSavedClass(
                                            context,
                                            items[index],
                                            save: !isSaved,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeLoadMore(Notification notification, ClassListBloc bloc) {
    if (!widget.source.isPaged) return;
    final metrics = switch (notification) {
      ScrollNotification(:final metrics) => metrics,
      ScrollMetricsNotification(:final metrics) => metrics,
      _ => null,
    };
    final state = bloc.state;
    if (metrics == null ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.loadMoreFailed) {
      return;
    }
    if (metrics.extentAfter < 400) bloc.add(const ClassListMoreRequested());
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        const AppBackButton(),
        const Gap(AppSpacing.s8),
        Expanded(
          child: Text(
            widget.title,
            style: context.textTheme.headlineSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: _startSearch,
          icon: Assets.icons.searchIcon.svg(width: 20, height: 20),
        ),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: _stopSearch, icon: const Icon(Icons.close)),
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: context.l10n.dashboardSearchHint,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: Assets.icons.searchIcon.svg(width: 20, height: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
