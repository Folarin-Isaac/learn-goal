import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_details_tab_scroll.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_quiz_card.dart';

class ClassQuizTab extends StatelessWidget {
  const new({required this.quizzes, super.key});

  final List<ClassQuiz> quizzes;

  static const String _storageKey = 'classDetailsQuiz';

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return ClassDetailsTabScroll.empty(
        storageKey: _storageKey,
        message: context.l10n.classDetailsQuizEmpty,
      );
    }
    return ClassDetailsTabScroll(
      storageKey: _storageKey,
      slivers: [
        SliverPadding(
          padding: ClassDetailsTabScroll.padding,
          sliver: SliverList.separated(
            itemCount: quizzes.length,
            separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
            itemBuilder: (context, index) =>
                ClassQuizCard(quiz: quizzes[index]),
          ),
        ),
      ],
    );
  }
}
