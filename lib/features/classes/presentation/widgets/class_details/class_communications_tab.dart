import 'package:lengoal/core/core.dart';

class ClassCommunicationsTab extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.classDetailsCommunicationsEmpty,
        style: context.textTheme.bodyMedium,
      ),
    );
  }
}
