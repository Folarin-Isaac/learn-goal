import 'package:lengoal/features/classes/data/models/class_educator_model.dart';
import 'package:lengoal/features/classes/data/models/lengoal_class_model.dart';
import 'package:lengoal/features/classes/domain/entities/class_referral.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';

abstract class ClassRemoteDataSource {
  Future<List<LengoalClassModel>> getSubscribedClasses({
    String? searchTerm,
    String? goalId,
  });

  Future<List<LengoalClassModel>> getRecommendedClasses({
    String? categoryId,
    String? goalName,
  });

  Future<List<LengoalClassModel>> searchClasses(String searchTerm);

  Future<List<LengoalClassModel>> getSavedClasses({String? searchTerm});

  Future<LengoalClassModel> getClass(String id);

  Future<void> saveClass(String classId);

  Future<void> unsaveClass(String classId);

  Future<List<ClassEducatorModel>> getClassEducators(String classId);

  Future<ClassReplay> getClassReplay(String classOutlineId);

  Future<ClassReferral> generateClassReferral(String classId);
}
