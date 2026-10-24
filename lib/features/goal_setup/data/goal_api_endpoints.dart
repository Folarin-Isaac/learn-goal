// Kept local to this feature so the shared api_endpoints.dart doesn't
// grow with every feature's own endpoints.
class GoalApiEndpoints {
  const new();

  static const String categories = '/api/v1/Category/GetAllCategories';
  static const String goals = '/api/v1/Goal/GetAllGoals';

  // Step 3 ("Create Goal") is not wired yet — the backend endpoint for
  // submitting examTargetDate is still being confirmed. This path is the
  // old placeholder and is not deployed.
  static const String saveGoal = '/goals';
  static const String examStages = '/goals/exam-stages';
}
