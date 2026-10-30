import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_info_column.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_thumbnail.dart';

class ClassListTile extends StatelessWidget {
  const new({
    required this.item,
    required this.showFavorite,
    this.onTap,
    super.key,
  });

  final ClassSummary item;
  final bool showFavorite;
  final VoidCallback? onTap;

  static const double _thumbnailFraction = 0.42;
  static const double _minThumbnailSize = 110;
  static const double _maxThumbnailSize = 160;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          onTap: () {
            AppHaptics.selection();
            if (onTap != null) {
              onTap!();
            } else {
              AppSnackbar.info(context.l10n.dashboardComingSoon);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final thumbnailSize =
                    (constraints.maxWidth * _thumbnailFraction).clamp(
                      _minThumbnailSize,
                      _maxThumbnailSize,
                    );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: thumbnailSize,
                      height: thumbnailSize,
                      child: ClassThumbnail(
                        item: item,
                        showFavorite: showFavorite,
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    Expanded(
                      child: ClassInfoColumn(item: item, stackDate: true),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
