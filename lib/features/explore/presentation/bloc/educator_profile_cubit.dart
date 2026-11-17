import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';
import 'package:lengoal/features/explore/domain/usecases/get_explore_feed_usecases.dart';

enum EducatorProfileStatus { loading, loaded, failure }

class EducatorProfileState extends Equatable {
  const new({this.status = EducatorProfileStatus.loading, this.profile});

  final EducatorProfileStatus status;
  final EducatorProfile? profile;

  @override
  List<Object?> get props => [status, profile];
}

class EducatorProfileCubit extends Cubit<EducatorProfileState> {
  new(this._getEducatorProfile) : super(const EducatorProfileState());

  final GetEducatorProfileUseCase _getEducatorProfile;

  // A failed refresh keeps the profile already on screen.
  Future<void> load(String educatorId) async {
    final current = state.profile;
    emit(
      EducatorProfileState(
        status: current == null
            ? EducatorProfileStatus.loading
            : EducatorProfileStatus.loaded,
        profile: current,
      ),
    );
    final result = await _getEducatorProfile(educatorId);
    if (isClosed) return;
    result.match(
      (_) => emit(
        EducatorProfileState(
          status: current == null
              ? EducatorProfileStatus.failure
              : EducatorProfileStatus.loaded,
          profile: current,
        ),
      ),
      (profile) => emit(
        EducatorProfileState(
          status: EducatorProfileStatus.loaded,
          profile: profile,
        ),
      ),
    );
  }
}
