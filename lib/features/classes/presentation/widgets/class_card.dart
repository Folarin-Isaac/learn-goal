import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_info_column.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_thumbnail.dart';

class ClassCard extends StatelessWidget {
  const new({required this.item, required this.width, this.onTap, super.key});

  final ClassSummary item;
  final double width;
  final VoidCallback? onTap;

  static const double thumbnailAspectRatio = 1.35;

  static const double textBlockHeight = 170;

  static double preferredHeight(double cardWidth) =>
      cardWidth / thumbnailAspectRatio + AppSpacing.s8 + textBlockHeight;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          if (onTap != null) {
            onTap!();
          } else {
            AppSnackbar.info(context.l10n.dashboardComingSoon);
          }
        },
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: thumbnailAspectRatio,
                child: ClassThumbnail(
                  item: item,
                  showFavorite: item.isFavorite,
                  playBadgeAlignment: Alignment.topRight,
                ),
              ),
              const Gap(AppSpacing.s8),
              ClassInfoColumn(item: item),
            ],
          ),
        ),
      ),
    );
  }
}
