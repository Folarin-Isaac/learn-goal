class ClassApiEndpoints {
  const new();

  static const String subscribedClasses = '/api/v1/Class/subscribed-classes';
  static const String recommendedClasses =
      '/api/v1/Landing/learner/upcoming-classes';
  static const String savedClasses = '/api/v1/Learner/GetLearnerSavedClasses';
  static const String classReplay = '/api/v1/Class/class-replay';

  static String classById(String id) => '/api/v1/Class/GetClass/$id';

  static String classEducators(String classId) =>
      '/api/v1/Class/get-class-educators/$classId';

  static String generateReferral(String classId) =>
      '/api/v1/Class/GenerateClassReferral/$classId';
}
