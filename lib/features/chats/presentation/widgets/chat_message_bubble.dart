import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';

enum ChatBubbleStatus { sent, sending, failed }

class ChatMessageBubble extends StatelessWidget {
  const new({
    required this.text,
    required this.timeLabel,
    required this.isMine,
    super.key,
    this.senderName,
    this.photoUrl,
    this.mediaUrl,
    this.isEdited = false,
    this.status = ChatBubbleStatus.sent,
    this.isBusy = false,
    this.onLongPress,
    this.onTap,
  });

  final String text;
  final String timeLabel;
  final bool isMine;
  final String? senderName;
  final String? photoUrl;
  final String? mediaUrl;
  final bool isEdited;
  final ChatBubbleStatus status;
  final bool isBusy;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  static const double _avatarSize = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.colors.onSurfaceVariant;
    final metaStyle = context.textTheme.bodySmall?.copyWith(color: muted);
    final who = isMine ? l10n.chatsYou : (senderName ?? '');

    final meta = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: who.isEmpty ? timeLabel : '$who · $timeLabel'),
          if (isEdited)
            TextSpan(
              text: ' ${l10n.chatsEdited}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
        ],
      ),
      style: metaStyle,
    );

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      child: Material(
        color: isMine
            ? context.colors.primary
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          onLongPress: onLongPress,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _BubbleContent(
              text: text,
              mediaUrl: mediaUrl,
              isMine: isMine,
            ),
          ),
        ),
      ),
    );

    final column = Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        meta,
        const Gap(AppSpacing.s4),
        Opacity(
          opacity: status == ChatBubbleStatus.sending || isBusy ? 0.6 : 1,
          child: bubble,
        ),
        if (status != ChatBubbleStatus.sent) ...[
          const Gap(AppSpacing.s4),
          Text(
            status == ChatBubbleStatus.sending
                ? l10n.chatsSending
                : l10n.chatsNotSent,
            style: metaStyle?.copyWith(
              color: status == ChatBubbleStatus.failed
                  ? AppColors.errorRed
                  : muted,
            ),
          ),
        ],
      ],
    );

    if (isMine) {
      return Align(alignment: Alignment.centerRight, child: column);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SenderAvatar(
          name: senderName ?? '',
          photoUrl: photoUrl,
          size: _avatarSize,
        ),
        const Gap(AppSpacing.s8),
        Flexible(child: column),
      ],
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const new({required this.text, required this.mediaUrl, required this.isMine});

  final String text;
  final String? mediaUrl;
  final bool isMine;

  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  };

  bool get _isImage {
    final url = mediaUrl;
    if (url == null) return false;
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    final dot = path.lastIndexOf('.');
    return dot != -1 && _imageExtensions.contains(path.substring(dot + 1));
  }

  @override
  Widget build(BuildContext context) {
    final foreground = isMine ? Colors.white : context.colors.onSurface;
    final url = mediaUrl;
    final hasText = text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (url != null) ...[
          GestureDetector(
            onTap: () => unawaited(openExternalUrl(url)),
            child: _isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.r4),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      height: 180,
                      fit: BoxFit.cover,
                      errorWidget: (context, _, _) =>
                          _AttachmentChip(color: foreground),
                    ),
                  )
                : _AttachmentChip(color: foreground),
          ),
          if (hasText) const Gap(AppSpacing.s8),
        ],
        if (hasText)
          Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(color: foreground),
          ),
      ],
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const new({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.attach_file_rounded, size: 18, color: color),
        const Gap(AppSpacing.s4),
        Flexible(
          child: Text(
            context.l10n.chatsAttachmentPreview,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              decoration: TextDecoration.underline,
              decorationColor: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _SenderAvatar extends StatelessWidget {
  const new({required this.name, required this.photoUrl, required this.size});

  final String name;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: context.colors.primary,
      foregroundColor: Colors.white,
      child: Text(
        initial,
        style: context.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = photoUrl;
    if (url == null) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, _) => fallback,
        errorWidget: (context, _, _) => fallback,
      ),
    );
  }
}
