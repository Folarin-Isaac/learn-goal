import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';
import 'package:lengoal/features/explore/domain/usecases/get_explore_feed_usecases.dart';

part 'explore_state.dart';

// Every row loads independently, so one slow or failing endpoint never
// holds back the rest of the page.
class ExploreCubit extends Cubit<ExploreState> {
  new({
    required this._getCategories,
    required this._getCategoryClasses,
    required this._getOngoingClasses,
    required this._getUpcomingClasses,
    required this._getTopEducators,
  }) : super(const ExploreState());

  final GetExploreCategoriesUseCase _getCategories;
  final GetCategoryClassesUseCase _getCategoryClasses;
  final GetOngoingClassesUseCase _getOngoingClasses;
  final GetUpcomingClassesUseCase _getUpcomingClasses;
  final GetTopEducatorsUseCase _getTopEducators;

  Future<void> load() async {
    emit(
      state.copyWith(
        categories: state.categories.loading(),
        categoryClasses: state.categoryClasses.loading(),
        ongoing: state.ongoing.loading(),
        upcoming: state.upcoming.loading(),
        educators: state.educators.loading(),
      ),
    );
    await Future.wait([
      _loadCategories(),
      _loadCategoryClasses(),
      _loadSection(
        _getOngoingClasses(),
        current: () => state.ongoing,
        update: (s) => state.copyWith(ongoing: s),
      ),
      _loadSection(
        _getUpcomingClasses(),
        current: () => state.upcoming,
        update: (s) => state.copyWith(upcoming: s),
      ),
      _loadSection(
        _getTopEducators(),
        current: () => state.educators,
        update: (s) => state.copyWith(educators: s),
      ),
    ]);
  }

  Future<void> selectCategory(String? categoryId) async {
    if (categoryId == state.selectedCategoryId) return;
    emit(
      state.copyWith(
        selectedCategoryId: () => categoryId,
        categoryClasses: const ExploreSection(),
      ),
    );
    await _loadCategoryClasses();
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories();
    if (isClosed) return;
    result.match(
      (_) => emit(state.copyWith(categories: state.categories.failed())),
      (categories) {
        final selected = state.selectedCategoryId;
        final stillListed =
            selected == null || categories.any((c) => c.id == selected);
        emit(
          state.copyWith(
            categories: ExploreSection(
              status: ExploreSectionStatus.loaded,
              items: categories,
            ),
            selectedCategoryId: stillListed ? null : () => null,
          ),
        );
        if (!stillListed) unawaited(_loadCategoryClasses());
      },
    );
  }

  // A result for a category the learner has since moved away from is
  // dropped, so quick taps between chips never show the wrong classes.
  Future<void> _loadCategoryClasses() async {
    final categoryId = state.selectedCategoryId;
    final result = await _getCategoryClasses(categoryId: categoryId);
    if (isClosed || state.selectedCategoryId != categoryId) return;
    result.match(
      (_) =>
          emit(state.copyWith(categoryClasses: state.categoryClasses.failed())),
      (classes) => emit(
        state.copyWith(
          categoryClasses: ExploreSection(
            status: ExploreSectionStatus.loaded,
            items: classes,
          ),
        ),
      ),
    );
  }

  Future<void> _loadSection<T>(
    Future<Either<Failure, List<T>>> request, {
    required ExploreSection<T> Function() current,
    required ExploreState Function(ExploreSection<T>) update,
  }) async {
    final result = await request;
    if (isClosed) return;
    result.match(
      (_) => emit(update(current().failed())),
      (items) => emit(
        update(
          ExploreSection(status: ExploreSectionStatus.loaded, items: items),
        ),
      ),
    );
  }
}
