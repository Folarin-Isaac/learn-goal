import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/di/injector.dart';
import 'package:lengoal/core/network/connectivity_cubit.dart';
import 'package:lengoal/core/preferences/theme_mode_cubit.dart';
import 'package:lengoal/core/router/app_router.dart';
import 'package:lengoal/core/theme/app_theme.dart';
import 'package:lengoal/core/widgets/connectivity_banner.dart';
import 'package:lengoal/core/widgets/content_width_limiter.dart';
import 'package:lengoal/core/widgets/splash_overlay.dart';
import 'package:lengoal/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:lengoal/l10n/l10n.dart';

class App extends StatelessWidget {
  const new({super.key});

  static SystemUiOverlayStyle _systemBarsStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final icons = isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: icons,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: icons,
      systemNavigationBarContrastEnforced: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(lazy: false, create: (_) => getIt<ConnectivityCubit>()),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        bloc: getIt<ThemeModeCubit>(),
        builder: (context, themeMode) => MaterialApp.router(
          title: 'Lengoal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.router,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: _systemBarsStyle(Theme.of(context).brightness),
            child: SplashOverlay(
              child: ContentWidthLimiter(
                child: ConnectivityBanner(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
