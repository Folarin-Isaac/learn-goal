import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:lengoal/core/di/injector.dart';

class AppBlocObserver extends BlocObserver {
  new();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  bool enableNetworkLogging = false,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
    // Keeps Flutter's red error screen in debug mode — without this,
    // a build/layout crash just renders nothing, silently.
    FlutterError.presentError(details);
  };

  Bloc.observer = AppBlocObserver();

  await setupInjector(enableNetworkLogging: enableNetworkLogging);

  runApp(await builder());
}
