// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:lengoal/app/app.dart';
import 'package:lengoal/core/di/injector.dart';
import 'package:lengoal/core/env/env.dart';
import 'package:lengoal/features/auth/presentation/pages/login_page.dart';

void main() {
  group('App', () {
    // App() reads AuthRepository via getIt (through AuthBloc and
    // AppRouter), so DI has to be set up before pumping it, same as
    // bootstrap.dart does at real app startup. ApiClient inside DI reads
    // Env.baseUrl, so the env file has to be loaded first too.
    setUp(() async {
      await Env.load(Flavor.development);
      setupInjector();
    });
    tearDown(getIt.reset);

    testWidgets('renders LoginPage when unauthenticated', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
