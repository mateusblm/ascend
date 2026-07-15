import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemPreferences {
  const SystemPreferences({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reduceMotion = false,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool reduceMotion;

  SystemPreferences copyWith({bool? soundEnabled, bool? hapticsEnabled, bool? reduceMotion}) =>
      SystemPreferences(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reduceMotion: reduceMotion ?? this.reduceMotion,
      );
}

class SystemPreferencesService {
  static const _soundKey = 'ascend_system_sound_enabled';
  static const _hapticsKey = 'ascend_system_haptics_enabled';
  static const _reduceMotionKey = 'ascend_system_reduce_motion';

  Future<SystemPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SystemPreferences(
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      reduceMotion: prefs.getBool(_reduceMotionKey) ?? false,
    );
  }

  Future<void> save(SystemPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_soundKey, value.soundEnabled),
      prefs.setBool(_hapticsKey, value.hapticsEnabled),
      prefs.setBool(_reduceMotionKey, value.reduceMotion),
    ]);
  }
}

final systemPreferencesProvider =
    StateNotifierProvider<SystemPreferencesNotifier, SystemPreferences>((ref) {
      return SystemPreferencesNotifier(SystemPreferencesService());
    });

class SystemPreferencesNotifier extends StateNotifier<SystemPreferences> {
  SystemPreferencesNotifier(this._service) : super(const SystemPreferences()) {
    unawaited(_load());
  }

  final SystemPreferencesService _service;

  Future<void> _load() async {
    try {
      state = await _service.load();
    } catch (_) {
      // A interface permanece útil com os padrões se a preferência local falhar.
    }
  }

  Future<void> setSoundEnabled(bool value) => _save(state.copyWith(soundEnabled: value));
  Future<void> setHapticsEnabled(bool value) => _save(state.copyWith(hapticsEnabled: value));
  Future<void> setReduceMotion(bool value) => _save(state.copyWith(reduceMotion: value));

  Future<void> _save(SystemPreferences next) async {
    state = next;
    try {
      await _service.save(next);
    } catch (_) {
      // A escolha ainda é aplicada nesta sessão; a persistência será tentada depois.
    }
  }
}
