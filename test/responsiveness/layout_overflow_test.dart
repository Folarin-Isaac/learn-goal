import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';
import 'package:lengoal/core/theme/app_theme.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/chats/domain/usecases/chat_usecases.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_read/chat_read_store.dart';
import 'package:lengoal/features/classes/domain/entities/class_attendance.dart';
import 'package:lengoal/features/classes/domain/entities/class_session.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_attendance_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_recommended_classes_page_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_recommended_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_saved_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_subscribed_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/set_class_saved_usecase.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_attendance/class_attendance_store.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_discussion/class_discussion_cubit.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_card.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_detail_header.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/discussion_post_card.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_tile.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_material_row.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/day_strip.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';
import 'package:lengoal/features/explore/presentation/widgets/educator_profile/educator_profile_hero_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/educator_profile/educator_profile_stats_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_category_chips.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_class_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_educator_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_section_header.dart';

// Renders the app's main cards with long, realistic content on a small
// phone, a common phone, a large phone and a tablet, at normal and
// enlarged system text, and fails on any layout overflow.

class _FakeClassRepository implements ClassRepository {
  @override
  Future<Either<Failure, List<LengoalClass>>> getSavedClasses({
    String? searchTerm,
  }) async => const Right([]);

  @override
  Future<Either<Failure, ClassAttendance>> getClassAttendance(
    String classId,
  ) async => const Left(ServerFailure());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _sizes = <String, Size>{
  'small phone 320x568': Size(320, 568),
  'phone 360x800': Size(360, 800),
  'large phone 412x915': Size(412, 915),
  'tablet 768x1024': Size(768, 1024),
};

const _textScales = <double>[1, 1.3, 2];

const _longTitle =
    'Advanced Project Management Professional Certification Bootcamp '
    'Cohort 12';
const _longName = 'Oluwaseun Adebayo-Okonkwo Chukwuemeka';
const _longCategory = 'Personnel and Human Resources Management';

final _now = DateTime(2026, 11, 18, 10);

LengoalClass _class({bool subscribed = false, bool free = false}) =>
    LengoalClass(
      id: 'c1',
      cohortName: _longTitle,
      educatorName: _longName,
      educatorTierName: 'Senior Certified Educator',
      price: free ? 0 : 1250000,
      discountPrice: free ? null : 990000,
      isFree: free,
      isSubscribed: subscribed,
      numberOfSubscribers: 1234,
      goalName: 'Project Management Professional (PMP)',
      categoryName: _longCategory,
      startDate: _now.subtract(const Duration(days: 3)),
      endDate: _now.add(const Duration(days: 60)),
      sessions: [
        ClassSession(
          id: 's1',
          topic: 'Risk management, stakeholder engagement and procurement',
          startDate: _now,
          endDate: _now.add(const Duration(hours: 2)),
        ),
      ],
    );

final _post = DiscussionPost(
  id: 'p1',
  senderName: _longName,
  content: List.filled(40, 'This is a very long discussion message.').join(' '),
  createdAt: _now,
  role: DiscussionUserRole.educator,
  isEdited: true,
);

final Map<String, Widget Function(Size size)> _cases = {
  'ExploreClassCard (running)': (size) => ExploreClassCard(
    item: ExploreClass(lengoalClass: _class(), completion: 0.42),
    width: (size.width * 0.82).clamp(260, 340),
  ),
  'ExploreClassCard (upcoming)': (size) => ExploreClassCard(
    item: ExploreClass(
      lengoalClass: _class(),
      enrollmentLimit: 50,
      availableSlots: 12,
    ),
    width: (size.width * 0.82).clamp(260, 340),
    kind: ExploreClassCardKind.upcoming,
  ),
  'ExploreEducatorCard': (size) => ExploreEducatorCard(
    educator: const TopEducator(
      id: 'e1',
      name: _longName,
      categories: [_longCategory, 'Project Management'],
      rating: 4.8,
      reviewCount: 1234,
      activeClassCount: 12,
    ),
    width: (size.width * 0.82).clamp(260, 340),
  ),
  'ExploreSectionHeader': (_) => const ExploreSectionHeader(
    eyebrow: 'EXPLORE BY CATEGORY',
    color: AppColors.successGreen,
    title: 'What do you want to master?',
    subtitle:
        'Browse across every learning domain, from professional '
        'certifications to creative skills.',
  ),
  'ExploreCategoryChips': (_) => ExploreCategoryChips(
    categories: const [
      ExploreCategory(id: 'a', name: _longCategory, activeClassCount: 3),
      ExploreCategory(id: 'b', name: 'Finance', activeClassCount: 9),
    ],
    selectedId: 'a',
    isLoading: false,
    onSelected: (_) {},
  ),
  'ClassCard (dashboard row)': (size) => ClassCard(
    item: ClassSummary.fromClass(_class(subscribed: true)),
    width: ((size.width - 48) / 2.2).clamp(140, 200),
  ),
  'ClassListTile': (_) => ClassListTile(
    item: ClassSummary.fromClass(_class(subscribed: true)),
    showFavorite: true,
  ),
  'CalendarSessionCard': (_) => const CalendarSessionCard(
    session: CalendarSession(
      title: '$_longTitle · Risk management and stakeholder engagement',
      day: 18,
      dateLabel: 'Wednesday, 18 November',
      timeRange: '10:00 AM - 12:00 PM',
      status: CalendarSessionStatus.ongoing,
      meetingUrl: '',
      host: _longName,
    ),
  ),
  'DayStrip (calendar week)': (_) => DayStrip(
    days: [
      for (var i = 0; i < 7; i++)
        CalendarDay(date: DateTime(2026, 11, 15 + i), hasSessions: i.isEven),
    ],
    selectedDate: DateTime(2026, 11, 18),
    onSelected: (_) {},
  ),
  'ClassDetailHeader (paid)': (_) => ClassDetailHeader(
    detail: ClassDetail.fromClass(_class(), now: _now),
    isSharing: false,
  ),
  'ClassDetailHeader (free, enrolled)': (_) => ClassDetailHeader(
    detail: ClassDetail.fromClass(
      _class(subscribed: true, free: true),
      now: _now,
    ),
    isSharing: false,
  ),
  'ClassMaterialRow': (_) => const ClassMaterialRow(
    material: ClassMaterial(
      name: 'Week 4 - Risk Register Template and Worked Examples (Final).xlsx',
      fileType: MaterialFileType.excel,
      url: 'https://example.com/a.xlsx',
    ),
  ),
  'DiscussionPostCard (expanded thread)': (_) => DiscussionPostCard(
    post: _post,
    replies: DiscussionReplies(status: DiscussionStatus.loaded, items: [_post]),
    isExpanded: true,
    canParticipate: true,
    isSendingReply: false,
    onToggleReplies: () {},
    onReply: (_) async => true,
  ),
  'EducatorProfileHeroCard': (_) => const EducatorProfileHeroCard(
    profile: EducatorProfile(
      id: 'e1',
      name: _longName,
      tierName: 'Senior Certified Educator',
      rating: 4.8,
      reviewCount: 1234,
      yearsOfExperience: 12,
      experiencePeriod: '2014 - Present',
      categories: [_longCategory, 'A Level', 'Project Management'],
      badges: ['Lengoal Cohort Guarantee'],
    ),
  ),
  'EducatorProfileStatsCard': (_) => const EducatorProfileStatsCard(
    profile: EducatorProfile(
      id: 'e1',
      name: _longName,
      learnersTaught: 123456,
      hoursTaught: 98765,
      cohortsDelivered: 1234,
    ),
  ),
};

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

class _FakeAuthRepository extends Fake implements AuthRepository;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont('Inter', 'assets/fonts/Inter-VariableFont.ttf');
    await _loadFont('Manrope', 'assets/fonts/Manrope-VariableFont.ttf');
    final repository = _FakeClassRepository();
    getIt
      ..registerLazySingleton(
        () => ClassAttendanceStore(GetClassAttendanceUseCase(repository)),
      )
      ..registerLazySingleton<ClassListBloc>(
        () => ClassListBloc(
          source: ClassListSource.saved,
          getSubscribedClassesUseCase: GetSubscribedClassesUseCase(repository),
          getRecommendedClassesUseCase: GetRecommendedClassesUseCase(
            repository,
          ),
          getRecommendedClassesPageUseCase: GetRecommendedClassesPageUseCase(
            repository,
          ),
          getSavedClassesUseCase: GetSavedClassesUseCase(repository),
          setClassSavedUseCase: SetClassSavedUseCase(repository),
        ),
        instanceName: ClassListSource.saved.name,
      )
      ..registerLazySingleton(
        () => ChatReadStore(
          SecureStorageService(),
          GetChatIdentityUseCase(_FakeAuthRepository()),
        ),
      );
  });

  tearDownAll(getIt.reset);

  for (final MapEntry(key: name, value: build) in _cases.entries) {
    group(name, () {
      for (final MapEntry(key: label, value: size) in _sizes.entries) {
        for (final scale in _textScales) {
          testWidgets('$label, text x$scale', (tester) async {
            tester.view
              ..physicalSize = size
              ..devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: build(size),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(seconds: 1));
            await tester.pump(const Duration(seconds: 1));
          });
        }
      }
    });
  }
}
