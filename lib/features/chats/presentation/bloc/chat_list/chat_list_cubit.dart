import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/domain/usecases/chat_usecases.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';

part 'chat_list_state.dart';

// One chat per enrolled class, across all goals (unlike the web, which
// only lists the active goal's: the app has no goal switcher on this tab).
// The class list comes from the shared subscribed-classes bloc; the API
// has no "last message" field, so each preview is the class's newest
// message, fetched a few at a time and refreshed once older than
// [freshFor].
class ChatListCubit extends Cubit<ChatListState> {
  new({
    required this._library,
    required this._getLatest,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now,
       super(const ChatListState());

  final ClassListBloc _library;
  final GetLatestChatMessageUseCase _getLatest;
  final DateTime Function() _now;

  static const Duration freshFor = Duration(seconds: 30);
  static const int _maxConcurrent = 4;

  StreamSubscription<ClassListState>? _subscription;
  final Map<String, DateTime> _fetchedAt = {};
  final Set<String> _inFlight = {};
  final List<String> _queue = [];
  int _active = 0;

  void start() {
    if (_subscription != null) return;
    _subscription = _library.stream.listen(_onLibrary);
    _library.add(const ClassListRequested());
    _onLibrary(_library.state);
  }

  void _onLibrary(ClassListState library) {
    if (isClosed) return;
    final status = switch (library.status) {
      ClassListStatus.loaded => ChatListStatus.loaded,
      ClassListStatus.failure when library.classes.isEmpty =>
        ChatListStatus.failure,
      ClassListStatus.failure => ChatListStatus.loaded,
      _ when library.classes.isNotEmpty => ChatListStatus.loaded,
      _ => ChatListStatus.loading,
    };
    emit(
      state.copyWith(
        status: status,
        classes: library.classes,
        errorMessage: () => library.errorMessage,
      ),
    );
    if (status == ChatListStatus.loaded) _refreshPreviews();
  }

  void search(String query) => emit(state.copyWith(query: query));

  // Coming back to the tab: the library refreshes itself if stale, and
  // previews older than [freshFor] are refetched behind the current ones.
  void refreshIfStale() {
    _library.add(const ClassListRequested());
    _refreshPreviews();
  }

  // Pull to refresh.
  Future<void> refresh() async {
    final done = _library.stream.firstWhere(
      (s) => !s.isRefreshing && s.status != ClassListStatus.loading,
    );
    _library.add(const ClassListRequested(force: true));
    await done.timeout(
      const Duration(seconds: 30),
      onTimeout: () => _library.state,
    );
    _fetchedAt.clear();
    _refreshPreviews();
  }

  // After leaving a chat, its preview reflects what was just said there.
  void refreshClass(String classId) {
    _fetchedAt.remove(classId);
    _enqueue(classId, first: true);
  }

  void _refreshPreviews() {
    for (final c in state.classes) {
      final at = _fetchedAt[c.id];
      if (at != null && _now().difference(at) < freshFor) continue;
      _enqueue(c.id);
    }
  }

  void _enqueue(String classId, {bool first = false}) {
    if (_inFlight.contains(classId) || _queue.contains(classId)) return;
    first ? _queue.insert(0, classId) : _queue.add(classId);
    _pump();
  }

  void _pump() {
    while (_active < _maxConcurrent && _queue.isNotEmpty) {
      final classId = _queue.removeAt(0);
      _active++;
      _inFlight.add(classId);
      unawaited(
        _fetch(classId).whenComplete(() {
          _active--;
          _inFlight.remove(classId);
          if (!isClosed) _pump();
        }),
      );
    }
  }

  Future<void> _fetch(String classId) async {
    final result = await _getLatest(classId);
    if (isClosed) return;
    result.match(
      (_) {
        if (state.latest.containsKey(classId)) return;
        emit(state.copyWith(latest: {...state.latest, classId: null}));
      },
      (message) {
        _fetchedAt[classId] = _now();
        emit(state.copyWith(latest: {...state.latest, classId: message}));
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
