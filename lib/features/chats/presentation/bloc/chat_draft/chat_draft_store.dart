import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';
import 'package:lengoal/features/chats/domain/usecases/chat_usecases.dart';

// Unsent text per class chat. Kept in memory for instant reads and saved
// on the device (per user) so a half-typed message survives the app being
// closed. Writes are debounced: typing doesn't hit storage on every key.
// The chat list shows a draft as a "Draft:" preview. Cleared on sign-out.
class ChatDraftStore {
  new(this._storage, this._getIdentity);

  final SecureStorageService _storage;
  final GetChatIdentityUseCase _getIdentity;

  static const String _keyPrefix = 'chat_drafts_';
  static const Duration _saveDelay = Duration(milliseconds: 600);

  final ValueNotifier<Map<String, String>> drafts = ValueNotifier(const {});

  String? _storageKey;
  Future<void>? _loading;
  Timer? _saveTimer;

  // Resolves once the signed-in user's saved drafts are in [drafts].
  Future<void> ready() {
    return _loading ??= _load();
  }

  Future<void> _load() async {
    final identity = await _getIdentity();
    final owner = identity.userId.isNotEmpty ? identity.userId : identity.email;
    final key = '$_keyPrefix$owner';
    _storageKey = key;
    final raw = await _storage.read(key);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final saved = {
        for (final MapEntry(:key, :value) in decoded.entries)
          if (value is String && value.trim().isNotEmpty) key: value,
      };
      drafts.value = {...saved, ...drafts.value};
    } on FormatException {
      return;
    }
  }

  String of(String classId) => drafts.value[classId] ?? '';

  void save(String classId, String text) {
    final current = drafts.value[classId];
    if (text.trim().isEmpty) {
      if (current == null) return;
      drafts.value = {...drafts.value}..remove(classId);
    } else {
      if (current == text) return;
      drafts.value = {...drafts.value, classId: text};
    }
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, () => unawaited(_persist()));
  }

  Future<void> _persist() async {
    await ready();
    final key = _storageKey;
    if (key == null) return;
    final value = drafts.value;
    if (value.isEmpty) {
      await _storage.delete(key);
    } else {
      await _storage.write(key, jsonEncode(value));
    }
  }

  // Sign-out: forget this user's drafts, in memory and on the device.
  Future<void> clear() async {
    _saveTimer?.cancel();
    final key = _storageKey;
    drafts.value = const {};
    _loading = null;
    _storageKey = null;
    if (key != null) await _storage.delete(key);
  }
}
