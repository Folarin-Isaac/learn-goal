import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_section.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/dashboard_top_bar.dart';
import 'package:lengoal/features/profile/profile.dart';

class DashboardPage extends StatefulWidget {
  const new({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GetLearnerProfileUseCase _getProfile = getIt();
  late LearnerProfile? _profile = _getProfile.cached;
  StreamSubscription<LearnerProfile?>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _getProfile.stream.listen((profile) {
      if (mounted) setState(() => _profile = profile);
    });
    unawaited(_resolveProfile());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _resolveProfile() async {
    final result = await _getProfile();
    final profile = result.getRight().toNullable();
    if (!mounted) return;
    if (profile != null) {
      setState(() => _profile = profile);
      return;
    }
    final user = await getIt<AuthRepository>().getCurrentUser();
    if (!mounted || user == null || _profile != null) return;
    setState(() {
      _profile = LearnerProfile(
        learnerId: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          AppSnackbar.info(context.l10n.dashboardSignedOutMessage);
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Builder(
            builder: (context) {
              final firstName = _profile?.firstName;
              const myClassesIndex = 3;
              final recommendedIndex =
                  myClassesIndex + 1 + mockMyClasses.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Entrance(
                      child: DashboardTopBar(
                        firstName: firstName,
                        avatarUrl: _profile?.avatar,
                      ),
                    ),
                    const Gap(AppSpacing.s24),
                    Entrance(
                      index: 1,
                      child: Text(
                        (firstName == null || firstName.isEmpty)
                            ? context.l10n.dashboardWelcomeFallback
                            : context.l10n.dashboardWelcome(firstName),
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    Entrance(
                      index: 2,
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          AppHaptics.selection();
                          AppSnackbar.info(context.l10n.dashboardComingSoon);
                        },
                        decoration: InputDecoration(
                          hintText: context.l10n.dashboardSearchHint,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Assets.icons.searchIcon.svg(
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.s24),
                    ClassSection(
                      title: context.l10n.dashboardMyClasses,
                      items: mockMyClasses,
                      onSeeAll: () => context.pushNamed(RouteNames.myClasses),
                      entranceIndex: myClassesIndex,
                    ),
                    const Gap(AppSpacing.s24),
                    ClassSection(
                      title: context.l10n.dashboardRecommendedClasses,
                      items: mockRecommendedClasses,
                      onSeeAll: () =>
                          context.pushNamed(RouteNames.recommendedClasses),
                      entranceIndex: recommendedIndex,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const DashboardBottomNav(),
      ),
    );
  }
}
