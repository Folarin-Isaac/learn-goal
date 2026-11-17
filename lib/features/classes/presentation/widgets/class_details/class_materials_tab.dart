import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_details_tab_scroll.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_material_row.dart';

class ClassMaterialsTab extends StatelessWidget {
  const new({required this.materials, super.key});

  final List<ClassMaterial> materials;

  static const String _storageKey = 'classDetailsMaterials';

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return ClassDetailsTabScroll.empty(
        storageKey: _storageKey,
        message: context.l10n.classDetailsMaterialsEmpty,
      );
    }
    return ClassDetailsTabScroll(
      storageKey: _storageKey,
      slivers: [
        SliverPadding(
          padding: ClassDetailsTabScroll.padding,
          sliver: SliverToBoxAdapter(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Column(
                  children: [
                    for (var i = 0; i < materials.length; i++) ...[
                      ClassMaterialRow(material: materials[i]),
                      if (i != materials.length - 1)
                        Divider(
                          height: 1,
                          color: context.colors.outlineVariant,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
