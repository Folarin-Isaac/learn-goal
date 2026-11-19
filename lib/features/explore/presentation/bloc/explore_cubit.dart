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
//
// The page lives as long as the home shell, so this cubit doubles as the
// Explore cache: each category's classes are remembered, and anything older
// than [freshFor] is refetched quietly (what's on screen stays put) when
// the learner comes back to the tab or picks that category again.
class ExploreCubit extends Cubit<ExploreState> {
  new({
    required this._getCategories,
    required this._getCategoryClasses,
    required this._getOngoingClasses,
    required this._getUpcomingClasses,
    required this._getTopEducators,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now,
       super(const ExploreState());

  final GetExploreCategoriesUseCase _getCategories;
  final GetCategoryClassesUseCase _getCategoryClasses;
  final GetOngoingClassesUseCase _getOngoingClasses;
  final GetUpcomingClassesUseCase _getUpcomingClasses;
  final GetTopEducatorsUseCase _getTopEducators;
  final DateTime Function() _now;

  static const Duration freshFor = Duration(minutes: 3);

  final Map<String?, _CachedClasses> _byCategory = {};
  final Set<String?> _inFlight = {};
  DateTime? _feedLoadedAt;
  bool _feedLoading = false;

  bool _isFresh(DateTime? at) => at != null && _now().difference(at) < freshFor;

  // Pull-to-refresh: everything is refetched now, and other categories are
  // marked stale so they refresh the next time they're picked.
  Future<void> load() async {
    _byCategory.updateAll((_, cached) => cached.stale());
    emit(
      state.copyWith(
        categories: state.categories.loading(),
        categoryClasses: state.categoryClasses.loading(),
        ongoing: state.ongoing.loading(),
        upcoming: state.upcoming.loading(),
        educators: state.educators.loading(),
      ),
    );
    await Future.wait([_loadFeed(), _loadCategoryClasses()]);
  }

  // Called whenever Explore comes back into view.
  Future<void> refreshIfStale() async {
    if (_feedLoading) return;
    await Future.wait([
      if (!_isFresh(_feedLoadedAt)) _loadFeed(),
      if (!_isFresh(_byCategory[state.selectedCategoryId]?.at))
        _loadCategoryClasses(),
    ]);
  }

  Future<void> selectCategory(String? categoryId) async {
    if (categoryId == state.selectedCategoryId) return;
    final cached = _byCategory[categoryId];
    emit(
      state.copyWith(
        selectedCategoryId: () => categoryId,
        categoryClasses: cached == null
            ? const ExploreSection()
            : ExploreSection(
                status: ExploreSectionStatus.loaded,
                items: cached.classes,
              ),
      ),
    );
    if (_isFresh(cached?.at)) return;
    await _loadCategoryClasses();
  }

  Future<void> _loadFeed() async {
    _feedLoading = true;
    final results = await Future.wait([
      _loadCategories(),
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
    _feedLoading = false;
    if (results.every((ok) => ok)) _feedLoadedAt = _now();
  }

  Future<bool> _loadCategories() async {
    final result = await _getCategories();
    if (isClosed) return false;
    return result.match<bool>(
      (_) {
        emit(state.copyWith(categories: state.categories.failed()));
        return false;
      },
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
        return true;
      },
    );
  }

  // A result for a category the learner has since moved away from is still
  // cached, but never shown, so quick taps between chips never show the
  // wrong classes.
  Future<void> _loadCategoryClasses() async {
    final categoryId = state.selectedCategoryId;
    if (!_inFlight.add(categoryId)) return;
    final result = await _getCategoryClasses(categoryId: categoryId);
    _inFlight.remove(categoryId);
    if (isClosed) return;
    result.match(
      (_) {
        if (state.selectedCategoryId != categoryId) return;
        emit(state.copyWith(categoryClasses: state.categoryClasses.failed()));
      },
      (classes) {
        _byCategory[categoryId] = _CachedClasses(classes, _now());
        if (state.selectedCategoryId != categoryId) return;
        emit(
          state.copyWith(
            categoryClasses: ExploreSection(
              status: ExploreSectionStatus.loaded,
              items: classes,
            ),
          ),
        );
      },
    );
  }

  Future<bool> _loadSection<T>(
    Future<Either<Failure, List<T>>> request, {
    required ExploreSection<T> Function() current,
    required ExploreState Function(ExploreSection<T>) update,
  }) async {
    final result = await request;
    if (isClosed) return false;
    return result.match<bool>(
      (_) {
        emit(update(current().failed()));
        return false;
      },
      (items) {
        emit(
          update(
            ExploreSection(status: ExploreSectionStatus.loaded, items: items),
          ),
        );
        return true;
      },
    );
  }
}

class _CachedClasses {
  const new(this.classes, this.at);

  final List<ExploreClass> classes;
  final DateTime? at;

  _CachedClasses stale() => _CachedClasses(classes, null);
}
