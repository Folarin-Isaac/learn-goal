class ClassApiEndpoints {
  const new();

  static const String subscribedClasses = '/api/v1/Class/subscribed-classes';
  static const String allClasses = '/api/v1/Class/GetAllClasses';
  static const String savedClasses = '/api/v1/Learner/GetLearnerSavedClasses';

  static String classById(String id) => '/api/v1/Class/GetClass/$id';
}
