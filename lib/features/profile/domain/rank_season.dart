import 'package:ascend/features/profile/domain/rank_progression.dart';

class RankSeasonSummary {
  const RankSeasonSummary({
    required this.seasonKey,
    required this.seasonLabel,
    required this.recordedWeeks,
    required this.totalSeasonWeeks,
    required this.secureWeeks,
    required this.secureRate,
    required this.demotionEvents,
    required this.examWeeks,
    required this.promotionEvents,
    required this.perfectWeeks,
    required this.averageActiveDays,
    required this.peakRank,
    required this.weeksRemaining,
    required this.rewardTierLabel,
    required this.rewardStatusLabel,
    required this.rewardTrackLabel,
    required this.rewardProgress,
    required this.nextUnlockHint,
    required this.rewardPreview,
    required this.rewardUnlocked,
    required this.rewardName,
    required this.rewardBadgeLabel,
    required this.rewardTitleLabel,
    required this.rewardBonusLabel,
    required this.resetLabel,
    required this.resetAt,
  });

  final String seasonKey;
  final String seasonLabel;
  final int recordedWeeks;
  final int totalSeasonWeeks;
  final int secureWeeks;
  final int secureRate;
  final int demotionEvents;
  final int examWeeks;
  final int promotionEvents;
  final int perfectWeeks;
  final double averageActiveDays;
  final String peakRank;
  final int weeksRemaining;
  final String rewardTierLabel;
  final String rewardStatusLabel;
  final String rewardTrackLabel;
  final double rewardProgress;
  final String nextUnlockHint;
  final String rewardPreview;
  final bool rewardUnlocked;
  final String rewardName;
  final String rewardBadgeLabel;
  final String rewardTitleLabel;
  final String rewardBonusLabel;
  final String resetLabel;
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
    final totalSeasonWeeks = _seasonWeekCapacity(currentDate);
    const rewardPayload = _SeasonRewardPayload.locked();
    return RankSeasonSummary(
      seasonKey: _seasonKey(currentDate),
      seasonLabel: _seasonLabel(currentDate),
      recordedWeeks: 0,
      totalSeasonWeeks: totalSeasonWeeks,
      secureWeeks: 0,
      secureRate: 0,
      demotionEvents: 0,
      examWeeks: 0,
      promotionEvents: 0,
      perfectWeeks: 0,
      averageActiveDays: 0,
      peakRank: '-',
      weeksRemaining: _remainingSeasonWeeks(currentDate, seasonBounds.end),
      rewardTierLabel: 'SEM DADOS',
      rewardStatusLabel: 'BLOQUEADA',
      rewardTrackLabel: '0/$totalSeasonWeeks semanas registradas',
      rewardProgress: 0,
      nextUnlockHint:
          'Registre sua primeira semana valida para abrir a trilha sazonal.',
      rewardPreview:
          'A temporada ainda nao gerou recompensa. Primeiro registre semanas validas.',
      rewardUnlocked: rewardPayload.unlocked,
      rewardName: rewardPayload.rewardName,
      rewardBadgeLabel: rewardPayload.badgeLabel,
      rewardTitleLabel: rewardPayload.titleLabel,
      rewardBonusLabel: rewardPayload.bonusLabel,
      resetLabel: _resetLabel(currentDate, seasonBounds.end),
      resetAt: seasonBounds.end,
    );
  }

  final totalSeasonWeeks = _seasonWeekCapacity(currentDate);
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
  final secureWeeks = seasonEntries.where((entry) {
    return entry.status == RankMaintenanceStatus.secure ||
        entry.status == RankMaintenanceStatus.promotionReady;
  }).length;
  final rewardTrack = _buildRewardTrack(
    secureWeeks: secureWeeks,
    totalSeasonWeeks: totalSeasonWeeks,
    promotionEvents: promotionEvents,
    perfectWeeks: perfectWeeks,
    demotionEvents: demotionEvents,
  );
  final rewardPayload = _rewardPayloadForSeason(
    tier: rewardTier,
    rewardStatusLabel: rewardTrack.statusLabel,
  );

  return RankSeasonSummary(
    seasonKey: _seasonKey(currentDate),
    seasonLabel: _seasonLabel(currentDate),
    recordedWeeks: seasonEntries.length,
    totalSeasonWeeks: totalSeasonWeeks,
    secureWeeks: secureWeeks,
    secureRate: ((secureWeeks / seasonEntries.length) * 100).round(),
    demotionEvents: demotionEvents,
    examWeeks: examWeeks,
    promotionEvents: promotionEvents,
    perfectWeeks: perfectWeeks,
    averageActiveDays: totalActiveDays / seasonEntries.length,
    peakRank: seasonEntries.first.currentRank,
    weeksRemaining: _remainingSeasonWeeks(currentDate, seasonBounds.end),
    rewardTierLabel: rewardTier.label,
    rewardStatusLabel: rewardTrack.statusLabel,
    rewardTrackLabel: rewardTrack.trackLabel,
    rewardProgress: rewardTrack.progress,
    nextUnlockHint: rewardTrack.nextUnlockHint,
    rewardPreview: rewardTier.preview,
    rewardUnlocked: rewardPayload.unlocked,
    rewardName: rewardPayload.rewardName,
    rewardBadgeLabel: rewardPayload.badgeLabel,
    rewardTitleLabel: rewardPayload.titleLabel,
    rewardBonusLabel: rewardPayload.bonusLabel,
    resetLabel: _resetLabel(currentDate, seasonBounds.end),
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

class _SeasonRewardTrack {
  const _SeasonRewardTrack({
    required this.statusLabel,
    required this.trackLabel,
    required this.progress,
    required this.nextUnlockHint,
  });

  final String statusLabel;
  final String trackLabel;
  final double progress;
  final String nextUnlockHint;
}

class _SeasonRewardPayload {
  const _SeasonRewardPayload({
    required this.unlocked,
    required this.rewardName,
    required this.badgeLabel,
    required this.titleLabel,
    required this.bonusLabel,
  });

  const _SeasonRewardPayload.locked()
    : unlocked = false,
      rewardName = 'Trilha sazonal bloqueada',
      badgeLabel = 'SEM EMBLEMA',
      titleLabel = 'Sem titulo sazonal',
      bonusLabel = 'Nenhum pacote sazonal liberado.';

  final bool unlocked;
  final String rewardName;
  final String badgeLabel;
  final String titleLabel;
  final String bonusLabel;
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

int _seasonWeekCapacity(DateTime date) {
  final bounds = _seasonBoundsFor(date);
  return ((bounds.end.difference(bounds.start).inDays) / 7).ceil();
}

String _resetLabel(DateTime now, DateTime seasonEnd) {
  final normalizedNow = DateTime(now.year, now.month, now.day);
  final days = seasonEnd.difference(normalizedNow).inDays;
  if (days <= 0) {
    return 'Reset em andamento';
  }
  if (days == 1) {
    return 'Reset amanha';
  }
  if (days <= 7) {
    return 'Reset em $days dias';
  }
  final weeks = ((days + 6) / 7).floor();
  return 'Reset em $weeks semana(s)';
}

_SeasonRewardTrack _buildRewardTrack({
  required int secureWeeks,
  required int totalSeasonWeeks,
  required int promotionEvents,
  required int perfectWeeks,
  required int demotionEvents,
}) {
  if (demotionEvents > 0) {
    return _SeasonRewardTrack(
      statusLabel: 'INSTAVEL',
      trackLabel: '$secureWeeks/$totalSeasonWeeks semanas seguras',
      progress: (secureWeeks / totalSeasonWeeks).clamp(0.0, 1.0),
      nextUnlockHint:
          'Elimine quedas e reconstrua 2 semanas seguras para voltar ao circuito sazonal.',
    );
  }

  if (secureWeeks < 2) {
    return _SeasonRewardTrack(
      statusLabel: 'ABRINDO TRILHA',
      trackLabel: '$secureWeeks/2 semanas seguras',
      progress: (secureWeeks / 2).clamp(0.0, 1.0),
      nextUnlockHint:
          'Mais ${2 - secureWeeks} semana(s) segura(s) para garantir a recompensa basica.',
    );
  }

  if (secureWeeks < 3) {
    return _SeasonRewardTrack(
      statusLabel: 'EM ROTA',
      trackLabel: '$secureWeeks/3 semanas seguras',
      progress: (secureWeeks / 3).clamp(0.0, 1.0),
      nextUnlockHint:
          'Mais ${3 - secureWeeks} semana(s) segura(s) para destravar DOMINIO.',
    );
  }

  if (promotionEvents < 1 || perfectWeeks < 1) {
    final missing = <String>[];
    if (promotionEvents < 1) {
      missing.add('1 promocao confirmada');
    }
    if (perfectWeeks < 1) {
      missing.add('1 semana perfeita');
    }
    return _SeasonRewardTrack(
      statusLabel: 'RECOMPENSA AVANCADA',
      trackLabel: '$secureWeeks/$totalSeasonWeeks semanas seguras',
      progress: 0.85,
      nextUnlockHint:
          'Falta ${missing.join(' e ')} para atingir ASCENSAO nesta temporada.',
    );
  }

  return _SeasonRewardTrack(
    statusLabel: 'GARANTIDA',
    trackLabel: '$secureWeeks/$totalSeasonWeeks semanas seguras',
    progress: 1.0,
    nextUnlockHint:
        'A trilha sazonal principal ja foi garantida. Agora o objetivo e fechar a temporada sem queda.',
  );
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

_SeasonRewardPayload _rewardPayloadForSeason({
  required _SeasonRewardTier tier,
  required String rewardStatusLabel,
}) {
  return switch (tier.label) {
    'ASCENSAO' => const _SeasonRewardPayload(
      unlocked: true,
      rewardName: 'Pacote Ascensao da Temporada',
      badgeLabel: 'SIGILO DE OURO',
      titleLabel: 'ASCENDENTE DA TEMPORADA',
      bonusLabel:
          'Moldura premium de rank, selo dourado e destaque maximo no historico sazonal.',
    ),
    'DOMINIO' => const _SeasonRewardPayload(
      unlocked: true,
      rewardName: 'Pacote Dominio do Rank',
      badgeLabel: 'SIGILO DE PRATA',
      titleLabel: 'COMANDANTE DO RANK',
      bonusLabel:
          'Moldura de temporada, selo prateado e destaque elevado no historico competitivo.',
    ),
    'MANUTENCAO' => const _SeasonRewardPayload(
      unlocked: true,
      rewardName: 'Pacote de Manutencao',
      badgeLabel: 'SIGILO DE BRONZE',
      titleLabel: 'VIGIA DO CICLO',
      bonusLabel:
          'Insignia sazonal, selo de consistencia e registro de temporada valida.',
    ),
    'INSTAVEL' => _SeasonRewardPayload(
      unlocked: false,
      rewardName: 'Pacote em recuperacao',
      badgeLabel: 'EM RISCO',
      titleLabel: 'RECUPERANDO POSICAO',
      bonusLabel:
          rewardStatusLabel == 'INSTAVEL'
              ? 'Sem premio liberado. Reconstrua a trilha com semanas seguras.'
              : 'A trilha ainda nao estabilizou o bastante para liberar premio.',
    ),
    _ => const _SeasonRewardPayload.locked(),
  };
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
