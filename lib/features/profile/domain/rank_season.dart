import 'package:ascend/features/profile/domain/rank_progression.dart';

class RankSeasonSummary {
  const RankSeasonSummary({
    required this.seasonKey,
    required this.seasonLabel,
    required this.recordedWeeks,
    required this.secureWeeks,
    required this.demotionEvents,
    required this.examWeeks,
    required this.promotionEvents,
    required this.perfectWeeks,
    required this.averageActiveDays,
    required this.peakRank,
    required this.weeksRemaining,
    required this.rewardTierLabel,
    required this.rewardPreview,
    required this.resetAt,
  });

  final String seasonKey;
  final String seasonLabel;
  final int recordedWeeks;
  final int secureWeeks;
  final int demotionEvents;
  final int examWeeks;
  final int promotionEvents;
  final int perfectWeeks;
  final double averageActiveDays;
  final String peakRank;
  final int weeksRemaining;
  final String rewardTierLabel;
  final String rewardPreview;
  final DateTime resetAt;
}

RankSeasonSummary buildCurrentSeasonSummary(
  List<CompetitiveRankSnapshot> history, {
  DateTime? now,
}) {
  final currentDate = now ?? DateTime.now();
  final seasonBounds = _seasonBoundsFor(currentDate);
  final seasonEntries = history.where((entry) {
    final date = _dateFromWeekKey(entry.weekKey);
    return date != null &&
        !date.isBefore(seasonBounds.start) &&
        date.isBefore(seasonBounds.end);
  }).toList();

  if (seasonEntries.isEmpty) {
    return RankSeasonSummary(
      seasonKey: _seasonKey(currentDate),
      seasonLabel: _seasonLabel(currentDate),
      recordedWeeks: 0,
      secureWeeks: 0,
      demotionEvents: 0,
      examWeeks: 0,
      promotionEvents: 0,
      perfectWeeks: 0,
      averageActiveDays: 0,
      peakRank: '-',
      weeksRemaining: _remainingSeasonWeeks(currentDate, seasonBounds.end),
      rewardTierLabel: 'SEM DADOS',
      rewardPreview:
          'A temporada ainda nao gerou recompensa. Primeiro registre semanas validas.',
      resetAt: seasonBounds.end,
    );
  }

  final totalActiveDays = seasonEntries.fold<int>(
    0,
    (sum, entry) => sum + entry.activeDays,
  );
  seasonEntries.sort(
    (a, b) => _rankScore(b.currentRank).compareTo(_rankScore(a.currentRank)),
  );
  final demotionEvents = seasonEntries
      .where((entry) => entry.status == RankMaintenanceStatus.demoted)
      .length;
  final examWeeks = seasonEntries.where((entry) {
    return entry.eventType == CompetitiveRankEventType.promotionUnlocked ||
        entry.eventType == CompetitiveRankEventType.promotionConfirmed;
  }).length;
  final promotionEvents = seasonEntries
      .where(
        (entry) =>
            entry.eventType == CompetitiveRankEventType.promotionConfirmed,
      )
      .length;
  final perfectWeeks = seasonEntries
      .where((entry) => entry.eventType == CompetitiveRankEventType.perfectWeek)
      .length;
  final rewardTier = _rewardTierForSeason(
    secureWeeks: seasonEntries.where((entry) {
      return entry.status == RankMaintenanceStatus.secure ||
          entry.status == RankMaintenanceStatus.promotionReady;
    }).length,
    promotionEvents: promotionEvents,
    perfectWeeks: perfectWeeks,
    demotionEvents: demotionEvents,
  );

  return RankSeasonSummary(
    seasonKey: _seasonKey(currentDate),
    seasonLabel: _seasonLabel(currentDate),
    recordedWeeks: seasonEntries.length,
    secureWeeks: seasonEntries.where((entry) {
      return entry.status == RankMaintenanceStatus.secure ||
          entry.status == RankMaintenanceStatus.promotionReady;
    }).length,
    demotionEvents: demotionEvents,
    examWeeks: examWeeks,
    promotionEvents: promotionEvents,
    perfectWeeks: perfectWeeks,
    averageActiveDays: totalActiveDays / seasonEntries.length,
    peakRank: seasonEntries.first.currentRank,
    weeksRemaining: _remainingSeasonWeeks(currentDate, seasonBounds.end),
    rewardTierLabel: rewardTier.label,
    rewardPreview: rewardTier.preview,
    resetAt: seasonBounds.end,
  );
}

class _SeasonBounds {
  const _SeasonBounds({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _SeasonRewardTier {
  const _SeasonRewardTier({required this.label, required this.preview});

  final String label;
  final String preview;
}

DateTime? _dateFromWeekKey(String weekKey) {
  final parts = weekKey.split('W');
  if (parts.length != 2) return null;
  final year = int.tryParse(parts[0]);
  final rawDate = parts[1];
  if (year == null || rawDate.length != 4) return null;
  final month = int.tryParse(rawDate.substring(0, 2));
  final day = int.tryParse(rawDate.substring(2, 4));
  if (month == null || day == null) return null;
  return DateTime(year, month, day);
}

String _seasonLabel(DateTime date) {
  const months = <String>[
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _seasonKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

_SeasonBounds _seasonBoundsFor(DateTime date) {
  final start = DateTime(date.year, date.month);
  final end = date.month == 12
      ? DateTime(date.year + 1, 1)
      : DateTime(date.year, date.month + 1);
  return _SeasonBounds(start: start, end: end);
}

int _remainingSeasonWeeks(DateTime now, DateTime seasonEnd) {
  final normalizedNow = DateTime(now.year, now.month, now.day);
  if (!normalizedNow.isBefore(seasonEnd)) {
    return 0;
  }

  final days = seasonEnd.difference(normalizedNow).inDays;
  return ((days + 6) / 7).floor();
}

_SeasonRewardTier _rewardTierForSeason({
  required int secureWeeks,
  required int promotionEvents,
  required int perfectWeeks,
  required int demotionEvents,
}) {
  if (promotionEvents >= 1 && perfectWeeks >= 1 && demotionEvents == 0) {
    return const _SeasonRewardTier(
      label: 'ASCENSAO',
      preview:
          'Selo de temporada limpa, moldura premium de rank e bonus futuro de prestigio.',
    );
  }
  if (secureWeeks >= 3 && demotionEvents == 0) {
    return const _SeasonRewardTier(
      label: 'DOMINIO',
      preview:
          'Recompensa futura de emblema competitivo e destaque no historico sazonal.',
    );
  }
  if (secureWeeks >= 2) {
    return const _SeasonRewardTier(
      label: 'MANUTENCAO',
      preview:
          'Temporada consistente. Voce ja esta em rota de recompensa sazonal basica.',
    );
  }
  if (demotionEvents > 0) {
    return const _SeasonRewardTier(
      label: 'INSTAVEL',
      preview:
          'Sem recompensa sazonal por enquanto. O sistema exige estabilizacao antes do reset.',
    );
  }
  return const _SeasonRewardTier(
    label: 'EM FORMACAO',
    preview:
        'Acumule semanas registradas para destravar a trilha de recompensa da temporada.',
  );
}

int _rankScore(String rank) {
  return switch (rank.trim().toUpperCase()) {
    'S' => 6,
    'A' => 5,
    'B' => 4,
    'C' => 3,
    'D' => 2,
    _ => 1,
  };
}
