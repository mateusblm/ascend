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

class RankRule {
  const RankRule({
    required this.rank,
    required this.requiredActiveDays,
    required this.requiresBossClear,
    required this.maxFailedWeeksBeforeDemotion,
  });

  final String rank;
  final int requiredActiveDays;
  final bool requiresBossClear;
  final int maxFailedWeeksBeforeDemotion;
}

class CompetitiveRankSnapshot {
  const CompetitiveRankSnapshot({
    required this.currentRank,
    required this.weekKey,
    required this.activeDays,
    required this.requiredActiveDays,
    required this.requiresBossClear,
    required this.bossCompleted,
    required this.status,
    required this.demotionStrikes,
    required this.promotionReady,
    required this.promotionTargetRank,
    required this.summary,
    required this.detail,
    required this.updatedAt,
  });

  final String currentRank;
  final String weekKey;
  final int activeDays;
  final int requiredActiveDays;
  final bool requiresBossClear;
  final bool bossCompleted;
  final RankMaintenanceStatus status;
  final int demotionStrikes;
  final bool promotionReady;
  final String? promotionTargetRank;
  final String summary;
  final String detail;
  final DateTime updatedAt;

  bool get maintenanceMet => status == RankMaintenanceStatus.secure || status == RankMaintenanceStatus.promotionReady;

  Map<String, dynamic> toFirestore() {
    return {
      'currentRank': currentRank,
      'weekKey': weekKey,
      'activeDays': activeDays,
      'requiredActiveDays': requiredActiveDays,
      'requiresBossClear': requiresBossClear,
      'bossCompleted': bossCompleted,
      'status': status.name,
      'demotionStrikes': demotionStrikes,
      'promotionReady': promotionReady,
      'promotionTargetRank': promotionTargetRank,
      'summary': summary,
      'detail': detail,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CompetitiveRankSnapshot.fromFirestore(Map<String, dynamic> data) {
    return CompetitiveRankSnapshot(
      currentRank: (data['currentRank'] as String? ?? 'E').trim().toUpperCase(),
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
      summary: data['summary'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      updatedAt: _readTimestamp(data['updatedAt']),
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
  final seedRank = previousSnapshot?.currentRank ?? playerRankForLevel(player.level);
  final baseRule = rankRuleFor(seedRank);
  final boss = weeklyBossForRank(seedRank);
  final bossCompleted = boss.isCompleted(player);
  final activeDays = boss.progressFor(player);
  final maintenanceMet = activeDays >= baseRule.requiredActiveDays &&
      (!baseRule.requiresBossClear || bossCompleted);
  final isNewWeek = previousSnapshot == null || previousSnapshot.weekKey != weekKey;

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
  final currentBoss = weeklyBossForRank(currentRank);
  final currentBossCompleted = currentBoss.isCompleted(player);
  final currentActiveDays = currentBoss.progressFor(player);
  final currentMaintenanceMet = currentActiveDays >= currentRule.requiredActiveDays &&
      (!currentRule.requiresBossClear || currentBossCompleted);

  if (status != RankMaintenanceStatus.demoted) {
    final promotionReady = _isPromotionReady(
      currentRank: currentRank,
      activeDays: currentActiveDays,
      bossCompleted: currentBossCompleted,
    );
    if (promotionReady) {
      status = RankMaintenanceStatus.promotionReady;
    } else if (currentMaintenanceMet) {
      status = RankMaintenanceStatus.secure;
    } else {
      final missingDays = (currentRule.requiredActiveDays - currentActiveDays).clamp(0, currentRule.requiredActiveDays);
      final bossBlocked = currentRule.requiresBossClear && !currentBossCompleted;
      status = missingDays <= 1 && !bossBlocked
          ? RankMaintenanceStatus.warning
          : RankMaintenanceStatus.critical;
    }
  }

  final detail = _detailForStatus(
    status: status,
    currentRank: currentRank,
    currentRule: currentRule,
    activeDays: currentActiveDays,
    bossCompleted: currentBossCompleted,
    demotionStrikes: demotionStrikes,
    nextRank: nextRank,
  );

  return CompetitiveRankSnapshot(
    currentRank: currentRank,
    weekKey: weekKey,
    activeDays: currentActiveDays,
    requiredActiveDays: currentRule.requiredActiveDays,
    requiresBossClear: currentRule.requiresBossClear,
    bossCompleted: currentBossCompleted,
    status: status,
    demotionStrikes: demotionStrikes,
    promotionReady: status == RankMaintenanceStatus.promotionReady,
    promotionTargetRank: nextRank,
    summary: _summaryForStatus(status, currentRank),
    detail: detail,
    updatedAt: currentDate,
  );
}

RankRule rankRuleFor(String rank) {
  final normalizedRank = rank.trim().toUpperCase();
  return switch (normalizedRank) {
    'E' => const RankRule(
        rank: 'E',
        requiredActiveDays: 3,
        requiresBossClear: false,
        maxFailedWeeksBeforeDemotion: 2,
      ),
    'D' => const RankRule(
        rank: 'D',
        requiredActiveDays: 4,
        requiresBossClear: false,
        maxFailedWeeksBeforeDemotion: 2,
      ),
    'C' => const RankRule(
        rank: 'C',
        requiredActiveDays: 5,
        requiresBossClear: true,
        maxFailedWeeksBeforeDemotion: 2,
      ),
    'B' => const RankRule(
        rank: 'B',
        requiredActiveDays: 5,
        requiresBossClear: true,
        maxFailedWeeksBeforeDemotion: 2,
      ),
    'A' => const RankRule(
        rank: 'A',
        requiredActiveDays: 6,
        requiresBossClear: true,
        maxFailedWeeksBeforeDemotion: 2,
      ),
    _ => const RankRule(
        rank: 'S',
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
}) {
  final nextRank = rankAfter(currentRank);
  if (nextRank == null) return false;

  final nextRule = rankRuleFor(nextRank);
  return activeDays >= nextRule.requiredActiveDays &&
      (!nextRule.requiresBossClear || bossCompleted);
}

String _summaryForStatus(RankMaintenanceStatus status, String currentRank) {
  return switch (status) {
    RankMaintenanceStatus.secure => 'Rank $currentRank estabilizado.',
    RankMaintenanceStatus.warning => 'Rank $currentRank em alerta.',
    RankMaintenanceStatus.critical => 'Rank $currentRank em risco real.',
    RankMaintenanceStatus.promotionReady => 'Exame de promocao pronto para o rank ${rankAfter(currentRank) ?? currentRank}.',
    RankMaintenanceStatus.demoted => 'Queda confirmada para o rank $currentRank.',
  };
}

String _detailForStatus({
  required RankMaintenanceStatus status,
  required String currentRank,
  required RankRule currentRule,
  required int activeDays,
  required bool bossCompleted,
  required int demotionStrikes,
  required String? nextRank,
}) {
  final bossLine = currentRule.requiresBossClear
      ? (bossCompleted ? 'Boss semanal concluido.' : 'Boss semanal ainda pendente.')
      : 'Boss semanal nao e exigido neste rank.';

  return switch (status) {
    RankMaintenanceStatus.secure =>
      'Voce garantiu $activeDays/${currentRule.requiredActiveDays} dias ativos. $bossLine',
    RankMaintenanceStatus.warning =>
      'Voce tem $activeDays/${currentRule.requiredActiveDays} dias ativos. Falhar esta semana deixa o sistema em pressao real.',
    RankMaintenanceStatus.critical =>
      'Voce esta abaixo da manutencao do rank $currentRank. Strikes atuais: $demotionStrikes. $bossLine',
    RankMaintenanceStatus.promotionReady =>
      'Voce atingiu o padrao do proximo rank${nextRank == null ? '' : ' $nextRank'}. Agora falta transformar isso em exame de promocao.',
    RankMaintenanceStatus.demoted =>
      'A manutencao falhou por semanas seguidas. O sistema aplicou queda de rank para preservar a seriedade da progressao.',
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
