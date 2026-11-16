import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';

class ExploreCategoryChips extends StatelessWidget {
  const new({
    required this.categories,
    required this.selectedId,
    required this.isLoading,
    required this.onSelected,
    super.key,
  });

  final List<ExploreCategory> categories;
  final String? selectedId;
  final bool isLoading;
  final ValueChanged<String?> onSelected;

  static const _palette = [
    Color(0xFFD6247B),
    Color(0xFFC77A12),
    Color(0xFF004DE6),
    Color(0xFF8CA21F),
    Color(0xFF0E8C43),
    Color(0xFF8E24AA),
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return const Shimmer(
        child: Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            SkeletonBox(width: 80, height: 34, radius: 17),
            SkeletonBox(width: 110, height: 34, radius: 17),
            SkeletonBox(width: 140, height: 34, radius: 17),
            SkeletonBox(width: 90, height: 34, radius: 17),
            SkeletonBox(width: 120, height: 34, radius: 17),
          ],
        ),
      );
    }
    if (categories.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: [
        _ClearChip(onTap: selectedId == null ? null : () => onSelected(null)),
        for (var i = 0; i < categories.length; i++)
          _CategoryChip(
            label: categories[i].name,
            color: _palette[i % _palette.length],
            isSelected: categories[i].id == selectedId,
            onTap: () => onSelected(categories[i].id),
          ),
      ],
    );
  }
}

class _ClearChip extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = context.colors.onSurface;
    return _ChipShell(
      onTap: onTap,
      background: context.colors.surface,
      border: foreground.withValues(alpha: 0.6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.closeCircleIcon.svg(
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
          const Gap(6),
          Text(
            context.l10n.exploreClear,
            style: context.textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const new({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : color;
    return _ChipShell(
      onTap: onTap,
      background: isSelected ? AppColors.accentBlue : context.colors.surface,
      border: isSelected ? AppColors.accentBlue : color.withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipShell extends StatelessWidget {
  const new({
    required this.onTap,
    required this.background,
    required this.border,
    required this.child,
  });

  final VoidCallback? onTap;
  final Color background;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                AppHaptics.selection();
                onTap!();
              },
        child: AnimatedContainer(
          duration: AppMotion.base,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}
