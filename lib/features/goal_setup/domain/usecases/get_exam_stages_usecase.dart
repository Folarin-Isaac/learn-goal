import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_stage.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

class GetExamStagesUseCase {
  GetExamStagesUseCase(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, List<ExamStage>>> call({required String examId}) {
    return _repository.getExamStages(examId: examId);
  }
}
