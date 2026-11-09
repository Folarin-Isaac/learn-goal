import 'package:flutter/foundation.dart';

enum ClassesHubTab { subscribed, saved }

class ClassesHubTabRequest {
  const new _();

  static final ValueNotifier<ClassesHubTab?> pending = ValueNotifier(null);
}
