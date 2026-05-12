import * as admin from 'firebase-admin';
import { normalizedDateFromKey, normalizedDateKey } from '../shared/date';
import { rankOrder } from './rank';

const COMPETITIVE_SYNC_SCHEMA_VERSION = 3;

export type CompetitiveSnapshotForSeason = {
  currentRank: string;
  peakRank: string;
  highestEligibleRank: string;
  weekKey: string;
  activeDays: number;
  requiredActiveDays: number;
  requiresBossClear: boolean;
  bossCompleted: boolean;
  status: string;
  demotionStrikes: number;
  promotionReady: boolean;
  promotionTargetRank: string | null;
  targetRequiredLevel: number;
  targetLevelGateMet: boolean;
  advancementMode: string | null;
  eventType: string;
  summary: string;
  detail: string;
  syncSchemaVersion: number;
  syncSource: string;
  updatedAt: admin.firestore.Timestamp;
};

export type CompetitiveExamForResolution = {
  status: string;
  sourceWeekKey: string;
  expiresAt: admin.firestore.Timestamp;
  baselineActiveDays: number;
  requiredExtraActiveDays: number;
  bossRequired: boolean;
  resolvedAt: admin.firestore.Timestamp | null;
  syncSchemaVersion: number;
  syncSource: string;
};

export type SeasonRewardRecord = {
  seasonKey: string;
  seasonLabel: string;
  currentRankBracket: string;
  rewardTierLabel: string;
  rewardStatusLabel: string;
  rewardUnlocked: boolean;
  rewardName: string;
  rewardBadgeLabel: string;
  rewardTitleLabel: string;
  rewardBonusLabel: string;
  recordedWeeks: number;
  secureWeeks: number;
  seasonScore: number;
  scoreBandLabel: string;
  clearRateLabel: string;
  playerStandingLabel: string;
  spotlightLabel: string;
  resetLabel: string;
  claimStatus: string;
  syncSchemaVersion: number;
  syncSource: string;
  updatedAt: admin.firestore.Timestamp;
  claimedAt: admin.firestore.Timestamp | null;
};

export function weekStartDate(value: Date): Date {
  const normalized = new Date(value.getFullYear(), value.getMonth(), value.getDate());
  return new Date(
    normalized.getFullYear(),
    normalized.getMonth(),
    normalized.getDate() - (normalized.getDay() === 0 ? 6 : normalized.getDay() - 1),
  );
}

export function weekKeyForDate(value: Date): string {
  const weekStart = weekStartDate(value);
  return `${weekStart.getFullYear()}W${String(weekStart.getMonth() + 1).padStart(2, '0')}${String(
    weekStart.getDate(),
  ).padStart(2, '0')}`;
}

export function dateFromWeekKey(weekKey: string): Date | null {
  const parts = weekKey.split('W');
  if (parts.length !== 2 || parts[1].length !== 4) return null;
  const year = Number(parts[0]);
  const month = Number(parts[1].slice(0, 2));
  const day = Number(parts[1].slice(2, 4));
  if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day)) {
    return null;
  }
  return new Date(year, month - 1, day);
}

export function currentWeekDateKeys(
  values: admin.firestore.Timestamp[],
  now: Date,
): Set<string> {
  const weekStart = weekStartDate(now);
  const weekEnd = new Date(weekStart.getFullYear(), weekStart.getMonth(), weekStart.getDate() + 7);
  return new Set(
    values
      .map((entry) => normalizedDateFromKey(normalizedDateKey(entry)))
      .filter((date) => date >= weekStart && date < weekEnd)
      .map((date) => normalizedDateKey(date)),
  );
}

export function resolveExamAfterSnapshot(args: {
  snapshot: CompetitiveSnapshotForSeason;
  currentExam: CompetitiveExamForResolution | null;
  now: admin.firestore.Timestamp;
}) {
  const {snapshot, currentExam, now} = args;
  if (!currentExam) return null;
  if (currentExam.status !== 'inProgress') {
    return {
      ...currentExam,
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
    };
  }

  if (
    snapshot.weekKey !== currentExam.sourceWeekKey ||
    now.toMillis() > currentExam.expiresAt.toMillis()
  ) {
    return {
      ...currentExam,
      status: 'failed',
      resolvedAt: now,
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
    };
  }

  const targetActiveDays = currentExam.baselineActiveDays + currentExam.requiredExtraActiveDays;
  const passed =
    snapshot.activeDays >= targetActiveDays &&
    (!currentExam.bossRequired || snapshot.bossCompleted);
  if (!passed) {
    return {
      ...currentExam,
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
    };
  }

  return {
    ...currentExam,
    status: 'passed',
    resolvedAt: now,
    syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
    syncSource: 'backend',
  };
}

export function seasonBoundsFor(now: Date) {
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 1);
  return {start, end};
}

export function seasonKeyFor(now: Date): string {
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

export function seasonLabelFor(now: Date): string {
  const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
  return `${months[now.getMonth()]} ${now.getFullYear()}`;
}

export function seasonWeekCapacity(now: Date): number {
  const bounds = seasonBoundsFor(now);
  return Math.ceil((bounds.end.getTime() - bounds.start.getTime()) / (7 * 24 * 60 * 60 * 1000));
}

export function remainingSeasonWeeks(now: Date, seasonEnd: Date): number {
  const normalizedNow = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (normalizedNow >= seasonEnd) return 0;
  const days = Math.floor((seasonEnd.getTime() - normalizedNow.getTime()) / (24 * 60 * 60 * 1000));
  return Math.floor((days + 6) / 7);
}

export function resetLabelFor(now: Date, seasonEnd: Date): string {
  const normalizedNow = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const days = Math.floor((seasonEnd.getTime() - normalizedNow.getTime()) / (24 * 60 * 60 * 1000));
  if (days <= 0) return 'Reset em andamento';
  if (days === 1) return 'Reset amanha';
  if (days <= 7) return `Reset em ${days} dias`;
  return `Reset em ${Math.floor((days + 6) / 7)} semana(s)`;
}

export function rewardTrackForSeason(args: {
  secureWeeks: number;
  totalSeasonWeeks: number;
  promotionEvents: number;
  perfectWeeks: number;
  demotionEvents: number;
}) {
  if (args.demotionEvents > 0) {
    return {
      statusLabel: 'INSTAVEL',
      trackLabel: `${args.secureWeeks}/${args.totalSeasonWeeks} semanas seguras`,
      progress: Math.min(1, args.secureWeeks / args.totalSeasonWeeks),
      nextUnlockHint:
        'Elimine quedas e reconstrua 2 semanas seguras para voltar ao circuito sazonal.',
    };
  }
  if (args.secureWeeks < 2) {
    return {
      statusLabel: 'ABRINDO TRILHA',
      trackLabel: `${args.secureWeeks}/2 semanas seguras`,
      progress: Math.min(1, args.secureWeeks / 2),
      nextUnlockHint: `Mais ${2 - args.secureWeeks} semana(s) segura(s) para garantir a recompensa basica.`,
    };
  }
  if (args.secureWeeks < 3) {
    return {
      statusLabel: 'EM ROTA',
      trackLabel: `${args.secureWeeks}/3 semanas seguras`,
      progress: Math.min(1, args.secureWeeks / 3),
      nextUnlockHint: `Mais ${3 - args.secureWeeks} semana(s) segura(s) para destravar DOMINIO.`,
    };
  }
  if (args.promotionEvents < 1 || args.perfectWeeks < 1) {
    const missing: string[] = [];
    if (args.promotionEvents < 1) missing.push('1 promocao confirmada');
    if (args.perfectWeeks < 1) missing.push('1 semana perfeita');
    return {
      statusLabel: 'RECOMPENSA AVANCADA',
      trackLabel: `${args.secureWeeks}/${args.totalSeasonWeeks} semanas seguras`,
      progress: 0.85,
      nextUnlockHint: `Falta ${missing.join(' e ')} para atingir ASCENSAO nesta temporada.`,
    };
  }
  return {
    statusLabel: 'GARANTIDA',
    trackLabel: `${args.secureWeeks}/${args.totalSeasonWeeks} semanas seguras`,
    progress: 1,
    nextUnlockHint:
      'A trilha sazonal principal ja foi garantida. Agora o objetivo e fechar a temporada sem queda.',
  };
}

export function rewardTierForSeason(args: {
  secureWeeks: number;
  promotionEvents: number;
  perfectWeeks: number;
  demotionEvents: number;
}) {
  if (args.promotionEvents >= 1 && args.perfectWeeks >= 1 && args.demotionEvents === 0) {
    return {
      label: 'ASCENSAO',
      preview: 'Selo de temporada limpa, moldura premium de rank e bonus futuro de prestigio.',
    };
  }
  if (args.secureWeeks >= 3 && args.demotionEvents === 0) {
    return {
      label: 'DOMINIO',
      preview: 'Recompensa futura de emblema competitivo e destaque no historico sazonal.',
    };
  }
  if (args.secureWeeks >= 2) {
    return {
      label: 'MANUTENCAO',
      preview: 'Temporada consistente. Voce ja esta em rota de recompensa sazonal basica.',
    };
  }
  if (args.demotionEvents > 0) {
    return {
      label: 'INSTAVEL',
      preview: 'Sem recompensa sazonal por enquanto. O sistema exige estabilizacao antes do reset.',
    };
  }
  return {
    label: 'EM FORMACAO',
    preview: 'Acumule semanas registradas para destravar a trilha de recompensa da temporada.',
  };
}

export function rewardPayloadForSeason(tierLabel: string, rewardStatusLabel: string) {
  switch (tierLabel) {
  case 'ASCENSAO':
    return {
      unlocked: true,
      rewardName: 'Pacote Ascensao da Temporada',
      badgeLabel: 'SIGILO DE OURO',
      titleLabel: 'ASCENDENTE DA TEMPORADA',
      bonusLabel: 'Moldura premium de rank, selo dourado e destaque maximo no historico sazonal.',
    };
  case 'DOMINIO':
    return {
      unlocked: true,
      rewardName: 'Pacote Dominio do Rank',
      badgeLabel: 'SIGILO DE PRATA',
      titleLabel: 'COMANDANTE DO RANK',
      bonusLabel: 'Moldura de temporada, selo prateado e destaque elevado no historico competitivo.',
    };
  case 'MANUTENCAO':
    return {
      unlocked: true,
      rewardName: 'Pacote de Manutencao',
      badgeLabel: 'SIGILO DE BRONZE',
      titleLabel: 'VIGIA DO CICLO',
      bonusLabel: 'Insignia sazonal, selo de consistencia e registro de temporada valida.',
    };
  case 'INSTAVEL':
    return {
      unlocked: false,
      rewardName: 'Pacote em recuperacao',
      badgeLabel: 'EM RISCO',
      titleLabel: 'RECUPERANDO POSICAO',
      bonusLabel:
        rewardStatusLabel === 'INSTAVEL'
          ? 'Sem premio liberado. Reconstrua a trilha com semanas seguras.'
          : 'A trilha ainda nao estabilizou o bastante para liberar premio.',
    };
  default:
    return {
      unlocked: false,
      rewardName: 'Trilha sazonal bloqueada',
      badgeLabel: 'SEM EMBLEMA',
      titleLabel: 'Sem titulo sazonal',
      bonusLabel: 'Nenhum pacote sazonal liberado.',
    };
  }
}

export function seasonScoreForSnapshotHistory(history: CompetitiveSnapshotForSeason[]) {
  const secureWeeks = history.filter((entry) => entry.status === 'secure' || entry.status === 'promotionReady').length;
  const examWeeks = history.filter(
    (entry) => entry.eventType === 'promotionUnlocked' || entry.eventType === 'promotionConfirmed',
  ).length;
  const promotionEvents = history.filter((entry) => entry.eventType === 'promotionConfirmed').length;
  const perfectWeeks = history.filter((entry) => entry.eventType === 'perfectWeek').length;
  const demotionEvents = history.filter((entry) => entry.status === 'demoted').length;
  return {
    secureWeeks,
    examWeeks,
    promotionEvents,
    perfectWeeks,
    demotionEvents,
    seasonScore: secureWeeks * 3 + examWeeks * 2 + promotionEvents * 5 + perfectWeeks * 4 - demotionEvents * 4,
  };
}

export function scoreBandForSeasonScore(score: number) {
  if (score >= 16) return 'LIDERANCA';
  if (score >= 10) return 'ELITE';
  if (score >= 6) return 'DISPUTA';
  return 'RECUPERACAO';
}

export function playerStandingForSeasonScore(score: number): string {
  if (score >= 16) return 'LIDER DO RANK';
  if (score >= 10) return 'NA ZONA DE PRESTIGIO';
  if (score >= 6) return 'NA DISPUTA';
  return 'FORA DO CORTE';
}

export function buildSeasonRewardFromHistory(args: {
  history: CompetitiveSnapshotForSeason[];
  snapshot: CompetitiveSnapshotForSeason;
  currentReward: SeasonRewardRecord | null;
  now: Date;
}): SeasonRewardRecord {
  const seasonKey = seasonKeyFor(args.now);
  const seasonLabel = seasonLabelFor(args.now);
  const bounds = seasonBoundsFor(args.now);
  const seasonEntries = args.history
    .filter((entry) => {
      const date = dateFromWeekKey(entry.weekKey);
      return date != null && date >= bounds.start && date < bounds.end;
    })
    .sort((a, b) => rankOrder(b.currentRank) - rankOrder(a.currentRank));

  const totalSeasonWeeks = seasonWeekCapacity(args.now);
  const updatedAt = admin.firestore.Timestamp.fromDate(args.now);

  if (seasonEntries.length === 0) {
    const lockedReward = rewardPayloadForSeason('EM FORMACAO', 'BLOQUEADA');
    return {
      seasonKey,
      seasonLabel,
      currentRankBracket: args.snapshot.currentRank,
      rewardTierLabel: 'SEM DADOS',
      rewardStatusLabel: 'BLOQUEADA',
      rewardUnlocked: false,
      rewardName: lockedReward.rewardName,
      rewardBadgeLabel: lockedReward.badgeLabel,
      rewardTitleLabel: lockedReward.titleLabel,
      rewardBonusLabel: lockedReward.bonusLabel,
      recordedWeeks: 0,
      secureWeeks: 0,
      seasonScore: 0,
      scoreBandLabel: 'RECUPERACAO',
      clearRateLabel: 'Clear rate aguardando lobby',
      playerStandingLabel: 'FORA DO CORTE',
      spotlightLabel: 'Sem boss ativo. O placar sazonal volta com a proxima rotacao.',
      resetLabel: resetLabelFor(args.now, bounds.end),
      claimStatus: 'locked',
      syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
      syncSource: 'backend',
      updatedAt,
      claimedAt: null,
    };
  }

  const seasonScoreData = seasonScoreForSnapshotHistory(seasonEntries);
  const rewardTier = rewardTierForSeason({
    secureWeeks: seasonScoreData.secureWeeks,
    promotionEvents: seasonScoreData.promotionEvents,
    perfectWeeks: seasonScoreData.perfectWeeks,
    demotionEvents: seasonScoreData.demotionEvents,
  });
  const rewardTrack = rewardTrackForSeason({
    secureWeeks: seasonScoreData.secureWeeks,
    totalSeasonWeeks,
    promotionEvents: seasonScoreData.promotionEvents,
    perfectWeeks: seasonScoreData.perfectWeeks,
    demotionEvents: seasonScoreData.demotionEvents,
  });
  const rewardPayload = rewardPayloadForSeason(rewardTier.label, rewardTrack.statusLabel);
  const previousClaimed =
    args.currentReward != null &&
    args.currentReward.seasonKey === seasonKey &&
    args.currentReward.claimStatus === 'claimed';
  const claimStatus = previousClaimed
    ? 'claimed'
    : rewardPayload.unlocked
      ? 'readyToClaim'
      : 'locked';

  return {
    seasonKey,
    seasonLabel,
    currentRankBracket: args.snapshot.currentRank,
    rewardTierLabel: rewardTier.label,
    rewardStatusLabel: rewardTrack.statusLabel,
    rewardUnlocked: rewardPayload.unlocked,
    rewardName: rewardPayload.rewardName,
    rewardBadgeLabel: rewardPayload.badgeLabel,
    rewardTitleLabel: rewardPayload.titleLabel,
    rewardBonusLabel: rewardPayload.bonusLabel,
    recordedWeeks: seasonEntries.length,
    secureWeeks: seasonScoreData.secureWeeks,
    seasonScore: seasonScoreData.seasonScore,
    scoreBandLabel: scoreBandForSeasonScore(seasonScoreData.seasonScore),
    clearRateLabel: 'Clear rate aguardando lobby',
    playerStandingLabel: playerStandingForSeasonScore(seasonScoreData.seasonScore),
    spotlightLabel: 'Sem boss ativo. O placar sazonal volta com a proxima rotacao.',
    resetLabel: resetLabelFor(args.now, bounds.end),
    claimStatus,
    syncSchemaVersion: COMPETITIVE_SYNC_SCHEMA_VERSION,
    syncSource: 'backend',
    updatedAt,
    claimedAt: previousClaimed ? args.currentReward?.claimedAt ?? null : null,
  };
}

export function buildSeasonLegacyPayload(
  seasonReward: SeasonRewardRecord,
  claimedAt: admin.firestore.Timestamp,
) {
  const cosmetics = buildSeasonCosmetics(
    seasonReward.rewardTierLabel,
    seasonReward.currentRankBracket,
    seasonReward.scoreBandLabel,
  );

  return {
    seasonKey: seasonReward.seasonKey,
    seasonLabel: seasonReward.seasonLabel,
    claimedRankBracket: seasonReward.currentRankBracket,
    rewardTierLabel: seasonReward.rewardTierLabel,
    rewardName: seasonReward.rewardName,
    rewardBadgeLabel: seasonReward.rewardBadgeLabel,
    rewardTitleLabel: seasonReward.rewardTitleLabel,
    rewardBonusLabel: seasonReward.rewardBonusLabel,
    scoreBandLabel: seasonReward.scoreBandLabel,
    seasonScore: seasonReward.seasonScore,
    playerStandingLabel: seasonReward.playerStandingLabel,
    spotlightLabel: seasonReward.spotlightLabel,
    cosmeticFrameLabel: cosmetics.frameLabel,
    cosmeticAuraLabel: cosmetics.auraLabel,
    claimedAt,
    syncSchemaVersion: seasonReward.syncSchemaVersion,
    syncSource: 'backend',
    updatedAt: claimedAt,
  };
}

export function buildSeasonProfilePayload(
  legacyReward: ReturnType<typeof buildSeasonLegacyPayload>,
) {
  return {
    activeSeasonKey: legacyReward.seasonKey,
    activeSeasonLabel: legacyReward.seasonLabel,
    activeRewardName: legacyReward.rewardName,
    activeBadgeLabel: legacyReward.rewardBadgeLabel,
    activeTitleLabel: legacyReward.rewardTitleLabel,
    cosmeticFrameLabel: legacyReward.cosmeticFrameLabel,
    cosmeticAuraLabel: legacyReward.cosmeticAuraLabel,
    equippedAt: legacyReward.claimedAt,
    syncSchemaVersion: legacyReward.syncSchemaVersion,
    syncSource: 'backend',
    updatedAt: legacyReward.updatedAt,
  };
}

export function buildSeasonCosmetics(
  rewardTierLabel: string,
  rankBracket: string,
  scoreBandLabel: string,
) {
  const tier = rewardTierLabel.trim().toUpperCase();
  const band = scoreBandLabel.trim().toUpperCase();

  if (band === 'LIDERANCA' || rankBracket === 'S') {
    return {
      frameLabel: 'QUADRO SOBERANO',
      auraLabel: 'AURA DO COMANDANTE',
    };
  }
  if (band === 'ELITE' || rankBracket === 'A') {
    return {
      frameLabel: 'QUADRO VANGUARDA',
      auraLabel: 'AURA AZUL ASCENDENTE',
    };
  }
  if (tier.includes('MANUTENCAO') || rankBracket === 'B' || rankBracket === 'C') {
    return {
      frameLabel: 'QUADRO DE BRONZE',
      auraLabel: 'AURA DE DISCIPLINA',
    };
  }

  return {
    frameLabel: 'QUADRO DE FERRO',
    auraLabel: 'AURA CONTIDA',
  };
}
