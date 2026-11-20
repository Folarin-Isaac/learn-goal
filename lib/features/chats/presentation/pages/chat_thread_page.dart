import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_thread/chat_thread_cubit.dart';
import 'package:lengoal/features/chats/presentation/models/chat_time.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_composer.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_day_separator.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_bubble.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

class ChatThreadPage extends StatelessWidget {
  const new({required this.lengoalClass, super.key});

  final LengoalClass lengoalClass;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ChatThreadCubit>(param1: lengoalClass.id);
        unawaited(cubit.load());
        return cubit;
      },
      child: _ChatThreadView(title: lengoalClass.cohortName),
    );
  }
}

class _ChatThreadView extends StatefulWidget {
  const new({required this.title});

  final String title;

  @override
  State<_ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<_ChatThreadView> {
  final TextEditingController _composer = TextEditingController();
  final FocusNode _focus = FocusNode();
  late final AppLifecycleListener _lifecycle;
  late final Timer _clock;
  DateTime _now = DateTime.now();

  static const double _loadOlderThreshold = 400;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onPause: () => context.read<ChatThreadCubit>().pausePolling(),
      onResume: () {
        final cubit = context.read<ChatThreadCubit>()..resumePolling();
        unawaited(cubit.refresh());
      },
    );
    _clock = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _clock.cancel();
    _composer.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ChatThreadCubit>();
    final text = _composer.text;
    if (cubit.state.editing != null) {
      if (await cubit.saveEdit(text)) _composer.clear();
      return;
    }
    _composer.clear();
    await cubit.send(text);
  }

  void _cancelEdit() {
    context.read<ChatThreadCubit>().cancelEditing();
    _composer.clear();
  }

  void _onEffect(BuildContext context, ChatThreadState state) {
    final effect = state.effect;
    if (effect == null) return;
    switch (effect.kind) {
      case ChatThreadEffectKind.error:
        AppHaptics.error();
        AppSnackbar.error(effect.message);
      case ChatThreadEffectKind.deleted:
        AppHaptics.success();
        AppSnackbar.success(context.l10n.chatsMessageDeleted);
    }
  }

  Future<void> _showOwnMessageActions(ChatMessage message) async {
    final cubit = context.read<ChatThreadCubit>();
    final l10n = context.l10n;
    AppHaptics.selection();
    final action = await showModalBottomSheet<_OwnAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.text.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.chatsEditMessage),
                onTap: () => Navigator.of(context).pop(_OwnAction.edit),
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.errorRed,
              ),
              title: Text(
                l10n.chatsDeleteMessage,
                style: const TextStyle(color: AppColors.errorRed),
              ),
              onTap: () => Navigator.of(context).pop(_OwnAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _OwnAction.edit:
        cubit.startEditing(message);
        _composer
          ..text = message.text
          ..selection = TextSelection.collapsed(offset: message.text.length);
        _focus.requestFocus();
      case _OwnAction.delete:
        final confirmed = await AppConfirmDialog.show(
          context,
          title: l10n.chatsDeleteConfirmTitle,
          body: l10n.chatsDeleteConfirmBody,
          cancelLabel: l10n.commonCancel,
          confirmLabel: l10n.chatsDeleteConfirm,
          confirmColor: AppColors.errorRed,
        );
        if (confirmed ?? false) await cubit.delete(message);
    }
  }

  Future<void> _showFailedActions(PendingChatMessage message) async {
    final cubit = context.read<ChatThreadCubit>();
    final l10n = context.l10n;
    AppHaptics.selection();
    final retry = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: Text(l10n.chatsRetryMessage),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: Text(l10n.chatsDiscardMessage),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
    if (retry == null) return;
    if (retry) {
      await cubit.retry(message.clientMessageId);
    } else {
      cubit.discard(message.clientMessageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ChatThreadCubit, ChatThreadState>(
          listenWhen: (previous, current) =>
              previous.effectCount != current.effectCount,
          listener: _onEffect,
          builder: (context, state) {
            final cubit = context.read<ChatThreadCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const Gap(AppSpacing.s8),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _body(context, state, cubit)),
                if (state.status == ChatThreadStatus.loaded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s8,
                      AppSpacing.s16,
                      AppSpacing.s16,
                    ),
                    child: ChatComposer(
                      controller: _composer,
                      focusNode: _focus,
                      isEditing: state.editing != null,
                      isBusy: state.isSavingEdit,
                      onCancelEdit: _cancelEdit,
                      onSubmit: () => unawaited(_submit()),
                      onAttach: () =>
                          AppSnackbar.info(context.l10n.dashboardComingSoon),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ChatThreadState state,
    ChatThreadCubit cubit,
  ) {
    switch (state.status) {
      case ChatThreadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ChatThreadStatus.failure:
        return ErrorView(
          message: state.errorMessage ?? context.l10n.errorGeneric,
          retryLabel: context.l10n.commonRetry,
          onRetry: () => unawaited(cubit.load()),
        );
      case ChatThreadStatus.loaded:
        if (state.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Text(
                context.l10n.chatsThreadEmpty,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
        final entries = _entries(state).reversed.toList();
        final showTop =
            state.hasOlder || state.isLoadingOlder || state.loadOlderFailed;
        return NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < _loadOlderThreshold) {
              unawaited(cubit.loadOlder());
            }
            return false;
          },
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            itemCount: entries.length + (showTop ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == entries.length) return _top(context, state, cubit);
              return _entry(context, state, entries[index]);
            },
          ),
        );
    }
  }

  Widget _top(
    BuildContext context,
    ChatThreadState state,
    ChatThreadCubit cubit,
  ) {
    if (state.loadOlderFailed && !state.isLoadingOlder) {
      return TextButton(
        onPressed: () => unawaited(cubit.loadOlder()),
        child: Text(context.l10n.chatsLoadOlderFailed),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.s16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  List<_Entry> _entries(ChatThreadState state) {
    final items = <_Entry>[
      for (final m in state.messages) _MessageEntry(m),
      for (final p in state.pending) _PendingEntry(p),
    ]..sort((a, b) => a.at.compareTo(b.at));
    final result = <_Entry>[];
    DateTime? lastDay;
    for (final item in items) {
      final local = item.at.toLocal();
      if (lastDay == null || !ChatTime.isSameDay(lastDay, local)) {
        result.add(_DayEntry(local));
        lastDay = local;
      }
      result.add(item);
    }
    return result;
  }

  Widget _entry(BuildContext context, ChatThreadState state, _Entry entry) {
    return switch (entry) {
      _DayEntry(:final at) => ChatDaySeparator(
        label: ChatTime.day(context, at, _now),
      ),
      _MessageEntry(:final message) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
        child: _messageBubble(context, state, message),
      ),
      _PendingEntry(:final message) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
        child: ChatMessageBubble(
          text: message.text,
          timeLabel: ChatTime.relative(context, message.createdOn, _now),
          isMine: true,
          status: message.failed
              ? ChatBubbleStatus.failed
              : ChatBubbleStatus.sending,
          onTap: message.failed
              ? () => unawaited(_showFailedActions(message))
              : null,
        ),
      ),
    };
  }

  Widget _messageBubble(
    BuildContext context,
    ChatThreadState state,
    ChatMessage message,
  ) {
    final isMine = state.identity.owns(message);
    return ChatMessageBubble(
      text: message.text,
      timeLabel: ChatTime.relative(context, message.createdOn, _now),
      isMine: isMine,
      senderName: message.sender?.name,
      photoUrl: message.sender?.photoUrl,
      mediaUrl: message.mediaUrl,
      isEdited: state.editedIds.contains(message.id),
      isBusy: state.deletingId == message.id || state.editing?.id == message.id,
      onLongPress: isMine && state.deletingId == null
          ? () => unawaited(_showOwnMessageActions(message))
          : null,
    );
  }
}

enum _OwnAction { edit, delete }

sealed class _Entry {
  const new();

  DateTime get at;
}

final class _DayEntry extends _Entry {
  const new(this.at);

  @override
  final DateTime at;
}

final class _MessageEntry extends _Entry {
  const new(this.message);

  final ChatMessage message;

  @override
  DateTime get at => message.createdOn;
}

final class _PendingEntry extends _Entry {
  const new(this.message);

  final PendingChatMessage message;

  @override
  DateTime get at => message.createdOn;
}
