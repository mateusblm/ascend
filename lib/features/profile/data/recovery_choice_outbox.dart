import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Uma única escolha de retomada pendente. O backend continua canônico.
class RecoveryChoiceOutbox {
  RecoveryChoiceOutbox({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  static const _key = 'pending_recovery_choice_v1';
  final Future<SharedPreferences> _preferences;

  Future<PendingRecoveryChoice?> load() async {
    final raw = (await _preferences).getString(_key);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      final periodKey = data['periodKey'];
      final choice = data['choice'];
      if (periodKey is! String || choice is! String) return null;
      return PendingRecoveryChoice(periodKey: periodKey, choice: choice);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PendingRecoveryChoice choice) async {
    await (await _preferences).setString(_key, jsonEncode(choice.toJson()));
  }

  Future<void> clear() async => (await _preferences).remove(_key);
}

class PendingRecoveryChoice {
  const PendingRecoveryChoice({required this.periodKey, required this.choice});

  final String periodKey;
  final String choice;

  Map<String, String> toJson() => {'periodKey': periodKey, 'choice': choice};
}
