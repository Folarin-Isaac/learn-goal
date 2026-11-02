import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/di/injector.dart';
import 'package:lengoal/core/network/connectivity_cubit.dart';
import 'package:lengoal/core/router/app_router.dart';
import 'package:lengoal/core/theme/app_theme.dart';
import 'package:lengoal/core/widgets/connectivity_banner.dart';
import 'package:lengoal/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:lengoal/l10n/l10n.dart';

class App extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(lazy: false, create: (_) => getIt<ConnectivityCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Lengoal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.router,
        builder: (context, child) =>
            ConnectivityBanner(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
