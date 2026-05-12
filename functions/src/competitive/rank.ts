export function rankOrder(rank: string): number {
  switch (rank.trim().toUpperCase()) {
  case 'E':
    return 0;
  case 'D':
    return 1;
  case 'C':
    return 2;
  case 'B':
    return 3;
  case 'A':
    return 4;
  default:
    return 5;
  }
}

export function rankAfter(rank: string): string | null {
  switch (rank.trim().toUpperCase()) {
  case 'E':
    return 'D';
  case 'D':
    return 'C';
  case 'C':
    return 'B';
  case 'B':
    return 'A';
  case 'A':
    return 'S';
  default:
    return null;
  }
}

export function higherRank(rankA: string, rankB: string): string {
  return rankOrder(rankA) >= rankOrder(rankB) ? rankA : rankB;
}

export function rankRequirements(rank: string) {
  switch (rank.trim().toUpperCase()) {
  case 'E':
    return {
      minimumLevel: 1,
      requiredActiveDays: 3,
      requiresBossClear: false,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'D':
    return {
      minimumLevel: 5,
      requiredActiveDays: 4,
      requiresBossClear: false,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'C':
    return {
      minimumLevel: 10,
      requiredActiveDays: 5,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'B':
    return {
      minimumLevel: 20,
      requiredActiveDays: 5,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  case 'A':
    return {
      minimumLevel: 30,
      requiredActiveDays: 6,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  default:
    return {
      minimumLevel: 40,
      requiredActiveDays: 6,
      requiresBossClear: true,
      maxFailedWeeksBeforeDemotion: 2,
    };
  }
}

export function playerRankForLevel(level: number): string {
  if (level < 5) return 'E';
  if (level < 10) return 'D';
  if (level < 20) return 'C';
  if (level < 30) return 'B';
  if (level < 40) return 'A';
  return 'S';
}

export function rankBefore(rank: string): string | null {
  switch (rank.trim().toUpperCase()) {
  case 'D':
    return 'E';
  case 'C':
    return 'D';
  case 'B':
    return 'C';
  case 'A':
    return 'B';
  case 'S':
    return 'A';
  default:
    return null;
  }
}
