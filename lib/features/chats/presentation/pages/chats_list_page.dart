import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_list/chat_list_cubit.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_list_tile.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

class ChatsListPage extends StatefulWidget {
  const new({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final ChatListCubit _cubit = getIt<ChatListCubit>()..start();
  final TextEditingController _search = TextEditingController();
  late final Timer _clock;
  late final AppLifecycleListener _lifecycle;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
    _lifecycle = AppLifecycleListener(
      onPause: _cubit.pauseBackgroundRefresh,
      onResume: _cubit.resumeBackgroundRefresh,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _clock.cancel();
    _search.dispose();
    unawaited(_cubit.close());
    super.dispose();
  }

  Future<void> _open(LengoalClass lengoalClass) async {
    await context.pushNamed(RouteNames.chatThread, extra: lengoalClass);
    _cubit.refreshClass(lengoalClass.id);
  }

  @override
  Widget build(BuildContext context) {
    return RouteVisibilityListener(
      routeName: RouteNames.chats,
      onVisible: _cubit.refreshIfStale,
      child: BlocProvider.value(
        value: _cubit,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s24,
                    AppSpacing.s24,
                    AppSpacing.s24,
                    AppSpacing.s16,
                  ),
                  child: Entrance(
                    child: Text(
                      context.l10n.chatsTitle,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                  ),
                  child: Entrance(
                    index: 1,
                    child: TextField(
                      autofillHints: null,
                      controller: _search,
                      onChanged: _cubit.search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: context.l10n.chatsSearchHint,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Assets.icons.searchIcon.svg(
                            width: 20,
                            height: 20,
                          ),
                        ),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _search,
                          builder: (context, value, _) => value.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  tooltip: context.l10n.commonCancel,
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _search.clear();
                                    _cubit.search('');
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.s16),
                Expanded(
                  child: BlocBuilder<ChatListCubit, ChatListState>(
                    builder: _body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ChatListState state) {
    switch (state.status) {
      case ChatListStatus.loading:
        return const _ChatListSkeleton();
      case ChatListStatus.failure:
        return ErrorView(
          message: state.errorMessage ?? context.l10n.errorGeneric,
          retryLabel: context.l10n.commonRetry,
          onRetry: () => unawaited(_cubit.refresh()),
        );
      case ChatListStatus.loaded:
        final visible = state.visible;
        return RefreshIndicator(
          onRefresh: _cubit.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              0,
              AppSpacing.s24,
              AppSpacing.s24,
            ),
            itemCount: visible.isEmpty ? 1 : visible.length,
            separatorBuilder: (context, index) => const Gap(AppSpacing.s8),
            itemBuilder: (context, index) {
              if (visible.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s48),
                  child: Text(
                    state.hasClasses
                        ? context.l10n.chatsNoMatches
                        : context.l10n.chatsEmptyList,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final preview = visible[index];
              return Entrance(
                index: index + 2,
                child: ChatListTile(
                  preview: preview,
                  now: _now,
                  onTap: () => unawaited(_open(preview.lengoalClass)),
                ),
              );
            },
          ),
        );
    }
  }
}

class _ChatListSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        itemCount: 5,
        separatorBuilder: (context, index) => const Gap(AppSpacing.s8),
        itemBuilder: (context, index) => const SkeletonBox(height: 76),
      ),
    );
  }
}
