import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';
import 'package:lengoal/features/explore/domain/repositories/explore_repository.dart';

class GetExploreCategoriesUseCase {
  new(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<ExploreCategory>>> call() =>
      _repository.getCategories();
}

class GetCategoryClassesUseCase {
  new(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<ExploreClass>>> call({String? categoryId}) =>
      _repository.getCategoryClasses(categoryId: categoryId);
}

class GetOngoingClassesUseCase {
  new(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<ExploreClass>>> call() =>
      _repository.getOngoingClasses();
}

class GetUpcomingClassesUseCase {
  new(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<ExploreClass>>> call() =>
      _repository.getUpcomingClasses();
}

class GetTopEducatorsUseCase {
  new(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<TopEducator>>> call() =>
      _repository.getTopEducators();
}

class GetEducatorProfileUseCase {
  new(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, EducatorProfile>> call(String educatorId) =>
      _repository.getEducatorProfile(educatorId);
}
