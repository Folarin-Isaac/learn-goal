import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';

class ClassMaterialRow extends StatelessWidget {
  const new({required this.material, super.key});

  final ClassMaterial material;

  static const double _iconSize = 40;
  static const double _actionIconSize = 22;

  bool get _isLink => material.fileType == MaterialFileType.link;

  Future<void> _open(BuildContext context) async {
    AppHaptics.selection();
    if (!_isLink) {
      unawaited(context.pushNamed(RouteNames.materialViewer, extra: material));
      return;
    }
    final failedMessage = context.l10n.classDetailsLinkOpenFailed;
    if (!await openExternalUrl(material.url)) {
      AppSnackbar.error(failedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    return Pressable(
      child: InkWell(
        onTap: () => unawaited(_open(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          child: Row(
            children: [
              _FileIcon(fileType: material.fileType, size: _iconSize),
              const Gap(AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(AppSpacing.s4),
                    Text(
                      _isLink
                          ? context.l10n.classDetailsMaterialExternalLink
                          : context.l10n.classDetailsMaterialFileResource,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              Icon(
                _isLink ? Icons.open_in_new_rounded : Icons.visibility_outlined,
                size: _actionIconSize,
                color: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const new({required this.fileType, required this.size});

  final MaterialFileType fileType;
  final double size;

  @override
  Widget build(BuildContext context) {
    return switch (fileType) {
      MaterialFileType.pdf => Assets.icons.pdfFileIcon.svg(
        width: size,
        height: size,
      ),
      MaterialFileType.word => Assets.icons.wordFileIcon.svg(
        width: size,
        height: size,
      ),
      MaterialFileType.excel => Assets.icons.excelFileIcon.svg(
        width: size,
        height: size,
      ),
      MaterialFileType.powerpoint => _CircleIcon(
        size: size,
        child: const Icon(
          Icons.slideshow_outlined,
          size: 18,
          color: Color(0xFFD24726),
        ),
      ),
      MaterialFileType.image => _CircleIcon(
        size: size,
        child: Icon(
          Icons.image_outlined,
          size: 18,
          color: context.colors.primary,
        ),
      ),
      MaterialFileType.text => _CircleIcon(
        size: size,
        child: Icon(
          Icons.description_outlined,
          size: 18,
          color: context.colors.primary,
        ),
      ),
      MaterialFileType.file => _CircleIcon(
        size: size,
        child: Icon(
          Icons.insert_drive_file_outlined,
          size: 18,
          color: context.colors.primary,
        ),
      ),
      MaterialFileType.link => _CircleIcon(
        size: size,
        child: Assets.icons.linkIcon.svg(
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            AppColors.errorRed,
            BlendMode.srcIn,
          ),
        ),
      ),
    };
  }
}

class _CircleIcon extends StatelessWidget {
  const new({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: child,
    );
  }
}
