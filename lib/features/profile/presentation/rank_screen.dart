import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RankScreen extends ConsumerWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final snapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
    final history = ref.watch(rankProgressionHistoryProvider).valueOrNull ?? const <CompetitiveRankSnapshot>[];
    final exam = ref.watch(promotionExamProvider).valueOrNull;
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final topCompletions = ref.watch(weeklyBossTopCompletionsProvider);
    final debugSyncPaused = ref.watch(debugRankSyncPausedProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(snapshot, player),
              const SizedBox(height: 24),
              _buildMaintenanceCard(snapshot, player),
              const SizedBox(height: 12),
              _buildPromotionExamCard(context, ref, snapshot, exam),
              const SizedBox(height: 12),
              _buildRankBossCard(player, remoteWeeklyBoss, topCompletions),
              const SizedBox(height: 12),
              _buildHistoryCard(history),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                _buildDebugCard(
                  context,
                  ref,
                  player,
                  snapshot,
                  exam,
                  debugSyncPaused,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CompetitiveRankSnapshot? snapshot, Player player) {
    final rank = snapshot?.currentRank ?? playerRankForLevel(player.level);
    final color = _statusColor(snapshot?.status ?? RankMaintenanceStatus.secure);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAMARA DE RANK',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
        const Divider(color: AppColors.neonBlue, thickness: 1),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.neonBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RANK ATUAL',
                      style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rank,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: color.withOpacity(0.8), blurRadius: 22)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot?.summary ?? 'Seu rank competitivo ainda esta sincronizando.',
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('LEVEL', style: TextStyle(fontSize: 10, color: Colors.white38)),
                  Text(
                    player.level.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(CompetitiveRankSnapshot? snapshot, Player player) {
    final currentRank = snapshot?.currentRank ?? playerRankForLevel(player.level);
    final rule = rankRuleFor(currentRank);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor(status).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANUTENCAO DO RANK',
            style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metric('STATUS', _statusLabel(status), _statusColor(status))),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'SEMANA',
                  '${snapshot?.activeDays ?? 0}/${rule.requiredActiveDays} dias',
                  AppColors.neonBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'STRIKES',
                  '${snapshot?.demotionStrikes ?? 0}',
                  (snapshot?.demotionStrikes ?? 0) > 0 ? Colors.orangeAccent : Colors.white70,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'BOSS',
                  rule.requiresBossClear
                      ? ((snapshot?.bossCompleted ?? false) ? 'CLEAR' : 'PENDENTE')
                      : 'NAO EXIGIDO',
                  (snapshot?.bossCompleted ?? false) ? Colors.greenAccent : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            snapshot?.detail ??
                'O sistema vai mostrar aqui o risco de queda, os requisitos da semana e o estado competitivo do seu rank.',
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionExamCard(
    BuildContext context,
    WidgetRef ref,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
  ) {
    final accentColor = switch (exam?.status) {
      PromotionExamStatus.inProgress => Colors.orangeAccent,
      PromotionExamStatus.passed => Colors.greenAccent,
      PromotionExamStatus.failed => Colors.redAccent,
      PromotionExamStatus.promoted => AppColors.neonBlue,
      null => AppColors.neonBlue,
    };

    final title = switch (exam?.status) {
      PromotionExamStatus.inProgress => 'EXAME DE PROMOCAO EM CURSO',
      PromotionExamStatus.passed => 'EXAME CONCLUIDO',
      PromotionExamStatus.failed => 'EXAME FALHOU',
      PromotionExamStatus.promoted => 'PROMOCAO CONFIRMADA',
      null => 'EXAME DE PROMOCAO',
    };

    final description = switch (exam?.status) {
      PromotionExamStatus.inProgress =>
        'Conquiste ${exam!.targetActiveDays} dias ativos nesta semana antes de ${_formatShortDate(exam.expiresAt)}.',
      PromotionExamStatus.passed =>
        'Voce venceu a prova para o rank ${exam!.targetRank}. Agora confirme a promocao.',
      PromotionExamStatus.failed =>
        'O exame expirou ou voce nao sustentou a progressao exigida. Conquiste o estado de promocao para tentar de novo.',
      PromotionExamStatus.promoted =>
        'Sua ascensao foi registrada. Agora voce precisa sustentar o novo padrao.',
      null => snapshot?.promotionReady == true
          ? 'Voce destravou o exame para o rank ${snapshot!.promotionTargetRank}. Inicie a prova para validar a ascensao.'
          : 'Quando o sistema detectar promocao pronta, a prova formal vai aparecer aqui.',
    };

    final actionLabel = switch (exam?.status) {
      PromotionExamStatus.passed => 'PROMOVER RANK',
      PromotionExamStatus.inProgress => null,
      PromotionExamStatus.failed => null,
      PromotionExamStatus.promoted => null,
      null => snapshot?.promotionReady == true ? 'INICIAR EXAME' : null,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
          if (exam != null && exam.status == PromotionExamStatus.inProgress) ...[
            const SizedBox(height: 12),
            _metric('META DO EXAME', '${exam.targetActiveDays} dias', accentColor),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => _handlePromotionExamAction(context, ref, snapshot, exam),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankBossCard(
    Player player,
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
  ) {
    final boss = remoteWeeklyBoss.valueOrNull;
    if (boss == null && !remoteWeeklyBoss.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: const Text(
          'Nenhum boss de rank ativo no momento.',
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
      );
    }

    final localBoss = boss == null
        ? null
        : WeeklyBossDefinition(
            rank: boss.rank,
            title: boss.title,
            description: boss.description,
            targetActiveDays: boss.targetActiveDays,
            rewardXp: boss.rewardXp,
            rewardStatPoints: boss.rewardStatPoints,
          );
    final progress = localBoss?.progressFor(player) ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ARENA DO RANK',
            style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          if (boss == null)
            const Text(
              'Conectando ao Firestore...',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            )
          else ...[
            Text(
              boss.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              boss.description,
              style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'SEU PROGRESSO',
                    '$progress/${boss.targetActiveDays}',
                    AppColors.neonBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'RANKING',
                    '${boss.completedCount} clears',
                    Colors.amberAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'TOP CLEARS',
              style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            ..._buildTopCompletions(topCompletions),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCard(List<CompetitiveRankSnapshot> history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRILHA DE ASCENSAO',
            style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Text(
              'Seu historico de rank vai aparecer aqui conforme as semanas forem registradas.',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
            )
          else
            ...history.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neonBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
                      ),
                      child: Text(
                        entry.weekKey,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: AppColors.neonBlue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rank ${entry.currentRank} | ${_statusLabel(entry.status)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.activeDays}/${entry.requiredActiveDays} dias | strikes ${entry.demotionStrikes}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.summary,
                            style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugCard(
    BuildContext context,
    WidgetRef ref,
    Player player,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
    bool syncPaused,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEBUG DE PROGRESSAO',
            style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pausar sync automatica', style: TextStyle(fontSize: 13)),
            value: syncPaused,
            onChanged: (value) => ref.read(debugRankSyncPausedProvider.notifier).state = value,
            activeColor: Colors.orangeAccent,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: syncPaused ? () => _forcePromotionReady(context, ref, player) : null,
                child: const Text('FORCAR PROMOTION READY'),
              ),
              OutlinedButton(
                onPressed: syncPaused && exam != null ? () => _forceExamPassed(context, ref, player) : null,
                child: const Text('FORCAR EXAME PASS'),
              ),
              OutlinedButton(
                onPressed: syncPaused ? () => _clearPromotionState(context, ref) : null,
                child: const Text('LIMPAR EXAME'),
              ),
            ],
          ),
          if (snapshot != null) ...[
            const SizedBox(height: 12),
            Text(
              'Snapshot: rank ${snapshot.currentRank} | ${snapshot.status.name} | alvo ${snapshot.promotionTargetRank ?? '-'}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
          if (exam != null) ...[
            const SizedBox(height: 4),
            Text(
              'Exame: ${exam.status.name} | ${exam.sourceRank} -> ${exam.targetRank}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopCompletions(AsyncValue<List<WeeklyBossCompletion>> topCompletions) {
    return topCompletions.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const [
            Text(
              'Nenhum clear remoto registrado ainda.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ];
        }

        return List.generate(entries.length, (index) {
          final entry = entries[index];
          final position = index + 1;
          final timestamp = entry.completedAt;
          final timeLabel = timestamp == null
              ? 'sincronizando...'
              : '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#$position',
                    style: const TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          );
        });
      },
      loading: () => const [
        Text(
          'Carregando ranking remoto...',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
      error: (error, _) => [
        Text(
          'Falha ao carregar ranking: ${_shortError(error)}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
        ),
      ],
    );
  }

  Future<void> _handlePromotionExamAction(
    BuildContext context,
    WidgetRef ref,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
  ) async {
    if (snapshot == null) return;

    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (exam?.status == PromotionExamStatus.passed) {
      final promoted = await repository.promoteIfExamPassed(snapshot);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            promoted
                ? 'Promocao confirmada. O sistema registrou seu novo rank.'
                : 'A promocao nao pode ser concluida agora.',
          ),
        ),
      );
      return;
    }

    final started = await repository.startPromotionExam(snapshot);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          started
              ? 'Exame iniciado. Ganhe mais um dia ativo para concluir a promocao.'
              : 'Nao foi possivel iniciar o exame agora.',
        ),
      ),
    );
  }

  Future<void> _forcePromotionReady(BuildContext context, WidgetRef ref, Player player) async {
    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final ok = await repository.debugForcePromotionReady(player);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Snapshot forcado para promotionReady.' : 'Nao foi possivel forcar promotionReady.'),
      ),
    );
  }

  Future<void> _forceExamPassed(BuildContext context, WidgetRef ref, Player player) async {
    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final ok = await repository.debugForceExamPassed(player);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Exame marcado como aprovado para teste.' : 'Nao foi possivel forcar exame aprovado.'),
      ),
    );
  }

  Future<void> _clearPromotionState(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    await repository.debugClearPromotionState();
    messenger.showSnackBar(const SnackBar(content: Text('Estado de exame limpo para teste.')));
  }

  Color _statusColor(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => Colors.greenAccent,
      RankMaintenanceStatus.warning => Colors.orangeAccent,
      RankMaintenanceStatus.critical => Colors.redAccent,
      RankMaintenanceStatus.promotionReady => AppColors.neonBlue,
      RankMaintenanceStatus.demoted => Colors.redAccent,
    };
  }

  String _statusLabel(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => 'ESTAVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'RISCO',
      RankMaintenanceStatus.promotionReady => 'PROMOCAO',
      RankMaintenanceStatus.demoted => 'QUEDA',
    };
  }

  String _formatShortDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
  }

  String _shortError(Object? error) {
    if (error == null) return 'desconhecido';
    final text = error.toString().replaceAll('\n', ' ');
    return text.length > 48 ? '${text.substring(0, 48)}...' : text;
  }
}
