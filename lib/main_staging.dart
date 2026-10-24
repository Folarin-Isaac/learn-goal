import 'package:flutter/services.dart';
import 'package:lengoal/app/app.dart';
import 'package:lengoal/bootstrap.dart';
import 'package:lengoal/core/env/env.dart';

Future<void> main() async {
  await Env.load(Flavor.staging);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await bootstrap(() => const App(), enableNetworkLogging: true);
}
