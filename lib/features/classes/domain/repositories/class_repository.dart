import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

abstract class ClassRepository {
  Future<Either<Failure, List<LengoalClass>>> getSubscribedClasses({
    String? searchTerm,
  });

  Future<Either<Failure, List<LengoalClass>>> getAllClasses({
    String? searchTerm,
  });

  Future<Either<Failure, List<LengoalClass>>> getSavedClasses({
    String? searchTerm,
  });

  Future<Either<Failure, LengoalClass>> getClass(String id);
}
