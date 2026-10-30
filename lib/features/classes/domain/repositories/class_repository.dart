import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/entities/class_referral.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

abstract class ClassRepository {
  Future<Either<Failure, List<LengoalClass>>> getSubscribedClasses({
    String? searchTerm,
  });

  Future<Either<Failure, List<LengoalClass>>> getRecommendedClasses();

  Future<Either<Failure, List<LengoalClass>>> getSavedClasses({
    String? searchTerm,
  });

  Future<Either<Failure, LengoalClass>> getClass(String id);

  Future<Either<Failure, List<ClassEducator>>> getClassEducators(
    String classId,
  );

  Future<Either<Failure, ClassReplay>> getClassReplay(String classOutlineId);

  Future<Either<Failure, ClassReferral>> generateClassReferral(String classId);
}
