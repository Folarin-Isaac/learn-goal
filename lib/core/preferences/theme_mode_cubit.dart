import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/constants/storage_keys.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  new(this._storage) : super(ThemeMode.system);

  final SecureStorageService _storage;

  Future<void> load() async {
    final stored = await _storage.read(StorageKeys.themeMode);
    final mode = ThemeMode.values.where((m) => m.name == stored).firstOrNull;
    if (mode != null && !isClosed) emit(mode);
  }

  Future<void> select(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _storage.write(StorageKeys.themeMode, mode.name);
  }
}
