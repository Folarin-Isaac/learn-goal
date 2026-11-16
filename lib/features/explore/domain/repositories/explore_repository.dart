import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';

abstract class ExploreRepository {
  Future<Either<Failure, List<ExploreCategory>>> getCategories();

  // Without a categoryId the feed returns classes from every category.
  Future<Either<Failure, List<ExploreClass>>> getCategoryClasses({
    String? categoryId,
  });

  Future<Either<Failure, List<ExploreClass>>> getOngoingClasses();

  Future<Either<Failure, List<ExploreClass>>> getUpcomingClasses();

  Future<Either<Failure, List<TopEducator>>> getTopEducators();
}
