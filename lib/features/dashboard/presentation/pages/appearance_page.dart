import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/core/preferences/theme_mode_cubit.dart';

class AppearancePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_outlined,
        title: l10n.profileAppearanceSystem,
        subtitle: l10n.profileAppearanceSystemHint,
      ),
      (
        mode: ThemeMode.light,
        icon: Icons.light_mode_outlined,
        title: l10n.profileAppearanceLight,
        subtitle: l10n.profileAppearanceLightHint,
      ),
      (
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_outlined,
        title: l10n.profileAppearanceDark,
        subtitle: l10n.profileAppearanceDarkHint,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Entrance(
                child: Row(
                  children: [
                    const AppBackButton(),
                    const Gap(AppSpacing.s8),
                    Expanded(
                      child: Text(
                        l10n.profileAppearance,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s24),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<ThemeModeCubit, ThemeMode>(
                    bloc: getIt<ThemeModeCubit>(),
                    builder: (context, current) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Entrance(
                          index: 1,
                          child: Text(
                            l10n.profileAppearanceIntro,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        const Gap(AppSpacing.s16),
                        for (var i = 0; i < options.length; i++) ...[
                          if (i > 0) const Gap(AppSpacing.s16),
                          Entrance(
                            index: i + 2,
                            child: _AppearanceOption(
                              icon: options[i].icon,
                              title: options[i].title,
                              subtitle: options[i].subtitle,
                              isSelected: options[i].mode == current,
                              onTap: () => unawaited(
                                getIt<ThemeModeCubit>().select(options[i].mode),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    return Semantics(
      selected: isSelected,
      button: true,
      child: Pressable(
        child: Material(
          color: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.r16),
            side: BorderSide(
              color: isSelected ? accent : context.colors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r16),
            ),
            onTap: isSelected
                ? null
                : () {
                    AppHaptics.selection();
                    onTap();
                  },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.12),
                    ),
                    child: Icon(icon, color: accent),
                  ),
                  const Gap(AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(AppSpacing.s4),
                        Text(subtitle, style: context.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(isSelected),
                      color: isSelected
                          ? accent
                          : context.colors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
