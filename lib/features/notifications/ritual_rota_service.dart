import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final ritualRotaProvider = Provider<RitualRotaService>(
  (_) => RitualRotaService(),
);

class RitualRotaSettings {
  const RitualRotaSettings({required this.enabled, required this.minutes});
  final bool enabled;
  final int minutes;
  int get hour => minutes ~/ 60;
  int get minute => minutes % 60;
}

/// Agenda no maximo um convite diario; nunca notifica sobre perda de streak.
class RitualRotaService {
  static const _notificationId = 7301;
  static const _enabledKey = 'ritual_rota_habilitado';
  static const _minutesKey = 'ritual_rota_minutos';
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  RitualRotaService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<RitualRotaSettings> settings() async {
    final prefs = await SharedPreferences.getInstance();
    return RitualRotaSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      minutes: prefs.getInt(_minutesKey) ?? (19 * 60),
    );
  }

  Future<bool> enable({required int minutes}) async {
    await _initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final allowed = await android?.requestNotificationsPermission();
    if (allowed == false) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_minutesKey, minutes);
    return true;
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    await _plugin.cancel(id: _notificationId);
  }

  Future<void> updateMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_minutesKey, minutes);
  }

  Future<void> sync(List<Quest> quests) async {
    final current = await settings();
    await _plugin.cancel(id: _notificationId);
    if (!current.enabled) return;
    await _initialize();
    final next = nextPendingQuestForRitual(quests);
    if (next == null) return;
    final scheduled = _nextSchedule(_dateFor(next), current);
    if (scheduled == null) return;
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'Sua rota está aberta',
      body: next.title,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ritual_rota',
          'Ritual de rota',
          channelDescription: 'Lembrete diário e gentil da próxima missão.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: next.id,
    );
  }

  DateTime _dateFor(Quest quest) =>
      quest.plannedFor ?? quest.occursOn ?? DateTime.now();

  tz.TZDateTime? _nextSchedule(DateTime date, RitualRotaSettings settings) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      settings.hour,
      settings.minute,
    );
    if (!scheduled.isAfter(now)) {
      if (DateTime(date.year, date.month, date.day)
          .isAfter(DateTime(now.year, now.month, now.day))) {
        return scheduled;
      }
      return null;
    }
    return scheduled;
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }
}

Quest? nextPendingQuestForRitual(List<Quest> quests) {
  final pending = quests.where((quest) => !quest.isArchived && !quest.isCompleted).toList()
    ..sort((a, b) => (a.plannedFor ?? a.occursOn ?? DateTime.now())
        .compareTo(b.plannedFor ?? b.occursOn ?? DateTime.now()));
  return pending.firstOrNull;
}
