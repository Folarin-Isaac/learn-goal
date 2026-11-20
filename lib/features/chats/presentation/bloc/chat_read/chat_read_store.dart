import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';
import 'package:lengoal/core/widgets/nav_badges.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/domain/usecases/chat_usecases.dart';

// Unread state kept on this device only: the API has no read receipts or
// unread counts. For each class it remembers the newest message the
// learner has seen; a chat is unread when its newest message is someone
// else's and newer than that. A class seen for the first time is seeded
// with its current newest message, so installing the app (or a new class)
// doesn't light every chat up. Keyed per user so accounts don't mix.
class ChatReadStore {
  new(this._storage, this._getIdentity);

  final SecureStorageService _storage;
  final GetChatIdentityUseCase _getIdentity;

  static const String _keyPrefix = 'chat_last_seen_';

  // Class ids with unseen messages; drives the list dots and the nav badge.
  final ValueNotifier<Set<String>> unread = ValueNotifier(const {});

  Map<String, DateTime> _lastSeen = {};
  ChatIdentity? _identity;
  String? _storageKey;
  Future<void>? _loading;

  Future<ChatIdentity> identity() async {
    await _ensureLoaded();
    return _identity!;
  }

  Future<void> _ensureLoaded() async {
    final identity = await _getIdentity();
    final owner = identity.userId.isNotEmpty ? identity.userId : identity.email;
    final key = '$_keyPrefix$owner';
    if (key != _storageKey || _loading == null) {
      _identity = identity;
      _storageKey = key;
      _setUnread(const {});
      _loading = _read(key);
    }
    await _loading;
  }

  Future<void> _read(String key) async {
    final raw = await _storage.read(key);
    final map = <String, DateTime>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final MapEntry(key: classId, :value) in decoded.entries) {
          if (value is int) {
            map[classId] = DateTime.fromMillisecondsSinceEpoch(
              value,
              isUtc: true,
            );
          }
        }
      } on FormatException {
        map.clear();
      }
    }
    if (key == _storageKey) _lastSeen = map;
  }

  Future<DateTime?> lastSeen(String classId) async {
    await _ensureLoaded();
    return _lastSeen[classId];
  }

  // Called with each chat-list preview.
  Future<void> track(String classId, ChatMessage? latest) async {
    await _ensureLoaded();
    if (latest == null) {
      _remove(classId);
      return;
    }
    final seen = _lastSeen[classId];
    if (seen == null) {
      await _save(classId, latest.createdOn);
      return;
    }
    final isNew =
        latest.createdOn.isAfter(seen) && !(_identity?.owns(latest) ?? false);
    isNew ? _add(classId) : _remove(classId);
  }

  // The learner has the chat open and has seen up to [at].
  Future<void> markSeen(String classId, DateTime at) async {
    await _ensureLoaded();
    _remove(classId);
    final seen = _lastSeen[classId];
    if (seen != null && !at.isAfter(seen)) return;
    await _save(classId, at);
  }

  // Classes the learner is no longer enrolled in stop counting.
  void retainOnly(Set<String> classIds) {
    final kept = unread.value.where(classIds.contains).toSet();
    if (kept.length != unread.value.length) _setUnread(kept);
  }

  Future<void> _save(String classId, DateTime at) async {
    _lastSeen = {..._lastSeen, classId: at.toUtc()};
    final key = _storageKey;
    if (key == null) return;
    final encoded = jsonEncode({
      for (final e in _lastSeen.entries) e.key: e.value.millisecondsSinceEpoch,
    });
    await _storage.write(key, encoded);
  }

  void _add(String classId) {
    if (unread.value.contains(classId)) return;
    _setUnread({...unread.value, classId});
  }

  void _remove(String classId) {
    if (!unread.value.contains(classId)) return;
    _setUnread({...unread.value}..remove(classId));
  }

  void _setUnread(Set<String> value) {
    unread.value = value;
    NavBadges.chats.value = value.length;
  }
}
