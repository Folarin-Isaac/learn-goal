import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/models/chat_conversation.dart';
import 'package:lengoal/features/chats/presentation/models/chat_message.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_composer.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_bubble.dart';

class ChatThreadPage extends StatefulWidget {
  const new({required this.conversation, super.key});

  final ChatConversation conversation;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  late final bool _isRequest =
      widget.conversation.type == ChatThreadType.request;
  late final List<ChatMessage> _messages = _isRequest
      ? [mockRequestPreviewMessage]
      : List<ChatMessage>.from(mockThreadMessages);

  late final int _initialCount = _messages.length;
  final _composerController = TextEditingController();

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;
    AppHaptics.selection();
    setState(() {
      _messages.add(
        ChatMessage(text: text, timestamp: _nowLabel(), isMine: true),
      );
      _composerController.clear();
    });
    context.unfocus();
  }

  String _nowLabel() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'am' : 'pm';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  void _respondToRequest(bool accepted) {
    AppHaptics.selection();
    AppSnackbar.info(context.l10n.dashboardComingSoon);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: conversation.avatarColor,
                    foregroundColor: Colors.white,
                    child: Text(
                      conversation.avatarInitial,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      conversation.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ColoredBox(
                color: context.colors.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  children: [
                    for (var i = 0; i < _messages.length; i++) ...[
                      ChatMessageBubble(
                        message: _messages[i],
                        index: i < _initialCount ? i : 0,
                      ),
                      const Gap(AppSpacing.s16),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: _isRequest
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _respondToRequest(false),
                              child: Text(context.l10n.chatsRejectMessage),
                            ),
                          ),
                          const Gap(AppSpacing.s8),
                          Expanded(
                            child: AppButton(
                              label: context.l10n.chatsAcceptMessage,
                              onPressed: () => _respondToRequest(true),
                            ),
                          ),
                        ],
                      )
                    : ChatComposer(
                        controller: _composerController,
                        onSubmit: _sendMessage,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
