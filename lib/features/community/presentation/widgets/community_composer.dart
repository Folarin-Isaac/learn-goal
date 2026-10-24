import 'package:lengoal/core/core.dart';

class CommunityComposer extends StatelessWidget {
  const new({
    required this.controller,
    required this.hint,
    required this.onSubmit,
    super.key,
    this.avatarInitial,
    this.avatarColor,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;
  final String? avatarInitial;
  final Color? avatarColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (avatarInitial != null) ...[
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor,
            foregroundColor: Colors.white,
            child: Text(
              avatarInitial!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Gap(AppSpacing.s8),
        ],
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: context.colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
            ),
          ),
        ),
        const Gap(AppSpacing.s8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final enabled = value.text.trim().isNotEmpty;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                  vertical: AppSpacing.s16,
                ),
              ),
              onPressed: enabled ? onSubmit : null,
              child: Text(context.l10n.communityPostButton),
            );
          },
        ),
      ],
    );
  }
}
