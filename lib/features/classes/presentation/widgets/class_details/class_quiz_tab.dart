import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_quiz_card.dart';

class ClassQuizTab extends StatelessWidget {
  const new({required this.quizzes, super.key});

  final List<ClassQuiz> quizzes;

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return Center(
        child: Text(
          context.l10n.classDetailsQuizEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: quizzes.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) => ClassQuizCard(quiz: quizzes[index]),
    );
  }
}
