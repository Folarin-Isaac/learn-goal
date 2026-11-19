import 'package:lengoal/features/classes/data/models/class_educator_model.dart';
import 'package:lengoal/features/classes/data/models/lengoal_class_model.dart';
import 'package:lengoal/features/classes/domain/entities/class_attendance.dart';
import 'package:lengoal/features/classes/domain/entities/class_referral.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_access.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_status.dart';

abstract class ClassRemoteDataSource {
  Future<List<LengoalClassModel>> getSubscribedClasses({
    String? searchTerm,
    String? goalId,
  });

  Future<List<LengoalClassModel>> getRecommendedClasses({
    String? categoryId,
    String? goalName,
    String? goalId,
    int? pageSize,
  });

  Future<({List<LengoalClassModel> items, bool hasMore})> searchClasses(
    String searchTerm, {
    required int page,
    required int pageSize,
  });

  Future<({List<LengoalClassModel> items, bool hasMore})>
  getRecommendedClassesPage({
    required int page,
    required int pageSize,
    String? categoryId,
    String? goalId,
  });

  Future<List<LengoalClassModel>> getSavedClasses({String? searchTerm});

  Future<LengoalClassModel> getClass(String id);

  Future<void> saveClass(String classId);

  Future<void> unsaveClass(String classId);

  Future<List<ClassEducatorModel>> getClassEducators(String classId);

  Future<ClassReplay> getClassReplay(String classOutlineId);

  Future<ClassReferral> generateClassReferral(String classId);

  Future<ClassAttendance> getClassAttendance(String classId);

  Future<LiveClassAccess> joinLiveClass(String classOutlineId);

  Future<LiveClassStatus> getLiveClassStatus(String classOutlineId);
}
