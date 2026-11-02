import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/entities/class_page.dart';
import 'package:lengoal/features/classes/domain/entities/class_referral.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

abstract class ClassRepository {
  Future<Either<Failure, List<LengoalClass>>> getSubscribedClasses({
    String? searchTerm,
    String? goalId,
  });

  Future<Either<Failure, List<LengoalClass>>> getRecommendedClasses({
    String? categoryId,
    String? goalName,
    int? pageSize,
  });

  Future<Either<Failure, List<LengoalClass>>> searchClasses(String searchTerm);

  Future<Either<Failure, ClassPage>> getRecommendedClassesPage({
    required int page,
    required int pageSize,
    String? categoryId,
  });

  Future<Either<Failure, List<LengoalClass>>> getSavedClasses({
    String? searchTerm,
  });

  Future<Either<Failure, LengoalClass>> getClass(String id);

  Future<Either<Failure, Unit>> saveClass(String classId);

  Future<Either<Failure, Unit>> unsaveClass(String classId);

  Future<Either<Failure, List<ClassEducator>>> getClassEducators(
    String classId,
  );

  Future<Either<Failure, ClassReplay>> getClassReplay(String classOutlineId);

  Future<Either<Failure, ClassReferral>> generateClassReferral(String classId);
}
