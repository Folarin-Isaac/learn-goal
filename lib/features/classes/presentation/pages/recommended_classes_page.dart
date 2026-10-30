import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_scaffold.dart';

class RecommendedClassesPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ClassListScaffold(
      title: context.l10n.dashboardRecommendedClasses,
      source: ClassListSource.recommended,
      showFavorite: false,
    );
  }
}
