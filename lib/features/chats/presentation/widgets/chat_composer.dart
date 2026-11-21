import 'package:lengoal/core/core.dart';

class ChatComposerController extends TextEditingController {
  RegExp? _mentions;
  Color? _mentionColor;

  void setMentionStyle(RegExp? mentions, Color color) {
    _mentions = mentions;
    _mentionColor = color;
  }

  static final RegExp _space = RegExp(r'\s');

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    final pattern = _mentions;
    if (pattern == null || !text.contains('@')) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final highlight = TextStyle(
      color: _mentionColor,
      fontWeight: FontWeight.w700,
    );
    final children = <TextSpan>[];
    var index = 0;
    for (final match in pattern.allMatches(text)) {
      final startsWord =
          match.start == 0 || _space.hasMatch(text[match.start - 1]);
      if (!startsWord) continue;
      if (match.start > index) {
        children.add(TextSpan(text: text.substring(index, match.start)));
      }
      children.add(TextSpan(text: match.group(0), style: highlight));
      index = match.end;
    }
    if (children.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    if (index < text.length) {
      children.add(TextSpan(text: text.substring(index)));
    }
    return TextSpan(style: style, children: children);
  }
}

class ChatComposer extends StatelessWidget {
  const new({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onAttach,
    super.key,
    this.isEditing = false,
    this.isBusy = false,
    this.onCancelEdit,
    this.banner,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onAttach;
  final bool isEditing;
  final bool isBusy;
  final VoidCallback? onCancelEdit;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = banner;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (top != null && !isEditing)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: top,
          ),
        if (isEditing)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: context.colors.primary,
                ),
                const Gap(AppSpacing.s8),
                Expanded(
                  child: Text(
                    l10n.chatsEditMessage,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.commonCancel,
                  onPressed: onCancelEdit,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: BorderRadius.circular(AppSpacing.r8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  autofillHints: null,
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.chatsComposerHint,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (!isEditing)
                IconButton(
                  tooltip: l10n.chatsAttachmentPreview,
                  onPressed: () {
                    AppHaptics.selection();
                    onAttach();
                  },
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final enabled = value.text.trim().isNotEmpty && !isBusy;
                  return IconButton(
                    onPressed: enabled
                        ? () {
                            AppHaptics.selection();
                            onSubmit();
                          }
                        : null,
                    icon: isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isEditing
                                ? Icons.check_rounded
                                : Icons.send_rounded,
                            color: enabled ? context.colors.primary : null,
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
