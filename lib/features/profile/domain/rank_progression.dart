import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RankMaintenanceStatus {
  secure,
  warning,
  critical,
  promotionReady,
  demoted,
}

enum RankAdvancementMode { ascension, reconquest }

enum CompetitiveRankEventType {
  routine,
  warning,
  perfectWeek,
  promotionUnlocked,
  reconquestUnlocked,
  promotionConfirmed,
  demotionApplied,
}

class RankRule {
  const RankRule({
    required this.rank,
    required this.minimumLevel,
    required this.requiredActiveDays,
    required this.requiresBossClear,
    required this.maxFailedWeeksBeforeDemotion,
  });

  final String rank;
  final int minimumLevel;
  final int requiredActiveDays;
  final bool requiresBossClear;
  final int maxFailedWeeksBeforeDemotion;
}

class CompetitiveRankSnapshot {
  const CompetitiveRankSnapshot({
    required this.currentRank,
    this.peakRank = 'E',
    this.highestEligibleRank = 'E',
    required this.weekKey,
    required this.activeDays,
    required this.requiredActiveDays,
    required this.requiresBossClear,
    required this.bossCompleted,
    required this.status,
    required this.demotionStrikes,
    required this.promotionReady,
    required this.promotionTargetRank,
    this.targetRequiredLevel = 1,
    this.targetLevelGateMet = true,
    this.advancementMode,
    required this.eventType,
    required this.summary,
    required this.detail,
    required this.syncSchemaVersion,
    required this.syncSource,
    required this.updatedAt,
  });

  final String currentRank;
  final String peakRank;
  final String highestEligibleRank;
  final String weekKey;
  final int activeDays;
  final int requiredActiveDays;
  final bool requiresBossClear;
  final bool bossCompleted;
  final RankMaintenanceStatus status;
  final int demotionStrikes;
  final bool promotionReady;
  final String? promotionTargetRank;
  final int targetRequiredLevel;
  final bool targetLevelGateMet;
  final RankAdvancementMode? advancementMode;
  final CompetitiveRankEventType eventType;
  final String summary;
  final String detail;
  final int syncSchemaVersion;
  final String syncSource;
  final DateTime updatedAt;

  bool get maintenanceMet =>
      status == RankMaintenanceStatus.secure ||
      status == RankMaintenanceStatus.promotionReady;

  bool get isReconquest => advancementMode == RankAdvancementMode.reconquest;

  Map<String, dynamic> toFirestore() {
    return {
      'currentRank': currentRank,
      'peakRank': peakRank,
      'highestEligibleRank': highestEligibleRank,
      'weekKey': weekKey,
      'activeDays': activeDays,
      'requiredActiveDays': requiredActiveDays,
      'requiresBossClear': requiresBossClear,
      'bossCompleted': bossCompleted,
      'status': status.name,
      'demotionStrikes': demotionStrikes,
      'promotionReady': promotionReady,
      'promotionTargetRank': promotionTargetRank,
      'targetRequiredLevel': targetRequiredLevel,
      'targetLevelGateMet': targetLevelGateMet,
      'advancementMode': advancementMode?.name,
      'eventType': eventType.name,
      'summary': summary,
      'detail': detail,
      'syncSchemaVersion': syncSchemaVersion,
      'syncSource': syncSource,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CompetitiveRankSnapshot.fromFirestore(Map<String, dynamic> data) {
    return CompetitiveRankSnapshot(
      currentRank: (data['currentRank'] as String? ?? 'E').trim().toUpperCase(),
      peakRank: (data['peakRank'] as String? ?? data['currentRank'] as String? ?? 'E')
          .trim()
          .toUpperCase(),
      highestEligibleRank:
          (data['highestEligibleRank'] as String? ??
                  data['currentRank'] as String? ??
                  'E')
              .trim()
              .toUpperCase(),
      weekKey: data['weekKey'] as String? ?? '',
      activeDays: data['activeDays'] as int? ?? 0,
      requiredActiveDays: data['requiredActiveDays'] as int? ?? 3,
      requiresBossClear: data['requiresBossClear'] as bool? ?? false,
      bossCompleted: data['bossCompleted'] as bool? ?? false,
      status: RankMaintenanceStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => RankMaintenanceStatus.warning,
      ),
      demotionStrikes: data['demotionStrikes'] as int? ?? 0,
      promotionReady: data['promotionReady'] as bool? ?? false,
      promotionTargetRank: data['promotionTargetRank'] as String?,
      targetRequiredLevel: (data['targetRequiredLevel'] as num?)?.toInt() ?? 1,
      targetLevelGateMet: data['targetLevelGateMet'] as bool? ?? true,
      advancementMode: data['advancementMode'] == null
          ? null
          : RankAdvancementMode.values.firstWhere(
              (value) => value.name == data['advancementMode'],
              orElse: () => RankAdvancementMode.ascension,
            ),
      eventType: CompetitiveRankEventType.values.firstWhere(
        (value) => value.name == data['eventType'],
        orElse: () => CompetitiveRankEventType.routine,
      ),
      summary: data['summary'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      syncSchemaVersion: (data['syncSchemaVersion'] as num?)?.toInt() ?? 1,
      syncSource: (data['syncSource'] as String? ?? 'client')
          .trim()
          .toLowerCase(),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  CompetitiveRankSnapshot copyWith({
    String? currentRank,
    String? peakRank,
    String? highestEligibleRank,
    String? weekKey,
    int? activeDays,
    int? requiredActiveDays,
    bool? requiresBossClear,
    bool? bossCompleted,
    RankMaintenanceStatus? status,
    int? demotionStrikes,
    bool? promotionReady,
    String? promotionTargetRank,
    int? targetRequiredLevel,
    bool? targetLevelGateMet,
    RankAdvancementMode? advancementMode,
    CompetitiveRankEventType? eventType,
    String? summary,
    String? detail,
    int? syncSchemaVersion,
    String? syncSource,
    DateTime? updatedAt,
  }) {
    return CompetitiveRankSnapshot(
      currentRank: currentRank ?? this.currentRank,
      peakRank: peakRank ?? this.peakRank,
      highestEligibleRank: highestEligibleRank ?? this.highestEligibleRank,
      weekKey: weekKey ?? this.weekKey,
      activeDays: activeDays ?? this.activeDays,
      requiredActiveDays: requiredActiveDays ?? this.requiredActiveDays,
      requiresBossClear: requiresBossClear ?? this.requiresBossClear,
      bossCompleted: bossCompleted ?? this.bossCompleted,
      status: status ?? this.status,
      demotionStrikes: demotionStrikes ?? this.demotionStrikes,
      promotionReady: promotionReady ?? this.promotionReady,
      promotionTargetRank: promotionTargetRank ?? this.promotionTargetRank,
      targetRequiredLevel: targetRequiredLevel ?? this.targetRequiredLevel,
      targetLevelGateMet: targetLevelGateMet ?? this.targetLevelGateMet,
      advancementMode: advancementMode ?? this.advancementMode,
      eventType: eventType ?? this.eventType,
      summary: summary ?? this.summary,
      detail: detail ?? this.detail,
      syncSchemaVersion: syncSchemaVersion ?? this.syncSchemaVersion,
      syncSource: syncSource ?? this.syncSource,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

CompetitiveRankSnapshot evaluateCompetitiveRank({
  required Player player,
  CompetitiveRankSnapshot? previousSnapshot,
  DateTime? now,
}) {
  final currentDate = now ?? DateTime.now();
  final weekKey = _weekKeyFor(currentDate);
  final highestEligibleRank = playerRankForLevel(player.level);
  final seedRank =
      previousSnapshot?.currentRank ?? playerRankForLevel(player.level);
  final previousPeakRank =
      previousSnapshot?.peakRank ?? previousSnapshot?.currentRank ?? seedRank;
  final peakRank = _higherRank(previousPeakRank, seedRank);
  final baseRule = rankRuleFor(seedRank);
  final boss = weeklyBossForRank(seedRank);
  final bossCompleted = boss.isCompleted(player);
  final activeDays = boss.progressFor(player);
  final maintenanceMet =
      activeDays >= baseRule.requiredActiveDays &&
      (!baseRule.requiresBossClear || bossCompleted);
  final isNewWeek =
      previousSnapshot == null || previousSnapshot.weekKey != weekKey;

  var currentRank = seedRank;
  var demotionStrikes = previousSnapshot?.demotionStrikes ?? 0;
  var status = RankMaintenanceStatus.secure;

  if (maintenanceMet) {
    demotionStrikes = 0;
  } else if (isNewWeek) {
    demotionStrikes += 1;
    if (demotionStrikes >= baseRule.maxFailedWeeksBeforeDemotion) {
      final previousRank = rankBefore(seedRank);
      if (previousRank != null) {
        currentRank = previousRank;
        demotionStrikes = 0;
        status = RankMaintenanceStatus.demoted;
      }
    }
  }

  final currentRule = rankRuleFor(currentRank);
  final nextRank = rankAfter(currentRank);
  final nextRule = nextRank == null ? null : rankRuleFor(nextRank);
  final currentBoss = weeklyBossForRank(currentRank);
  final currentBossCompleted = currentBoss.isCompleted(player);
  final currentActiveDays = currentBoss.progressFor(player);
  final currentMaintenanceMet =
      currentActiveDays >= currentRule.requiredActiveDays &&
      (!currentRule.requiresBossClear || currentBossCompleted);
  final nextBoss = nextRank == null ? null : weeklyBossForRank(nextRank);
  final nextBossCompleted = nextBoss?.isCompleted(player) ?? false;
  final targetRequiredLevel = nextRule?.minimumLevel ?? player.level;
  final targetLevelGateMet =
      nextRule == null ? true : player.level >= nextRule.minimumLevel;
  final advancementMode = nextRank == null
      ? null
      : (_rankOrder(nextRank) <= _rankOrder(peakRank)
            ? RankAdvancementMode.reconquest
            : RankAdvancementMode.ascension);

  if (status != RankMaintenanceStatus.demoted) {
    final promotionReady = _isPromotionReady(
      currentRank: currentRank,
      activeDays: currentActiveDays,
      bossCompleted: nextBossCompleted,
      playerLevel: player.level,
    );
    if (promotionReady) {
      status = RankMaintenanceStatus.promotionReady;
    } else if (currentMaintenanceMet) {
      status = RankMaintenanceStatus.secure;
    } else {
      final missingDays = (currentRule.requiredActiveDays - currentActiveDays)
          .clamp(0, currentRule.requiredActiveDays);
      final bossBlocked =
          currentRule.requiresBossClear && !currentBossCompleted;
      status = missingDays <= 1 && !bossBlocked
          ? RankMaintenanceStatus.warning
          : RankMaintenanceStatus.critical;
    }
  }

  final detail = _detailForStatus(
    status: status,
    currentRank: currentRank,
    peakRank: peakRank,
    highestEligibleRank: highestEligibleRank,
    currentRule: currentRule,
    activeDays: currentActiveDays,
    bossCompleted: currentBossCompleted,
    demotionStrikes: demotionStrikes,
    nextRank: nextRank,
    targetRequiredLevel: targetRequiredLevel,
    targetLevelGateMet: targetLevelGateMet,
    advancementMode: advancementMode,
  );
  final eventType = _eventTypeForSnapshot(
    status: status,
    activeDays: currentActiveDays,
    requiredActiveDays: currentRule.requiredActiveDays,
    bossCompleted: currentBossCompleted,
    advancementMode: advancementMode,
  );

  return CompetitiveRankSnapshot(
    currentRank: currentRank,
    peakRank: peakRank,
    highestEligibleRank: highestEligibleRank,
    weekKey: weekKey,
    activeDays: currentActiveDays,
    requiredActiveDays: currentRule.requiredActiveDays,
    requiresBossClear: currentRule.requiresBossClear,
    bossCompleted: currentBossCompleted,
    status: status,
    demotionStrikes: demotionStrikes,
    promotionReady: status == RankMaintenanceStatus.promotionReady,
    promotionTargetRank: nextRank,
    targetRequiredLevel: targetRequiredLevel,
    targetLevelGateMet: targetLevelGateMet,
    advancementMode: advancementMode,
    eventType: eventType,
    summary: _summaryForStatus(
      status,
      currentRank,
      nextRank: nextRank,
      advancementMode: advancementMode,
    ),
    detail: detail,
    syncSchemaVersion: 1,
    syncSource: 'client',
    updatedAt: currentDate,
  );
}

CompetitiveRankEventType _eventTypeForSnapshot({
  required RankMaintenanceStatus status,
  required int activeDays,
  required int requiredActiveDays,
  required bool bossCompleted,
  required RankAdvancementMode? advancementMode,
}) {
  if (status == RankMaintenanceStatus.demoted) {
    return CompetitiveRankEventType.demotionApplied;
  }
  if (status == RankMaintenanceStatus.promotionReady) {
    return advancementMode == RankAdvancementMode.reconquest
        ? CompetitiveRankEventType.reconquestUnlocked
        : CompetitiveRankEventType.promotionUnlocked;
  }
  if (status == RankMaintenanceStatus.warning ||
      status == RankMaintenanceStatus.critical) {
    return CompetitiveRankEventType.warning;
  }
  if (activeDays >= requiredActiveDays + 1 && bossCompleted) {
    return CompetitiveRankEventType.perfectWeek;
  }
  return CompetitiveRankEventType.routine;
}

RankRule rankRuleFor(String rank) {
  final normalizedRank = rank.trim().toUpperCase();
  return switch (normalizedRank) {
    'E' => const RankRule(
      rank: 'E',
      minimumLevel: 1,
      requiredActiveDays: 3,
      requiresBossClear: false,
      maxFailedWeeksBeforeDemotion: 2,
    ),
    'D' => const RankRule(
      rank: 'D',
      minimumLevel: 5,
      requiredActiveDays: 4,
      requiresBossClear: false,
      maxFailedWeeksBeforeDemotion: 2,
    ),
    'C' => const RankRule(
      rank: 'C',
      minimumLevel: 10,
      requiredActiveDays: 5,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    ),
    'B' => const RankRule(
      rank: 'B',
      minimumLevel: 20,
      requiredActiveDays: 5,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    ),
    'A' => const RankRule(
      rank: 'A',
      minimumLevel: 30,
      requiredActiveDays: 6,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    ),
    _ => const RankRule(
      rank: 'S',
      minimumLevel: 40,
      requiredActiveDays: 6,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    ),
  };
}

String? rankAfter(String rank) {
  return switch (rank.trim().toUpperCase()) {
    'E' => 'D',
    'D' => 'C',
    'C' => 'B',
    'B' => 'A',
    'A' => 'S',
    _ => null,
  };
}

String? rankBefore(String rank) {
  return switch (rank.trim().toUpperCase()) {
    'D' => 'E',
    'C' => 'D',
    'B' => 'C',
    'A' => 'B',
    'S' => 'A',
    _ => null,
  };
}

bool _isPromotionReady({
  required String currentRank,
  required int activeDays,
  required bool bossCompleted,
  required int playerLevel,
}) {
  final nextRank = rankAfter(currentRank);
  if (nextRank == null) return false;

  final nextRule = rankRuleFor(nextRank);
  final levelGateMet = playerLevel >= nextRule.minimumLevel;
  return levelGateMet &&
      activeDays >= nextRule.requiredActiveDays &&
      (!nextRule.requiresBossClear || bossCompleted);
}

String _summaryForStatus(
  RankMaintenanceStatus status,
  String currentRank, {
  required String? nextRank,
  required RankAdvancementMode? advancementMode,
}) {
  return switch (status) {
    RankMaintenanceStatus.secure => 'Rank $currentRank estabilizado.',
    RankMaintenanceStatus.warning => 'Rank $currentRank em alerta.',
    RankMaintenanceStatus.critical => 'Rank $currentRank em risco real.',
    RankMaintenanceStatus.promotionReady =>
      advancementMode == RankAdvancementMode.reconquest
          ? 'Reconquista pronta para o rank ${nextRank ?? currentRank}.'
          : 'Exame de promocao pronto para o rank ${nextRank ?? currentRank}.',
    RankMaintenanceStatus.demoted =>
      'Queda confirmada para o rank $currentRank.',
  };
}

String _detailForStatus({
  required RankMaintenanceStatus status,
  required String currentRank,
  required String peakRank,
  required String highestEligibleRank,
  required RankRule currentRule,
  required int activeDays,
  required bool bossCompleted,
  required int demotionStrikes,
  required String? nextRank,
  required int targetRequiredLevel,
  required bool targetLevelGateMet,
  required RankAdvancementMode? advancementMode,
}) {
  final bossLine = currentRule.requiresBossClear
      ? (bossCompleted
            ? 'Boss semanal concluido.'
            : 'Boss semanal ainda pendente.')
      : 'Boss semanal nao e exigido neste rank.';
  final levelLine = nextRank == null
      ? 'Voce ja esta no topo do sistema.'
      : targetLevelGateMet
          ? 'Seu level ja libera a tentativa do rank $nextRank.'
          : 'Seu level atual ainda nao libera o rank $nextRank. Necessario: level $targetRequiredLevel.';
  final reconquestLine = _rankOrder(currentRank) < _rankOrder(peakRank)
      ? 'Seu pico historico e $peakRank. O sistema abriu uma rota de reconquista acelerada.'
      : 'Seu teto atual por level chega ate o rank $highestEligibleRank.';

  return switch (status) {
    RankMaintenanceStatus.secure =>
      'Voce garantiu $activeDays/${currentRule.requiredActiveDays} dias ativos. $bossLine $reconquestLine $levelLine',
    RankMaintenanceStatus.warning =>
      'Voce tem $activeDays/${currentRule.requiredActiveDays} dias ativos. Falhar esta semana deixa o sistema em pressao real. $levelLine',
    RankMaintenanceStatus.critical =>
      'Voce esta abaixo da manutencao do rank $currentRank. Strikes atuais: $demotionStrikes. $bossLine',
    RankMaintenanceStatus.promotionReady =>
      advancementMode == RankAdvancementMode.reconquest
          ? 'Voce sustentou o padrao para reconquistar o rank ${nextRank ?? currentRank}. O exame agora valida a retomada do seu pico historico.'
          : 'Voce atingiu o padrao do proximo rank${nextRank == null ? '' : ' $nextRank'}. Agora falta transformar isso em exame de promocao.',
    RankMaintenanceStatus.demoted =>
      'A manutencao falhou por semanas seguidas. O sistema aplicou queda de rank para preservar a seriedade da progressao. Seu pico historico continua registrado em $peakRank.',
  };
}

String _higherRank(String rankA, String rankB) {
  return _rankOrder(rankA) >= _rankOrder(rankB) ? rankA : rankB;
}

int _rankOrder(String rank) {
  return switch (rank.trim().toUpperCase()) {
    'E' => 0,
    'D' => 1,
    'C' => 2,
    'B' => 3,
    'A' => 4,
    _ => 5,
  };
}

String _weekKeyFor(DateTime value) {
  final weekStart = weekStartFor(value);
  return '${weekStart.year}W${weekStart.month.toString().padLeft(2, '0')}${weekStart.day.toString().padLeft(2, '0')}';
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
