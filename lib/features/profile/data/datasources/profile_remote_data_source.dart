import 'package:lengoal/features/profile/data/models/learner_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<LearnerProfileModel> getLearnerProfile();

  Future<void> updateLearnerProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? avatarUrl,
  });

  Future<String> uploadFile({required String filePath});
}
