import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_details_tab_scroll.dart';

class ClassCommunicationsTab extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ClassDetailsTabScroll.empty(
      storageKey: 'classDetailsCommunications',
      message: context.l10n.classDetailsCommunicationsEmpty,
    );
  }
}
