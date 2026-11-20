import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/domain/usecases/chat_usecases.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_draft/chat_draft_store.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_read/chat_read_store.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_thread/chat_thread_cache.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';

part 'chat_list_state.dart';

// One chat per enrolled class, across all goals (unlike the web, which
// only lists the active goal's: the app has no goal switcher on this tab).
// The class list comes from the shared subscribed-classes bloc; the API
// has no "last message" field, so each preview is the class's newest
// message, fetched a few at a time and refreshed once older than
// [freshFor]. The Chats tab lives as long as the home shell, so previews
// are also re-checked every [backgroundEvery] while the app is in the
// foreground; that keeps the unread badge on the nav bar current.
class ChatListCubit extends Cubit<ChatListState> {
  new({
    required this._library,
    required this._getLatest,
    required this._readStore,
    required this._draftStore,
    required this._threadCache,
    this.backgroundEvery = const Duration(minutes: 2),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now,
       super(const ChatListState());

  final ClassListBloc _library;
  final GetLatestChatMessageUseCase _getLatest;
  final ChatReadStore _readStore;
  final ChatDraftStore _draftStore;
  final ChatThreadCache _threadCache;
  final Duration backgroundEvery;
  final DateTime Function() _now;

  static const Duration freshFor = Duration(seconds: 30);
  static const int _maxConcurrent = 4;

  StreamSubscription<ClassListState>? _subscription;
  Timer? _timer;
  final Map<String, DateTime> _fetchedAt = {};
  final Set<String> _inFlight = {};
  final List<String> _queue = [];
  int _active = 0;

  void start() {
    if (_subscription != null) return;
    _readStore.unread.addListener(_onUnread);
    _draftStore.drafts.addListener(_onDrafts);
    unawaited(_draftStore.ready());
    _onUnread();
    _onDrafts();
    _subscription = _library.stream.listen(_onLibrary);
    _library.add(const ClassListRequested());
    _onLibrary(_library.state);
    resumeBackgroundRefresh();
  }

  void resumeBackgroundRefresh() {
    if (_timer != null || isClosed) return;
    _timer = Timer.periodic(backgroundEvery, (_) => _refreshPreviews());
  }

  void pauseBackgroundRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  void _onUnread() {
    if (!isClosed) emit(state.copyWith(unread: _readStore.unread.value));
  }

  void _onDrafts() {
    if (!isClosed) emit(state.copyWith(drafts: _draftStore.drafts.value));
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
    if (status == ChatListStatus.loaded) {
      _readStore.retainOnly(library.classIds);
      _refreshPreviews();
    }
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
    if (isClosed || state.status != ChatListStatus.loaded) return;
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
    final message = result.getRight().toNullable();
    if (result.isLeft()) {
      if (!state.latest.containsKey(classId)) {
        emit(state.copyWith(latest: {...state.latest, classId: null}));
      }
      return;
    }
    _fetchedAt[classId] = _now();
    emit(state.copyWith(latest: {...state.latest, classId: message}));
    await _readStore.track(classId, message);
  }

  // The Chats tab only goes away with the home shell (sign-out), so this
  // user's drafts and cached chats go with it rather than carrying over to
  // the next account.
  @override
  Future<void> close() async {
    pauseBackgroundRefresh();
    _readStore.unread.removeListener(_onUnread);
    _draftStore.drafts.removeListener(_onDrafts);
    _threadCache.clear();
    await _draftStore.clear();
    await _subscription?.cancel();
    await super.close();
  }
}
