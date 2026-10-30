import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_info_column.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_thumbnail.dart';

class ClassListTile extends StatelessWidget {
  const new({
    required this.item,
    required this.showFavorite,
    this.showProgress = true,
    this.centerInfo = false,
    this.onTap,
    super.key,
  });

  final ClassSummary item;
  final bool showFavorite;
  final bool showProgress;
  final bool centerInfo;
  final VoidCallback? onTap;

  static const double _thumbnailFraction = 0.45;
  static const double _minThumbnailWidth = 120;
  static const double _maxThumbnailWidth = 170;
  static const double _thumbnailAspect = 1.08;

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
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final thumbnailWidth =
                    (constraints.maxWidth * _thumbnailFraction).clamp(
                      _minThumbnailWidth,
                      _maxThumbnailWidth,
                    );
                final info = ClassInfoColumn(
                  item: item,
                  stackDate: true,
                  showProgress: showProgress,
                );
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: thumbnailWidth * _thumbnailAspect,
                        ),
                        child: SizedBox(
                          width: thumbnailWidth,
                          child: ClassThumbnail(
                            item: item,
                            showFavorite: showFavorite,
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: centerInfo
                            ? Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: info,
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.s4,
                                ),
                                child: info,
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
