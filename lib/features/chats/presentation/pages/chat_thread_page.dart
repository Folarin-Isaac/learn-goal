import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_draft/chat_draft_store.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_thread/chat_thread_cubit.dart';
import 'package:lengoal/features/chats/presentation/models/chat_time.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_composer.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_day_separator.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_bubble.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_text.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';

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
      child: _ChatThreadView(lengoalClass: lengoalClass),
    );
  }
}

class _ChatThreadView extends StatefulWidget {
  const new({required this.lengoalClass});

  final LengoalClass lengoalClass;

  @override
  State<_ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<_ChatThreadView> {
  final ChatDraftStore _drafts = getIt<ChatDraftStore>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _composer = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scroll = ScrollController();
  late final AppLifecycleListener _lifecycle;
  late final Timer _clock;
  DateTime _now = DateTime.now();
  bool _showJump = false;
  bool _hasNewBelow = false;
  String _draftBeforeEdit = '';
  ChatMessage? _replyTo;

  static const double _loadOlderThreshold = 400;
  static const double _jumpThreshold = 400;
  static const double _atBottom = 120;
  static const Duration _groupWindow = Duration(minutes: 5);

  String get _classId => widget.lengoalClass.id;

  late final ChatThreadCubit _cubit = context.read<ChatThreadCubit>();

  @override
  void initState() {
    super.initState();
    _composer
      ..text = _drafts.of(_classId)
      ..addListener(_saveDraft);
    unawaited(_restoreSavedDraft());
    _scroll.addListener(_onScroll);
    _lifecycle = AppLifecycleListener(
      onPause: _cubit.pausePolling,
      onResume: () {
        _cubit.resumePolling();
        unawaited(_cubit.refresh());
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
    _composer.removeListener(_saveDraft);
    if (_cubit.state.editing != null) {
      _drafts.save(_classId, _draftBeforeEdit);
    }
    _composer.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _restoreSavedDraft() async {
    await _drafts.ready();
    if (!mounted || _composer.text.isNotEmpty) return;
    if (_cubit.state.editing != null) return;
    final saved = _drafts.of(_classId);
    if (saved.isEmpty) return;
    _composer
      ..text = saved
      ..selection = TextSelection.collapsed(offset: saved.length);
  }

  void _saveDraft() {
    if (_cubit.state.editing != null) return;
    _drafts.save(_classId, _composer.text);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final offset = _scroll.offset;
    final showJump = offset > _jumpThreshold;
    final clearNew = offset < _atBottom && _hasNewBelow;
    if (showJump != _showJump || clearNew) {
      setState(() {
        _showJump = showJump;
        if (clearNew) _hasNewBelow = false;
      });
    }
  }

  void _jumpToLatest() {
    if (!_scroll.hasClients) return;
    AppHaptics.selection();
    setState(() => _hasNewBelow = false);
    _scroll.animateTo(0, duration: AppMotion.slow, curve: Curves.easeOutCubic);
  }

  void _scrollToLatestAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients || _scroll.offset == 0) return;
      _scroll.animateTo(0, duration: AppMotion.fast, curve: Curves.easeOut);
    });
  }

  Future<void> _submit() async {
    final cubit = context.read<ChatThreadCubit>();
    final text = _composer.text;
    if (cubit.state.editing != null) {
      if (await cubit.saveEdit(text)) _restoreDraftAfterEdit();
      return;
    }
    final replyTo = _replyTo;
    final outgoing = replyTo == null
        ? text
        : ChatReplyQuote.compose(
            name: replyTo.sender?.name.trim() ?? '',
            kind: _quoteKind(replyTo),
            label: _quoteLabel(replyTo),
            body: text.trim(),
          );
    _composer.clear();
    if (replyTo != null) setState(() => _replyTo = null);
    _scrollToLatestAfterFrame();
    await cubit.send(outgoing);
  }

  bool _isImage(ChatMessage message) {
    final url = message.mediaUrl;
    return url != null && materialFileTypeFor(url) == MaterialFileType.image;
  }

  String _attachmentLabel(ChatMessage message) => _isImage(message)
      ? context.l10n.chatsPhoto
      : chatAttachmentName(message.mediaUrl) ??
            context.l10n.chatsAttachmentPreview;

  void _cancelReply() {
    AppHaptics.selection();
    setState(() => _replyTo = null);
  }

  void _restoreDraftAfterEdit() {
    _composer
      ..text = _draftBeforeEdit
      ..selection = TextSelection.collapsed(offset: _draftBeforeEdit.length);
    _draftBeforeEdit = '';
  }

  void _cancelEdit() {
    context.read<ChatThreadCubit>().cancelEditing();
    _restoreDraftAfterEdit();
  }

  void _startEdit(ChatMessage message) {
    if (_replyTo != null) setState(() => _replyTo = null);
    final cubit = context.read<ChatThreadCubit>();
    if (cubit.state.editing == null) _draftBeforeEdit = _composer.text;
    cubit.startEditing(message);
    _composer
      ..text = message.text
      ..selection = TextSelection.collapsed(offset: message.text.length);
    _focus.requestFocus();
  }

  bool _canReply(ChatMessage message) =>
      (message.sender?.name.trim().isNotEmpty ?? false) &&
      (message.hasMedia || _snippet(message).isNotEmpty);

  void _reply(ChatMessage message) {
    if (!_canReply(message)) return;
    if (_cubit.state.editing != null) _cancelEdit();
    setState(() => _replyTo = message);
    _focus.requestFocus();
  }

  String _snippet(ChatMessage message) =>
      ChatMessageText.withoutMention(message.text).trim();

  ChatQuoteKind _quoteKind(ChatMessage message) {
    if (_snippet(message).isNotEmpty || !message.hasMedia) {
      return ChatQuoteKind.text;
    }
    return _isImage(message) ? ChatQuoteKind.image : ChatQuoteKind.file;
  }

  String _quoteLabel(ChatMessage message) =>
      _quoteKind(message) == ChatQuoteKind.text
      ? _snippet(message)
      : _attachmentLabel(message);

  Future<void> _copy(ChatMessage message) async {
    await Clipboard.setData(ClipboardData(text: message.text));
    if (!mounted) return;
    AppSnackbar.success(context.l10n.chatsCopied);
  }

  void _openMedia(String url, String? senderName) {
    AppHaptics.selection();
    unawaited(
      context.pushNamed(
        RouteNames.materialViewer,
        extra: ClassMaterial(
          name: senderName?.trim().isNotEmpty ?? false
              ? senderName!
              : context.l10n.chatsAttachmentPreview,
          fileType: materialFileTypeFor(url),
          url: url,
        ),
      ),
    );
  }

  static const List<String> _documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'jpg',
    'jpeg',
    'png',
  ];
  static const int _maxFileBytes = 25 * 1024 * 1024;

  Future<void> _pickAttachment() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<_AttachSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profileTakePhoto),
              onTap: () => Navigator.of(context).pop(_AttachSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileChooseFromGallery),
              onTap: () => Navigator.of(context).pop(_AttachSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(l10n.chatsChooseFile),
              onTap: () => Navigator.of(context).pop(_AttachSource.file),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final path = source == _AttachSource.file
        ? await _pickDocument()
        : (await _picker.pickImage(
            source: source == _AttachSource.camera
                ? ImageSource.camera
                : ImageSource.gallery,
            maxWidth: 1600,
            imageQuality: 85,
          ))?.path;
    if (path == null || !mounted) return;
    _scrollToLatestAfterFrame();
    await _cubit.sendAttachment(path);
  }

  Future<String?> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _documentExtensions,
    );
    final file = result?.files.firstOrNull;
    if (file == null || !mounted) return null;
    if (file.size > _maxFileBytes) {
      AppHaptics.error();
      AppSnackbar.error(context.l10n.chatsFileTooLarge);
      return null;
    }
    return file.path;
  }

  void _openClass() {
    AppHaptics.selection();
    final wentBack = context.popIfPrevious(
      RouteNames.classDetails,
      sameTarget: (extra) => extra is LengoalClass && extra.id == _classId,
    );
    if (wentBack) return;
    unawaited(
      context.pushNamed(RouteNames.classDetails, extra: widget.lengoalClass),
    );
  }

  void _onStateChanged(BuildContext context, ChatThreadState state) {
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

  void _onNewest(BuildContext context, ChatThreadState state) {
    final newest = state.messages.isEmpty ? null : state.messages.last;
    if (newest == null || state.identity.owns(newest)) return;
    if (_scroll.hasClients && _scroll.offset > _atBottom && !_hasNewBelow) {
      setState(() => _hasNewBelow = true);
    }
  }

  Future<void> _showActions(ChatMessage message, {required bool isMine}) async {
    final l10n = context.l10n;
    final hasText = message.text.trim().isNotEmpty;
    final canReply = message.sender?.name.trim().isNotEmpty ?? false;
    AppHaptics.selection();
    final action = await showModalBottomSheet<_Action>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canReply)
              ListTile(
                leading: const Icon(Icons.reply_rounded),
                title: Text(l10n.chatsReply),
                onTap: () => Navigator.of(context).pop(_Action.reply),
              ),
            if (hasText)
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: Text(l10n.chatsCopy),
                onTap: () => Navigator.of(context).pop(_Action.copy),
              ),
            if (isMine && hasText)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.chatsEditMessage),
                onTap: () => Navigator.of(context).pop(_Action.edit),
              ),
            if (isMine)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorRed,
                ),
                title: Text(
                  l10n.chatsDeleteMessage,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
                onTap: () => Navigator.of(context).pop(_Action.delete),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    final cubit = context.read<ChatThreadCubit>();
    switch (action) {
      case _Action.reply:
        _reply(message);
      case _Action.copy:
        await _copy(message);
      case _Action.edit:
        _startEdit(message);
      case _Action.delete:
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<ChatThreadCubit, ChatThreadState>(
              listenWhen: (previous, current) =>
                  previous.effectCount != current.effectCount,
              listener: _onStateChanged,
            ),
            BlocListener<ChatThreadCubit, ChatThreadState>(
              listenWhen: (previous, current) =>
                  previous.messages.isNotEmpty &&
                  current.messages.isNotEmpty &&
                  previous.messages.last.id != current.messages.last.id,
              listener: _onNewest,
            ),
          ],
          child: BlocBuilder<ChatThreadCubit, ChatThreadState>(
            builder: (context, state) {
              final cubit = context.read<ChatThreadCubit>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context),
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
                        onAttach: () => unawaited(_pickAttachment()),
                        banner: _replyTo == null
                            ? null
                            : _replyBanner(context, state, _replyTo!),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _replyBanner(
    BuildContext context,
    ChatThreadState state,
    ChatMessage message,
  ) {
    final url = message.mediaUrl;
    final kind = _quoteKind(message);
    final local = url == null ? null : state.localMedia[url];
    final thumbnail = kind != ChatQuoteKind.image || url == null
        ? null
        : local != null
        ? Image.file(File(local), fit: BoxFit.cover)
        : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ChatQuoteCard(
              name: context.l10n.chatsReplyingTo(
                message.sender?.name.trim() ?? '',
              ),
              label: _quoteLabel(message),
              kind: kind,
              color: context.colors.primary,
              thumbnail: thumbnail,
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: context.l10n.commonCancel,
          onPressed: _cancelReply,
          icon: const Icon(Icons.close_rounded, size: 18),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          const AppBackButton(),
          const Gap(AppSpacing.s8),
          Expanded(
            child: Semantics(
              button: true,
              label: context.l10n.chatsViewClass,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
                onTap: _openClass,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s4,
                  ),
                  child: Text(
                    widget.lengoalClass.cohortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.chatsViewClass,
            onPressed: _openClass,
            icon: Icon(
              Icons.info_outline_rounded,
              color: context.colors.onSurface,
            ),
          ),
        ],
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
        return Stack(
          children: [
            NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < _loadOlderThreshold) {
                  unawaited(cubit.loadOlder());
                }
                return false;
              },
              child: ListView.builder(
                controller: _scroll,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                itemCount: entries.length + (showTop ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == entries.length) {
                    return _top(context, state, cubit);
                  }
                  return _entry(context, state, entries[index]);
                },
              ),
            ),
            if (_hasNewBelow || _showJump)
              Positioned(
                right: AppSpacing.s16,
                bottom: AppSpacing.s16,
                child: _JumpButton(
                  label: _hasNewBelow ? context.l10n.chatsNewMessages : null,
                  onTap: _jumpToLatest,
                ),
              ),
          ],
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
    final items =
        <({DateTime at, ChatMessage? message, PendingChatMessage? pending})>[
          for (final m in state.messages)
            (at: m.createdOn, message: m, pending: null),
          for (final p in state.pending)
            (at: p.createdOn, message: null, pending: p),
        ]..sort((a, b) => a.at.compareTo(b.at));
    final unreadAfter = state.unreadAfter;
    final result = <_Entry>[];
    DateTime? lastDay;
    String? lastSender;
    DateTime? lastAt;
    var newMarked = false;
    for (final item in items) {
      final message = item.message;
      final isMine = message == null || state.identity.owns(message);
      final sender = isMine ? '' : (message.sender?.userId ?? '?');
      final local = item.at.toLocal();
      var startsGroup = false;
      if (lastDay == null || !ChatTime.isSameDay(lastDay, local)) {
        result.add(_DayEntry(local));
        lastDay = local;
        startsGroup = true;
      }
      if (!newMarked &&
          unreadAfter != null &&
          message != null &&
          !isMine &&
          item.at.isAfter(unreadAfter)) {
        result.add(const _NewEntry());
        newMarked = true;
        startsGroup = true;
      }
      if (lastSender != sender ||
          lastAt == null ||
          item.at.difference(lastAt) > _groupWindow) {
        startsGroup = true;
      }
      result.add(
        message != null
            ? _MessageEntry(message, showHeader: startsGroup)
            : _PendingEntry(item.pending!, showHeader: startsGroup),
      );
      lastSender = sender;
      lastAt = item.at;
    }
    return result;
  }

  Widget _entry(BuildContext context, ChatThreadState state, _Entry entry) {
    return switch (entry) {
      _DayEntry(:final at) => ChatDaySeparator(
        label: ChatTime.day(context, at, _now),
      ),
      _NewEntry() => ChatDaySeparator(
        label: context.l10n.chatsNewMessages,
        highlight: true,
      ),
      _MessageEntry(:final message, :final showHeader) => Padding(
        padding: EdgeInsets.only(
          top: showHeader ? AppSpacing.s16 : AppSpacing.s4,
        ),
        child: _messageBubble(context, state, message, showHeader),
      ),
      _PendingEntry(:final message, :final showHeader) => Padding(
        padding: EdgeInsets.only(
          top: showHeader ? AppSpacing.s16 : AppSpacing.s4,
        ),
        child: ChatMessageBubble(
          text: message.text,
          timeLabel: ChatTime.clock(context, message.createdOn, _now),
          isMine: true,
          showHeader: showHeader,
          localImagePath: message.localPath,
          isImage:
              message.localPath != null &&
              materialFileTypeFor(message.localPath!) == MaterialFileType.image,
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
    bool showHeader,
  ) {
    final isMine = state.identity.owns(message);
    final url = message.mediaUrl;
    return ChatMessageBubble(
      text: message.text,
      timeLabel: ChatTime.clock(context, message.createdOn, _now),
      isMine: isMine,
      showHeader: showHeader,
      senderName: message.sender?.name,
      photoUrl: message.sender?.photoUrl,
      mediaUrl: url,
      localImagePath: url == null ? null : state.localMedia[url],
      isImage:
          url != null && materialFileTypeFor(url) == MaterialFileType.image,
      onOpenMedia: url == null
          ? null
          : () => _openMedia(url, message.sender?.name),
      isEdited: state.editedIds.contains(message.id),
      isBusy: state.deletingId == message.id || state.editing?.id == message.id,
      onLongPress: state.deletingId == message.id
          ? null
          : () => unawaited(_showActions(message, isMine: isMine)),
    );
  }
}

class _JumpButton extends StatelessWidget {
  const new({required this.onTap, this.label});

  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label;
    return Material(
      color: AppColors.brandPrimary,
      elevation: 3,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Tooltip(
          message: context.l10n.chatsJumpToLatest,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: text == null ? AppSpacing.s8 : AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (text != null) ...[
                  Text(
                    text,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Gap(AppSpacing.s4),
                ],
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Action { reply, copy, edit, delete }

enum _AttachSource { camera, gallery, file }

sealed class _Entry {
  const new();
}

final class _DayEntry extends _Entry {
  const new(this.at);

  final DateTime at;
}

final class _NewEntry extends _Entry {
  const new();
}

final class _MessageEntry extends _Entry {
  const new(this.message, {required this.showHeader});

  final ChatMessage message;
  final bool showHeader;
}

final class _PendingEntry extends _Entry {
  const new(this.message, {required this.showHeader});

  final PendingChatMessage message;
  final bool showHeader;
}
