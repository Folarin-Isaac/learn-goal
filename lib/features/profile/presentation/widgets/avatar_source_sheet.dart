import 'package:image_picker/image_picker.dart';
import 'package:lengoal/core/core.dart';

class AvatarSourceSheet extends StatelessWidget {
  const new({super.key});

  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.profileChangePhoto,
              style: context.textTheme.titleLarge,
            ),
            const Gap(AppSpacing.s16),
            _SourceTile(
              icon: Assets.icons.cameraIcon,
              label: context.l10n.profileTakePhoto,
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const Gap(AppSpacing.s8),
            _SourceTile(
              icon: Assets.icons.editIconBlue,
              label: context.l10n.profileChooseFromGallery,
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onTap});

  final SvgGenImage icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: AppSpacing.s16,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tagBlueSurface,
                ),
                child: icon.svg(width: 18, height: 18),
              ),
              const Gap(AppSpacing.s16),
              Expanded(child: Text(label, style: context.textTheme.bodyLarge)),
            ],
          ),
        ),
      ),
    );
  }
}
