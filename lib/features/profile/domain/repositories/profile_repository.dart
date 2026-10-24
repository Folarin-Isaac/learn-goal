import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/profile/domain/entities/learner_profile.dart';

abstract class ProfileRepository {
  // Last profile fetched this session, served synchronously so screens
  // can paint real data on their first frame instead of a spinner.
  LearnerProfile? get cachedProfile;

  // Emits on every successful fetch and after every successful update, so
  // anything showing the learner's name or avatar stays in sync without
  // re-fetching or being re-entered.
  Stream<LearnerProfile?> get profileStream;

  // Returns the cache when there is one. Pass forceRefresh to go to the
  // network anyway.
  Future<Either<Failure, LearnerProfile>> getLearnerProfile({
    bool forceRefresh = false,
  });

  // Fire-and-forget warm-up used right after sign-in so the profile is
  // already in memory by the time the learner opens the profile page.
  Future<void> prefetchProfile();

  Future<Either<Failure, Unit>> updateLearnerProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? avatarUrl,
  });

  // Returns the hosted URL of the uploaded file, which is what gets
  // sent back as avatarUrl on update.
  Future<Either<Failure, String>> uploadFile({required String filePath});

  void clearCache();
}
