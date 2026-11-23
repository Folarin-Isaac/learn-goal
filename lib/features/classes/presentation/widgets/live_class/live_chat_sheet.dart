import 'dart:async';

import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_chat.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_controller.dart';

class LiveChatSheet extends StatefulWidget {
  const new({required this.controller, super.key});

  final LiveRoomController controller;

  static Future<void> show(
    BuildContext context,
    LiveRoomController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: LiveChatSheet(controller: controller),
        ),
      ),
    );
  }

  static const Color _panel = Color(0xFA111111);
  static const Color _localBubble = Color(0xFF2F2F3A);
  static const Color _remoteBubble = Color(0xFF1F1F24);

  @override
  State<LiveChatSheet> createState() => _LiveChatSheetState();
}

class _LiveChatSheetState extends State<LiveChatSheet> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _shown = 0;
  bool _sending = false;

  LiveRoomController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChange);
    _shown = _controller.chatMessages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.setChatOpen(open: true);
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChange)
      ..setChatOpen(open: false);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChange() {
    final count = _controller.chatMessages.length;
    if (count == _shown) return;
    _shown = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(0, duration: AppMotion.fast, curve: Curves.easeOut);
    });
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await _controller.sendChat(text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _input.clear();
    } else {
      AppHaptics.error();
      AppSnackbar.error(context.l10n.liveClassChatSendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s8,
              AppSpacing.s8,
              AppSpacing.s8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.liveClassMessages,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.liveClassClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final messages = _controller.chatMessages;
                return ListView.builder(
                  controller: _scroll,
                  reverse: true,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final index = messages.length - 1 - i;
                    final meta = chatEntryMeta(messages, index);
                    return _Entry(
                      message: messages[index],
                      hideName: meta.hideName,
                      hideTime: meta.hideTime,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s8,
              AppSpacing.s16,
              AppSpacing.s16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofillHints: null,
                    controller: _input,
                    enabled: _controller.canSignal,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => unawaited(_send()),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.liveClassChatHint,
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white38,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: 12,
                      ),
                      border: _border(Colors.white12),
                      enabledBorder: _border(Colors.white12),
                      disabledBorder: _border(Colors.white10),
                      focusedBorder: _border(Colors.white30),
                    ),
                  ),
                ),
                const Gap(AppSpacing.s8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _input,
                  builder: (context, value, _) {
                    final enabled =
                        value.text.trim().isNotEmpty &&
                        !_sending &&
                        _controller.canSignal;
                    return TextButton(
                      onPressed: enabled ? () => unawaited(_send()) : null,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white30,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      child: Text(l10n.liveClassSend),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.r8),
    borderSide: BorderSide(color: color),
  );
}

class _Entry extends StatelessWidget {
  const new({
    required this.message,
    required this.hideName,
    required this.hideTime,
  });

  final LiveChatMessage message;
  final bool hideName;
  final bool hideTime;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final small = context.textTheme.labelSmall;
    final time = DateFormat.jm(Localizations.localeOf(context).toLanguageTag())
        .format(message.sentAt);
    final showMeta = !hideName || !hideTime || message.isEdited;
    return Padding(
      padding: EdgeInsets.only(top: hideName ? AppSpacing.s4 : AppSpacing.s16),
      child: Column(
        crossAxisAlignment: message.isLocal
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (showMeta)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (!hideName)
                      TextSpan(
                        text: message.isLocal
                            ? l10n.liveClassYou
                            : message.fromName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (!hideName && !hideTime) const TextSpan(text: '  '),
                    if (!hideTime) TextSpan(text: time),
                    if (message.isEdited)
                      TextSpan(
                        text: ' ${l10n.chatsEdited}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
                style: small?.copyWith(color: Colors.white54),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: message.isLocal
                    ? LiveChatSheet._localBubble
                    : LiveChatSheet._remoteBubble,
                borderRadius: BorderRadius.circular(AppSpacing.r8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: AppSpacing.s8,
                ),
                child: SelectableText(
                  message.message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
