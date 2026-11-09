import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_material_row.dart';

class ClassMaterialsTab extends StatelessWidget {
  const new({required this.materials, super.key});

  final List<ClassMaterial> materials;

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return Center(
        child: Text(
          context.l10n.classDetailsMaterialsEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.all(AppSpacing.s24),
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
                Divider(height: 1, color: context.colors.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}
