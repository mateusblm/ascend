import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = Provider<AppAnalytics>((ref) {
  try {
    if (Firebase.apps.isEmpty) {
      return const NoopAppAnalytics();
    }
    final analytics = FirebaseAnalytics.instance;
    return FirebaseAppAnalytics(
      analytics: analytics,
      observer: FirebaseAnalyticsObserver(analytics: analytics),
    );
  } catch (_) {
    return const NoopAppAnalytics();
  }
});

final analyticsNavigationObserverProvider = Provider<NavigatorObserver?>((ref) {
  return ref.watch(analyticsProvider).navigatorObserver;
});

abstract class AppAnalytics {
  const AppAnalytics();

  NavigatorObserver? get navigatorObserver => null;

  Future<void> setUserId(String? uid);

  Future<void> logAuthLoginStarted();

  Future<void> logAuthLoginCancelled();

  Future<void> logAuthLoginSucceeded({required bool restoredSession});

  Future<void> logAuthLoginFailed({required String reason});

  Future<void> logAuthSignedOut();

  Future<void> logOnboardingCompleted({
    required String focus,
    required int starterKitSize,
    required int competitiveQuestCount,
    required int personalQuestCount,
  });

  Future<void> logFocusChanged({
    required String from,
    required String to,
  });

  Future<void> logStarterKitApplied({
    required String focus,
    required int totalCount,
    required int competitiveCount,
    required int personalCount,
  });

  Future<void> logQuestCreated({
    required String category,
    required String verificationMode,
    required int xpReward,
    String? templateType,
  });

  Future<void> logCompetitiveQuestStarted({
    required String verificationMode,
    required int targetDurationMinutes,
    String? templateType,
  });

  Future<void> logCompetitiveQuestBlocked({
    required String reason,
    required String verificationMode,
    String? templateType,
  });

  Future<void> logQuestCompleted({
    required String category,
    required String verificationMode,
    required int xpReward,
    required bool countsTowardRank,
    required int levelAfter,
    String? templateType,
  });

  Future<void> logSuggestedWeekAdded({required int addedCount});

  Future<void> logWeeklyBossClaimed({
    required String bossId,
    required String rank,
    required String status,
  });

  Future<void> logPromotionExamStarted({
    required String sourceRank,
    required String targetRank,
    required String mode,
    required String status,
  });

  Future<void> logPromotionConfirmed({
    required String sourceRank,
    required String targetRank,
    required String mode,
    required String status,
  });

  Future<void> logSeasonRewardClaimed({
    required String seasonKey,
    required String rewardName,
    required String status,
  });
}

class NoopAppAnalytics extends AppAnalytics {
  const NoopAppAnalytics();

  @override
  Future<void> setUserId(String? uid) async {}

  @override
  Future<void> logAuthLoginStarted() async {}

  @override
  Future<void> logAuthLoginCancelled() async {}

  @override
  Future<void> logAuthLoginSucceeded({required bool restoredSession}) async {}

  @override
  Future<void> logAuthLoginFailed({required String reason}) async {}

  @override
  Future<void> logAuthSignedOut() async {}

  @override
  Future<void> logOnboardingCompleted({
    required String focus,
    required int starterKitSize,
    required int competitiveQuestCount,
    required int personalQuestCount,
  }) async {}

  @override
  Future<void> logFocusChanged({
    required String from,
    required String to,
  }) async {}

  @override
  Future<void> logStarterKitApplied({
    required String focus,
    required int totalCount,
    required int competitiveCount,
    required int personalCount,
  }) async {}

  @override
  Future<void> logQuestCreated({
    required String category,
    required String verificationMode,
    required int xpReward,
    String? templateType,
  }) async {}

  @override
  Future<void> logCompetitiveQuestStarted({
    required String verificationMode,
    required int targetDurationMinutes,
    String? templateType,
  }) async {}

  @override
  Future<void> logCompetitiveQuestBlocked({
    required String reason,
    required String verificationMode,
    String? templateType,
  }) async {}

  @override
  Future<void> logQuestCompleted({
    required String category,
    required String verificationMode,
    required int xpReward,
    required bool countsTowardRank,
    required int levelAfter,
    String? templateType,
  }) async {}

  @override
  Future<void> logSuggestedWeekAdded({required int addedCount}) async {}

  @override
  Future<void> logWeeklyBossClaimed({
    required String bossId,
    required String rank,
    required String status,
  }) async {}

  @override
  Future<void> logPromotionExamStarted({
    required String sourceRank,
    required String targetRank,
    required String mode,
    required String status,
  }) async {}

  @override
  Future<void> logPromotionConfirmed({
    required String sourceRank,
    required String targetRank,
    required String mode,
    required String status,
  }) async {}

  @override
  Future<void> logSeasonRewardClaimed({
    required String seasonKey,
    required String rewardName,
    required String status,
  }) async {}
}

class FirebaseAppAnalytics extends AppAnalytics {
  FirebaseAppAnalytics({
    required FirebaseAnalytics analytics,
    required FirebaseAnalyticsObserver observer,
  }) : _analytics = analytics,
       _observer = observer;

  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsObserver _observer;

  @override
  NavigatorObserver get navigatorObserver => _observer;

  @override
  Future<void> setUserId(String? uid) async {
    await _analytics.setUserId(id: uid);
  }

  @override
  Future<void> logAuthLoginStarted() => _log('auth_login_started');

  @override
  Future<void> logAuthLoginCancelled() => _log('auth_login_cancelled');

  @override
  Future<void> logAuthLoginSucceeded({required bool restoredSession}) {
    return _log('auth_login_succeeded', {
      'restored_session': restoredSession,
    });
  }

  @override
  Future<void> logAuthLoginFailed({required String reason}) {
    return _log('auth_login_failed', {
      'reason': reason,
    });
  }

  @override
  Future<void> logAuthSignedOut() => _log('auth_signed_out');

  @override
  Future<void> logOnboardingCompleted({
    required String focus,
    required int starterKitSize,
    required int competitiveQuestCount,
    required int personalQuestCount,
  }) {
    return _log('onboarding_completed', {
      'focus': focus,
      'starter_kit_size': starterKitSize,
      'competitive_count': competitiveQuestCount,
      'personal_count': personalQuestCount,
    });
  }

  @override
  Future<void> logFocusChanged({
    required String from,
    required String to,
  }) {
    return _log('focus_changed', {
      'from': from,
      'to': to,
    });
  }

  @override
  Future<void> logStarterKitApplied({
    required String focus,
    required int totalCount,
    required int competitiveCount,
    required int personalCount,
  }) {
    return _log('starter_kit_applied', {
      'focus': focus,
      'total_count': totalCount,
      'competitive_count': competitiveCount,
      'personal_count': personalCount,
    });
  }

  @override
  Future<void> logQuestCreated({
    required String category,
    required String verificationMode,
    required int xpReward,
    String? templateType,
  }) {
    return _log('quest_created', {
      'category': category,
      'verification_mode': verificationMode,
      'xp_reward': xpReward,
      if (templateType != null) 'template_type': templateType,
    });
  }

  @override
  Future<void> logCompetitiveQuestStarted({
    required String verificationMode,
    required int targetDurationMinutes,
    String? templateType,
  }) {
    return _log('competitive_quest_started', {
      'verification_mode': verificationMode,
      'target_minutes': targetDurationMinutes,
      if (templateType != null) 'template_type': templateType,
    });
  }

  @override
  Future<void> logCompetitiveQuestBlocked({
    required String reason,
    required String verificationMode,
    String? templateType,
  }) {
    return _log('competitive_quest_blocked', {
      'reason': reason,
      'verification_mode': verificationMode,
      if (templateType != null) 'template_type': templateType,
    });
  }

  @override
  Future<void> logQuestCompleted({
    required String category,
    required String verificationMode,
    required int xpReward,
    required bool countsTowardRank,
    required int levelAfter,
    String? templateType,
  }) {
    return _log('quest_completed', {
      'category': category,
      'verification_mode': verificationMode,
      'xp_reward': xpReward,
      'counts_toward_rank': countsTowardRank,
      'level_after': levelAfter,
      if (templateType != null) 'template_type': templateType,
    });
  }

  @override
  Future<void> logSuggestedWeekAdded({required int addedCount}) {
    return _log('suggested_week_added', {
      'added_count': addedCount,
    });
  }

  @override
  Future<void> logWeeklyBossClaimed({
    required String bossId,
    required String rank,
    required String status,
  }) {
    return _log('weekly_boss_claimed', {
      'boss_id': bossId,
      'rank': rank,
      'status': status,
    });
  }

  @override
  Future<void> logPromotionExamStarted({
    required String sourceRank,
    required String targetRank,
    required String mode,
    required String status,
  }) {
    return _log('promotion_exam_started', {
      'source_rank': sourceRank,
      'target_rank': targetRank,
      'mode': mode,
      'status': status,
    });
  }

  @override
  Future<void> logPromotionConfirmed({
    required String sourceRank,
    required String targetRank,
    required String mode,
    required String status,
  }) {
    return _log('promotion_confirmed', {
      'source_rank': sourceRank,
      'target_rank': targetRank,
      'mode': mode,
      'status': status,
    });
  }

  @override
  Future<void> logSeasonRewardClaimed({
    required String seasonKey,
    required String rewardName,
    required String status,
  }) {
    return _log('season_reward_claimed', {
      'season_key': seasonKey,
      'reward_name': rewardName,
      'status': status,
    });
  }

  Future<void> _log(String name, [Map<String, Object?> params = const {}]) async {
    final cleanParams = <String, Object>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value is String || value is num || value is bool) {
        cleanParams[entry.key] = value as Object;
      }
    }
    await _analytics.logEvent(name: name, parameters: cleanParams);
  }
}
