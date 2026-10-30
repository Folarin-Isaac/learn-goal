import 'package:lengoal/features/classes/data/models/lengoal_class_model.dart';

abstract class ClassRemoteDataSource {
  Future<List<LengoalClassModel>> getSubscribedClasses({String? searchTerm});

  Future<List<LengoalClassModel>> getAllClasses({String? searchTerm});

  Future<List<LengoalClassModel>> getSavedClasses({String? searchTerm});

  Future<LengoalClassModel> getClass(String id);
}
