import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_text.dart';

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
    this.isImage = false,
    this.localImagePath,
    this.showHeader = true,
    this.isEdited = false,
    this.status = ChatBubbleStatus.sent,
    this.isBusy = false,
    this.onLongPress,
    this.onTap,
    this.onOpenMedia,
    this.quoteName,
    this.onQuoteTap,
  });

  final String text;
  final String timeLabel;
  final bool isMine;
  final String? senderName;
  final String? photoUrl;
  final String? mediaUrl;
  final bool isImage;
  final String? localImagePath;
  final bool showHeader;
  final bool isEdited;
  final ChatBubbleStatus status;
  final bool isBusy;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onOpenMedia;
  final String Function(String name)? quoteName;
  final VoidCallback? onQuoteTap;

  static const double avatarSize = 28;

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
            ? AppColors.brandPrimary
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
              isImage: isImage,
              localImagePath: localImagePath,
              isMine: isMine,
              onOpenMedia: onOpenMedia,
              quoteName: quoteName,
              onQuoteTap: onQuoteTap,
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
        if (showHeader) ...[meta, const Gap(AppSpacing.s4)],
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
        if (showHeader)
          _SenderAvatar(
            name: senderName ?? '',
            photoUrl: photoUrl,
            size: avatarSize,
          )
        else
          const SizedBox(width: avatarSize),
        const Gap(AppSpacing.s8),
        Flexible(child: column),
      ],
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const new({
    required this.text,
    required this.mediaUrl,
    required this.isImage,
    required this.isMine,
    required this.onOpenMedia,
    this.localImagePath,
    this.quoteName,
    this.onQuoteTap,
  });

  final String text;
  final String? mediaUrl;
  final bool isImage;
  final String? localImagePath;
  final bool isMine;
  final VoidCallback? onOpenMedia;
  final String Function(String name)? quoteName;
  final VoidCallback? onQuoteTap;

  static const double _imageSize = 200;

  @override
  Widget build(BuildContext context) {
    final foreground = isMine ? Colors.white : context.colors.onSurface;
    final url = mediaUrl;
    final local = localImagePath;
    final hasText = text.trim().isNotEmpty;
    final hasAttachment = url != null || local != null;
    final chip = _AttachmentChip(
      color: foreground,
      name: chatAttachmentName(url ?? local),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasAttachment) ...[
          GestureDetector(
            onTap: url == null ? null : onOpenMedia,
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.r4),
                    child: SizedBox.square(
                      dimension: _imageSize,
                      child: local != null
                          ? Image.file(
                              File(local),
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, _) =>
                                  _networkOrChip(url, foreground, chip),
                            )
                          : _networkOrChip(url, foreground, chip),
                    ),
                  )
                : chip,
          ),
          if (hasText) const Gap(AppSpacing.s8),
        ],
        if (hasText)
          ChatMessageText(
            text: text,
            color: foreground,
            quoteName: quoteName,
            onQuoteTap: onQuoteTap,
          ),
      ],
    );
  }

  Widget _networkOrChip(String? url, Color foreground, Widget chip) {
    if (url == null) return Center(child: chip);
    final placeholder = ColoredBox(color: foreground.withValues(alpha: 0.08));
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: AppMotion.fast,
      placeholder: (context, _) => placeholder,
      errorWidget: (context, _, _) => Center(child: chip),
    );
  }
}

String? chatAttachmentName(String? pathOrUrl) {
  if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
  final last = pathOrUrl.split(RegExp(r'[\\/]')).last.split('?').first;
  if (last.isEmpty) return null;
  final malformed = RegExp('%(?![0-9a-fA-F]{2})').hasMatch(last);
  return malformed ? last : Uri.decodeComponent(last);
}

class _AttachmentChip extends StatelessWidget {
  const new({required this.color, this.name});

  final Color color;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insert_drive_file_outlined, size: 18, color: color),
        const Gap(AppSpacing.s4),
        Flexible(
          child: Text(
            name ?? context.l10n.chatsAttachmentPreview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
      backgroundColor: AppColors.brandPrimary,
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
