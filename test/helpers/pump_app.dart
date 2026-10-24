import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lengoal/l10n/l10n.dart';

extension PumpApp on WidgetTester {
  /// Wraps [widget] in a bare-bones MaterialApp with localization set up,
  /// for testing a single widget/page in isolation. For anything that
  /// needs BlocProviders (most feature widgets), wrap with those before
  /// passing them in here, e.g.:
  /// `tester.pumpApp(BlocProvider.value(value: bloc, child: const
  /// LoginPage()))`
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}
