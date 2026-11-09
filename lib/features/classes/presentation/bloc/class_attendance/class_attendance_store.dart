import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:lengoal/features/classes/domain/entities/class_attendance.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_attendance_usecase.dart';

// App-wide cache of the learner's attendance per class, feeding the
// "% Completed" bar on subscribed class cards. The endpoint is per class,
// so cards ask for their own row when they appear (`ensure`); results are
// kept for [_freshFor] and at most [_maxConcurrent] requests run at once so
// a long list never floods the API.
class ClassAttendanceStore extends ChangeNotifier {
  new(this._getClassAttendance);

  final GetClassAttendanceUseCase _getClassAttendance;

  static const Duration _freshFor = Duration(minutes: 3);
  static const int _maxConcurrent = 4;

  final Map<String, ClassAttendance> _byClass = {};
  final Map<String, DateTime> _fetchedAt = {};
  final Set<String> _inFlight = {};
  final Queue<String> _queue = Queue();
  int _running = 0;
  int _generation = 0;

  ClassAttendance? attendanceFor(String classId) => _byClass[classId];

  void ensure(String classId) {
    if (classId.isEmpty) return;
    if (_inFlight.contains(classId) || _queue.contains(classId)) return;
    final at = _fetchedAt[classId];
    if (at != null && DateTime.now().difference(at) < _freshFor) return;
    _queue.add(classId);
    _pump();
  }

  // Pull-to-refresh: refetch every class already on record. Values stay
  // visible meanwhile so bars don't flash back to the estimate.
  void refreshAll() {
    for (final id in _byClass.keys.toList()) {
      _fetchedAt.remove(id);
      ensure(id);
    }
  }

  // Sign-out: drop everything, and make any request still in flight land
  // nowhere so the next account never sees this learner's numbers.
  void clear() {
    _generation++;
    _byClass.clear();
    _fetchedAt.clear();
    _queue.clear();
    _inFlight.clear();
    _running = 0;
    notifyListeners();
  }

  void _pump() {
    while (_running < _maxConcurrent && _queue.isNotEmpty) {
      final id = _queue.removeFirst();
      _running++;
      _inFlight.add(id);
      unawaited(_load(id, _generation));
    }
  }

  Future<void> _load(String classId, int generation) async {
    final result = await _getClassAttendance(classId);
    if (generation != _generation) return;
    _running--;
    _inFlight.remove(classId);
    // A failure isn't cached, so the next `ensure` (e.g. when the card is
    // rebuilt after reconnecting) tries again; the bar keeps its estimate.
    final attendance = result.getRight().toNullable();
    if (attendance != null) {
      _byClass[classId] = attendance;
      _fetchedAt[classId] = DateTime.now();
      notifyListeners();
    }
    _pump();
  }
}
