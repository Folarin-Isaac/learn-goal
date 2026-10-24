import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_scaffold.dart';

class MyClassesPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ClassListScaffold(
      title: context.l10n.dashboardMyClasses,
      items: mockMyClasses,
      showFavorite: true,
    );
  }
}
