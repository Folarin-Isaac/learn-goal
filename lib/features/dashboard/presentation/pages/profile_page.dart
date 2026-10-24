import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/profile/profile.dart';

class ProfilePage extends StatefulWidget {
  const new({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetLearnerProfileUseCase _getProfile = getIt();
  late LearnerProfile? _profile = _getProfile.cached;
  StreamSubscription<LearnerProfile?>? _subscription;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _subscription = _getProfile.stream.listen((profile) {
      if (mounted) setState(() => _profile = profile);
    });
    // Served from cache when the session warm-up already ran, so this is
    // usually a no-op rather than a visible load.
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  // Falls back to the token claims so the card still shows a name if the
  // profile call fails — the claims carry first/last name but no avatar.
  Future<void> _load() async {
    final result = await _getProfile();
    if (!mounted) return;
    if (result.getRight().toNullable() != null) return;

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

  Future<void> _confirmSignOut(BuildContext context) async {
    AppHaptics.selection();
    final confirmed = await AppConfirmDialog.show(
      context,
      title: context.l10n.profileSignOut,
      body: context.l10n.profileSignOutConfirmBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.profileSignOut,
    );
    if (confirmed == true && context.mounted) {
      setState(() => _isSigningOut = true);
      context.read<AuthBloc>().add(const AuthLoggedOut());
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    AppHaptics.selection();
    final confirmed = await AppConfirmDialog.show(
      context,
      title: context.l10n.profileDeleteConfirmTitle,
      body: context.l10n.profileDeleteConfirmBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.profileDeleteConfirmButton,
      confirmColor: const Color(0xFFE62E2E),
    );
    if (confirmed == true && context.mounted) {
      AppSnackbar.info(context.l10n.dashboardComingSoon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Entrance(
                child: Text(
                  context.l10n.profileTitle,
                  style: context.textTheme.headlineSmall,
                ),
              ),
              const Gap(AppSpacing.s24),
              Expanded(
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      final user = _profile;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Entrance(
                            index: 1,
                            child: _ProfileCard(profile: user),
                          ),
                          const Gap(AppSpacing.s24),
                          Entrance(
                            index: 2,
                            child: Text(
                              context.l10n.profileAccountSection,
                              style: context.textTheme.titleMedium,
                            ),
                          ),
                          const Gap(AppSpacing.s16),
                          Entrance(
                            index: 3,
                            child: _ProfileRow(
                              icon: Assets.icons.subscriptionHistoryIcon,
                              label: context.l10n.profileSubscriptionHistory,
                              onTap: () {
                                AppHaptics.selection();
                                unawaited(
                                  context.pushNamed(
                                    RouteNames.subscriptionHistory,
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap(AppSpacing.s16),
                          Entrance(
                            index: 4,
                            child: _ProfileRow(
                              icon: Assets.icons.supportIcon,
                              label: context.l10n.profileSupport,
                              onTap: () {
                                AppHaptics.selection();
                                unawaited(
                                  context.pushNamed(RouteNames.support),
                                );
                              },
                            ),
                          ),
                          const Gap(AppSpacing.s24),
                          Entrance(
                            index: 5,
                            child: Text(
                              context.l10n.profileSignOutSection,
                              style: context.textTheme.titleMedium,
                            ),
                          ),
                          const Gap(AppSpacing.s16),
                          Entrance(
                            index: 6,
                            child: _ProfileRow(
                              icon: Assets.icons.signOutIcon,
                              label: context.l10n.profileSignOut,
                              isBusy: _isSigningOut,
                              onTap: () => _confirmSignOut(context),
                            ),
                          ),
                          const Gap(AppSpacing.s24),
                          Entrance(
                            index: 7,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.profileDangerZoneSection,
                                    style: context.textTheme.titleMedium,
                                  ),
                                ),
                                Assets.icons.dangerIcon.svg(
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    context.colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(AppSpacing.s16),
                          Entrance(
                            index: 8,
                            child: _ProfileRow(
                              icon: Assets.icons.deleteAccountIcon,
                              label: context.l10n.profileDeleteAccount,
                              background: const Color(0xFFF9D6D6),
                              labelColor: const Color(0xFFE62E2E),
                              onTap: () => _confirmDeleteAccount(context),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: -1),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const new({required this.profile});

  final LearnerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final user = profile;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Row(
        children: [
          ProfileAvatar(imageUrl: user?.avatar, size: 48),
          const Gap(AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user?.email ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: user == null
                ? null
                : () {
                    AppHaptics.selection();
                    // No return value needed — the repository pushes the
                    // saved profile down the stream this page listens to.
                    unawaited(
                      context.pushNamed(RouteNames.updateProfile, extra: user),
                    );
                  },
            child: Assets.icons.editIconWhite.svg(width: 20, height: 20),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    this.background,
    this.labelColor,
    this.isBusy = false,
  });

  final SvgGenImage icon;
  final String label;
  final VoidCallback onTap;
  final Color? background;
  final Color? labelColor;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: Material(
        color: background ?? context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: isBusy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                icon.svg(width: 44, height: 44),
                const Gap(AppSpacing.s16),
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isBusy)
                  SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: labelColor ?? context.colors.primary,
                    ),
                  )
                else
                  Assets.icons.chevronRightIcon.svg(
                    width: 9,
                    height: 17,
                    colorFilter: ColorFilter.mode(
                      labelColor ?? context.colors.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
