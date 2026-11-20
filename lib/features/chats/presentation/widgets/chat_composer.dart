import 'package:lengoal/core/core.dart';

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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onAttach;
  final bool isEditing;
  final bool isBusy;
  final VoidCallback? onCancelEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
