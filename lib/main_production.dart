import 'package:flutter/services.dart';
import 'package:lengoal/app/app.dart';
import 'package:lengoal/bootstrap.dart';
import 'package:lengoal/core/env/env.dart';

Future<void> main() async {
  await Env.load(Flavor.production);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await bootstrap(() => const App());
}
