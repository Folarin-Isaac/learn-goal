import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lengoal/app/app.dart';
import 'package:lengoal/core/di/injector.dart';
import 'package:lengoal/core/env/env.dart';
import 'package:lengoal/core/widgets/content_width_limiter.dart';
import 'package:lengoal/features/auth/presentation/pages/login_page.dart';

const _sizes = <String, Size>{
  'small phone 320x568': Size(320, 568),
  'phone 360x800': Size(360, 800),
  'tablet 768x1024': Size(768, 1024),
};

const _textScales = <double>[1, 1.3, 2];

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('Inter', 'assets/fonts/Inter-VariableFont.ttf');
    await _loadFont('Manrope', 'assets/fonts/Manrope-VariableFont.ttf');
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (call) async => ['wifi'],
      )
      ..setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (call) async => call.method == 'readAll' ? <String, String>{} : null,
      );
    await Env.load(Flavor.development);
    await setupInjector();
  });
  tearDown(getIt.reset);

  for (final MapEntry(key: label, value: size) in _sizes.entries) {
    for (final scale in _textScales) {
      testWidgets('LoginPage, $label, text x$scale', (tester) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
        expect(
          tester.getSize(find.byType(LoginPage)).width,
          lessThanOrEqualTo(ContentWidthLimiter.maxWidth),
        );
      });
    }
  }
}
