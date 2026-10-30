import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';
import 'package:lengoal/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lengoal/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:lengoal/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/login_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/register_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:lengoal/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:lengoal/features/classes/data/datasources/class_remote_data_source.dart';
import 'package:lengoal/features/classes/data/datasources/class_remote_data_source_impl.dart';
import 'package:lengoal/features/classes/data/repositories/class_repository_impl.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';
import 'package:lengoal/features/classes/domain/usecases/generate_class_referral_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_educators_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_replay_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_recommended_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_saved_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_subscribed_classes_usecase.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/goal_setup/data/datasources/goal_remote_data_source.dart';
import 'package:lengoal/features/goal_setup/data/datasources/goal_remote_data_source_impl.dart';
import 'package:lengoal/features/goal_setup/data/repositories/goal_repository_impl.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_exam_stages_usecase.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_goals_usecase.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_categories_usecase.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/save_goal_usecase.dart';
import 'package:lengoal/features/goal_setup/presentation/bloc/goal_setup/goal_setup_bloc.dart';
import 'package:lengoal/features/profile/profile.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjector({bool enableNetworkLogging = false}) async {
  getIt
    ..registerLazySingleton(SecureStorageService.new)
    ..registerLazySingleton(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()))
    ..registerLazySingleton(
      () => ApiClient(getIt(), enableLogging: enableNetworkLogging),
    );

  _initAuth();
  _initGoalSetup();
  _initProfile();
  _initClasses();

  getIt<ProfileSessionSync>().start();
}

void _initProfile() {
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: getIt(),
        networkInfo: getIt(),
      ),
    )
    ..registerLazySingleton(
      () => ProfileSessionSync(
        authRepository: getIt(),
        profileRepository: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetLearnerProfileUseCase(getIt()))
    ..registerLazySingleton(() => UpdateLearnerProfileUseCase(getIt()))
    ..registerLazySingleton(() => UploadFileUseCase(getIt()))
    ..registerFactory(
      () => UpdateProfileBloc(
        getLearnerProfileUseCase: getIt(),
        updateLearnerProfileUseCase: getIt(),
        uploadFileUseCase: getIt(),
      ),
    );
}

void _initClasses() {
  getIt
    ..registerLazySingleton<ClassRemoteDataSource>(
      () => ClassRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ClassRepository>(
      () =>
          ClassRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
    )
    ..registerLazySingleton(() => GetSubscribedClassesUseCase(getIt()))
    ..registerLazySingleton(() => GetRecommendedClassesUseCase(getIt()))
    ..registerLazySingleton(() => GetSavedClassesUseCase(getIt()))
    ..registerLazySingleton(() => GetClassUseCase(getIt()))
    ..registerLazySingleton(() => GetClassEducatorsUseCase(getIt()))
    ..registerLazySingleton(() => GetClassReplayUseCase(getIt()))
    ..registerLazySingleton(() => GenerateClassReferralUseCase(getIt()))
    ..registerFactoryParam<ClassListBloc, ClassListSource, void>(
      (source, _) => ClassListBloc(
        source: source,
        getSubscribedClassesUseCase: getIt(),
        getRecommendedClassesUseCase: getIt(),
        getSavedClassesUseCase: getIt(),
      ),
    )
    ..registerFactoryParam<ClassDetailBloc, LengoalClass, void>(
      (initial, _) => ClassDetailBloc(
        initial: initial,
        getClassUseCase: getIt(),
        getClassEducatorsUseCase: getIt(),
        getClassReplayUseCase: getIt(),
        generateClassReferralUseCase: getIt(),
      ),
    );
}

void _initAuth() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        secureStorage: getIt(),
        networkInfo: getIt(),
      ),
    )
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerLazySingleton(() => RegisterUseCase(getIt()))
    ..registerLazySingleton(() => VerifyOtpUseCase(getIt()))
    ..registerLazySingleton(() => ResendOtpUseCase(getIt()))
    ..registerLazySingleton(() => ForgotPasswordUseCase(getIt()))
    ..registerLazySingleton(() => ResetPasswordUseCase(getIt()))
    ..registerLazySingleton(() => LogoutUseCase(getIt()))
    ..registerFactory(() => AuthBloc(authRepository: getIt()));
}

void _initGoalSetup() {
  getIt
    ..registerLazySingleton<GoalRemoteDataSource>(
      () => GoalRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<GoalRepository>(
      () => GoalRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
    )
    ..registerLazySingleton(() => GetCategoriesUseCase(getIt()))
    ..registerLazySingleton(() => GetGoalsUseCase(getIt()))
    ..registerLazySingleton(() => GetExamStagesUseCase(getIt()))
    ..registerLazySingleton(() => SaveGoalUseCase(getIt()))
    ..registerFactory(
      () => GoalSetupBloc(
        getCategoriesUseCase: getIt(),
        getGoalsUseCase: getIt(),
        getExamStagesUseCase: getIt(),
        saveGoalUseCase: getIt(),
      ),
    );
}
