import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_search/class_search_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_tile.dart';

class ClassSearchPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClassSearchBloc>(),
      child: const _ClassSearchView(),
    );
  }
}

class _ClassSearchView extends StatefulWidget {
  const new();

  @override
  State<_ClassSearchView> createState() => _ClassSearchViewState();
}

class _ClassSearchViewState extends State<_ClassSearchView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<ClassSearchBloc>().add(ClassSearchQueryChanged(value));
    });
  }

  void _search() {
    _debounce?.cancel();
    context.read<ClassSearchBloc>().add(
      ClassSearchQueryChanged(_controller.text),
    );
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
              Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: _onChanged,
                      onSubmitted: (_) => _search(),
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
              ),
              const Gap(AppSpacing.s16),
              Expanded(
                child: BlocBuilder<ClassSearchBloc, ClassSearchState>(
                  builder: (context, state) => switch (state.status) {
                    ClassSearchStatus.idle => _Message(
                      text: context.l10n.classSearchPrompt,
                    ),
                    ClassSearchStatus.loading when state.results.isEmpty =>
                      const ClassTileListSkeleton(),
                    ClassSearchStatus.failure => ErrorView(
                      message: state.errorMessage ?? context.l10n.errorGeneric,
                      onRetry: _search,
                      retryLabel: context.l10n.commonRetry,
                    ),
                    _ when state.results.isEmpty => _Message(
                      text: context.l10n.dashboardNoResults,
                    ),
                    _ => _Results(state: state),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const new({required this.state});

  final ClassSearchState state;

  @override
  Widget build(BuildContext context) {
    final results = state.results;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.status == ClassSearchStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(top: AppSpacing.s8),
            itemCount: results.length,
            separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
            itemBuilder: (context, index) => ClassListTile(
              item: ClassSummary.fromClass(results[index]),
              showFavorite: false,
              onTap: () => context.pushNamed(
                RouteNames.classDetails,
                extra: results[index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium,
      ),
    );
  }
}
