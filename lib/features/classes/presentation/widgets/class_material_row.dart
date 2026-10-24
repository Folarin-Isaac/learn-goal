import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';

class ClassMaterialRow extends StatelessWidget {
  const new({required this.material, super.key});

  final ClassMaterial material;

  @override
  Widget build(BuildContext context) {
    final isLink = material.fileType == MaterialFileType.link;

    return Pressable(
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          AppSnackbar.info(context.l10n.dashboardComingSoon);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          child: Row(
            children: [
              _FileIcon(fileType: material.fileType),
              const Gap(AppSpacing.s16),
              Expanded(
                child: Text(
                  material.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              if (!isLink) ...[
                const Gap(AppSpacing.s8),
                Assets.icons.downloadIcon.svg(
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const new({required this.fileType});

  final MaterialFileType fileType;

  @override
  Widget build(BuildContext context) {
    return switch (fileType) {
      MaterialFileType.pdf => Assets.icons.pdfFileIcon.svg(
        width: 36,
        height: 36,
      ),
      MaterialFileType.word => Assets.icons.wordFileIcon.svg(
        width: 36,
        height: 36,
      ),
      MaterialFileType.excel => Assets.icons.excelFileIcon.svg(
        width: 36,
        height: 36,
      ),
      MaterialFileType.link => Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.r8),
        ),
        child: Assets.icons.linkIcon.svg(
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            context.colors.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
    };
  }
}
