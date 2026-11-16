part of 'explore_cubit.dart';

enum ExploreSectionStatus { loading, loaded, failure }

class ExploreSection<T> extends Equatable {
  const new({
    this.status = ExploreSectionStatus.loading,
    this.items = const [],
  });

  final ExploreSectionStatus status;
  final List<T> items;

  ExploreSection<T> loading() => ExploreSection(items: items);

  // A failed refresh keeps what was already on screen.
  ExploreSection<T> failed() => ExploreSection(
    status: items.isEmpty
        ? ExploreSectionStatus.failure
        : ExploreSectionStatus.loaded,
    items: items,
  );

  @override
  List<Object?> get props => [status, items];
}

class ExploreState extends Equatable {
  const new({
    this.categories = const ExploreSection(),
    this.selectedCategoryId,
    this.categoryClasses = const ExploreSection(),
    this.ongoing = const ExploreSection(),
    this.upcoming = const ExploreSection(),
    this.educators = const ExploreSection(),
  });

  final ExploreSection<ExploreCategory> categories;
  final String? selectedCategoryId;
  final ExploreSection<ExploreClass> categoryClasses;
  final ExploreSection<ExploreClass> ongoing;
  final ExploreSection<ExploreClass> upcoming;
  final ExploreSection<TopEducator> educators;

  ExploreState copyWith({
    ExploreSection<ExploreCategory>? categories,
    String? Function()? selectedCategoryId,
    ExploreSection<ExploreClass>? categoryClasses,
    ExploreSection<ExploreClass>? ongoing,
    ExploreSection<ExploreClass>? upcoming,
    ExploreSection<TopEducator>? educators,
  }) {
    return ExploreState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId == null
          ? this.selectedCategoryId
          : selectedCategoryId(),
      categoryClasses: categoryClasses ?? this.categoryClasses,
      ongoing: ongoing ?? this.ongoing,
      upcoming: upcoming ?? this.upcoming,
      educators: educators ?? this.educators,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    selectedCategoryId,
    categoryClasses,
    ongoing,
    upcoming,
    educators,
  ];
}
