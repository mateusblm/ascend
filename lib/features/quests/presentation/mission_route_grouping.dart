import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';

/// Seleção visual: não altera ordem de persistência, estado ou XP.
Quest? missionPriorityFor(List<Quest> quests, {required DateTime now}) {
  final active = quests
      .where((quest) => !quest.isArchived && !quest.isCompleted)
      .toList();
  if (active.isEmpty) return null;

  final inProgress = _ordered(active.where(_isInProgress));
  if (inProgress.isNotEmpty) return inProgress.first;

  final scheduled = _ordered(
    active.where((quest) {
      final when = quest.plannedFor ?? quest.occursOn;
      return _hasScheduledTime(quest) &&
          when != null &&
          !DateUtils.dateOnly(when).isBefore(DateUtils.dateOnly(now));
    }),
  );
  if (scheduled.isNotEmpty) return scheduled.first;

  final overdue = _ordered(
    active.where((quest) {
      final when = quest.plannedFor ?? quest.occursOn;
      return when != null &&
          DateUtils.dateOnly(when).isBefore(DateUtils.dateOnly(now));
    }),
  );
  if (overdue.isNotEmpty) return overdue.first;

  return _ordered(active).first;
}

enum MissionRouteGroup { inProgress, now, scheduled, unscheduled, completed }

Map<MissionRouteGroup, List<Quest>> missionGroupsFor(
  List<Quest> quests, {
  required DateTime now,
  String? priorityId,
}) {
  final groups = <MissionRouteGroup, List<Quest>>{
    for (final group in MissionRouteGroup.values) group: [],
  };
  for (final quest in _ordered(quests)) {
    if (quest.id == priorityId) continue;
    if (quest.isCompleted) {
      groups[MissionRouteGroup.completed]!.add(quest);
    } else if (_isInProgress(quest)) {
      groups[MissionRouteGroup.inProgress]!.add(quest);
    } else if (_isDueNow(quest, now)) {
      groups[MissionRouteGroup.now]!.add(quest);
    } else if (_hasScheduledTime(quest)) {
      groups[MissionRouteGroup.scheduled]!.add(quest);
    } else {
      groups[MissionRouteGroup.unscheduled]!.add(quest);
    }
  }
  return groups;
}

bool _isInProgress(Quest quest) =>
    quest.verificationStatus == QuestVerificationStatus.inProgress;

bool _hasScheduledTime(Quest quest) {
  final when = quest.plannedFor ?? quest.occursOn;
  return when != null && (when.hour != 0 || when.minute != 0);
}

bool _isDueNow(Quest quest, DateTime now) {
  final when = quest.plannedFor ?? quest.occursOn;
  return _hasScheduledTime(quest) &&
      when != null &&
      !when.isAfter(now) &&
      DateUtils.isSameDay(when, now);
}

List<Quest> _ordered(Iterable<Quest> quests) {
  final ordered = quests.toList();
  ordered.sort((a, b) {
    final whenA = a.plannedFor ?? a.occursOn;
    final whenB = b.plannedFor ?? b.occursOn;
    if (whenA == null && whenB == null) return 0;
    if (whenA == null) return 1;
    if (whenB == null) return -1;
    return whenA.compareTo(whenB);
  });
  return ordered;
}
