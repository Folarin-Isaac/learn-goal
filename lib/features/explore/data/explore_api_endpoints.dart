class ExploreApiEndpoints {
  const new();

  static const String categories = '/api/v1/Landing/learner/categories';
  static const String categoryClasses =
      '/api/v1/Landing/learner/categories/classes';
  static const String ongoingClasses =
      '/api/v1/Landing/learner/ongoing-classes';
  static const String upcomingClasses =
      '/api/v1/Landing/learner/upcoming-classes';
  static const String topEducators = '/api/v1/Landing/learner/top-educators';
  static String educatorProfile(String educatorId) =>
      '/api/v1/Landing/learner/educators/$educatorId';
}
