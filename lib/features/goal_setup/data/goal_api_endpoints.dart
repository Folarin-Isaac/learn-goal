// Kept local to this feature so the shared api_endpoints.dart doesn't
// grow with every feature's own endpoints.
class GoalApiEndpoints {
  const new();

  static const String categories = '/api/v1/Category/GetAllCategories';
  static const String goals = '/api/v1/Goal/GetAllGoals';
  static const String addLearnerGoal = '/api/v1/Learner/AddLearnerGoal';
}
