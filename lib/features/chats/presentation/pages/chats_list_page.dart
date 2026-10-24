import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/models/chat_conversation.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_list_tile.dart';

class ChatsListPage extends StatefulWidget {
  const new({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openThread(ChatConversation conversation) {
    AppHaptics.selection();
    unawaited(context.pushNamed(RouteNames.chatThread, extra: conversation));
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
                child: Text(
                  context.l10n.chatsTitle,
                  style: context.textTheme.headlineSmall,
                ),
              ),
            ),
            Entrance(
              index: 1,
              child: AppTabBar(
                controller: _tabController,
                labels: [
                  context.l10n.chatsGroupMessagesTab,
                  context.l10n.chatsDirectMessagesTab,
                  context.l10n.chatsRequestsTab,
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ChatList(conversations: mockGroupChats, onTap: _openThread),
                  _ChatList(conversations: mockDirectChats, onTap: _openThread),
                  _ChatList(
                    conversations: mockChatRequests,
                    onTap: _openThread,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 4),
    );
  }
}

class _ChatList extends StatefulWidget {
  const new({required this.conversations, required this.onTap});

  final List<ChatConversation> conversations;
  final ValueChanged<ChatConversation> onTap;

  @override
  State<_ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<_ChatList>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatConversation> get _filtered {
    if (_query.isEmpty) return widget.conversations;
    final query = _query.toLowerCase();
    return widget.conversations
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final conversations = _filtered;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: context.l10n.chatsSearchHint,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: Assets.icons.searchIcon.svg(width: 20, height: 20),
            ),
          ),
        ),
        const Gap(AppSpacing.s16),
        if (conversations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
            child: Center(
              child: Text(
                context.l10n.dashboardNoResults,
                style: context.textTheme.bodyMedium,
              ),
            ),
          )
        else
          for (var i = 0; i < conversations.length; i++)
            Entrance(
              index: i + 2,
              child: ChatListTile(
                conversation: conversations[i],
                onTap: () => widget.onTap(conversations[i]),
              ),
            ),
      ],
    );
  }
}
