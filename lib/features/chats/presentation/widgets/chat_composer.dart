import 'package:lengoal/core/core.dart';

class ChatComposer extends StatelessWidget {
  const new({required this.controller, required this.onSubmit, super.key});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            AppHaptics.selection();
            AppSnackbar.info(context.l10n.dashboardComingSoon);
          },
          icon: Assets.icons.cameraIcon.svg(width: 20, height: 20),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: context.l10n.communityShareHint,
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
              child: Text(context.l10n.chatsSendButton),
            );
          },
        ),
      ],
    );
  }
}
