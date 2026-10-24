import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/profile/domain/repositories/profile_repository.dart';

class UploadFileUseCase {
  new(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, String>> call({required String filePath}) =>
      _repository.uploadFile(filePath: filePath);
}
