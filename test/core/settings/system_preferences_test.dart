import 'package:ascend/core/settings/system_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persiste preferências locais do Sistema', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SystemPreferencesService();
    await service.save(
      const SystemPreferences(
        soundEnabled: false,
        hapticsEnabled: false,
        reduceMotion: true,
      ),
    );

    final loaded = await service.load();

    expect(loaded.soundEnabled, isFalse);
    expect(loaded.hapticsEnabled, isFalse);
    expect(loaded.reduceMotion, isTrue);
  });
}
