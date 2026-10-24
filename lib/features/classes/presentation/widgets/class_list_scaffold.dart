import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_tile.dart';

class ClassListScaffold extends StatefulWidget {
  const new({
    required this.title,
    required this.items,
    required this.showFavorite,
    super.key,
  });

  final String title;
  final List<ClassSummary> items;
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

  List<ClassSummary> get _filteredItems {
    final query = _query.toLowerCase();
    return widget.items
        .where(
          (item) => query.isEmpty || item.title.toLowerCase().contains(query),
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
    final items = _filteredItems;

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
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.dashboardNoResults,
                          style: context.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const Gap(AppSpacing.s16),
                        itemBuilder: (context, index) => Entrance(
                          index: index + 1,
                          child: ClassListTile(
                            item: items[index],
                            showFavorite: widget.showFavorite,
                            onTap: () => context.pushNamed(
                              RouteNames.classDetails,
                              extra: detailFor(items[index]),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
