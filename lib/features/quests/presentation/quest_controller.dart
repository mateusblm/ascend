import 'dart:async';

import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/notifications/ritual_rota_service.dart';
import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final questSyncRepositoryProvider = Provider<QuestSyncRepository>(
  (ref) => QuestSyncRepository(sessionRepository: ActiveSessionRepository()),
);

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  final notifier = QuestNotifier(
    ref,
    ref.watch(isarProvider),
    ref.read(questSyncRepositoryProvider),
    ref.read(ritualRotaProvider),
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Cria a primeira missao pessoal conforme o foco escolhido no despertar.
List<Quest> starterQuestsForFocus(AwakeningPath foco) {
  final dados = switch (foco) {
    AwakeningPath.discipline => (
      'Arrumar a cama ao acordar',
      AttributeType.vitality,
    ),
    AwakeningPath.study => (
      'Organizar material de estudo',
      AttributeType.intelligence,
    ),
    AwakeningPath.training => (
      'Separar roupa e agua para o treino',
      AttributeType.vitality,
    ),
    AwakeningPath.health => (
      'Bater a meta de agua do dia',
      AttributeType.vitality,
    ),
    AwakeningPath.productivity => (
      'Definir a tarefa critica do dia',
      AttributeType.agility,
    ),
  };
  return [
    Quest(
      id: '${foco.name}-inicial',
      title: dados.$1,
      rewardAttribute: dados.$2,
      xpReward: personalQuestDefaultXp,
    ),
  ];
}

/// Retorna verdadeiro quando a data do ultimo reset nao e mais o dia atual.
bool isDailyResetDue({required DateTime lastReset, required DateTime now}) {
  return now.year != lastReset.year ||
      now.month != lastReset.month ||
      now.day != lastReset.day;
}

String questResultSnackBarMessage(Quest quest, QuestCompletionResult result) {
  return switch (result) {
    QuestCompletionResult.success =>
      quest.isCompleted
          ? 'Missao reaberta.'
          : 'MISSÃO CONCLUÍDA  ·  +${quest.xpReward} XP  ·  ${quest.rewardAttribute.name.toUpperCase()}${quest.journeyId == null ? '' : '  ·  ROTA ATUALIZADA'}',
    QuestCompletionResult.notFound => 'Missao nao encontrada.',
    QuestCompletionResult.alreadyCompleted => 'Esta missao ja foi concluida.',
    QuestCompletionResult.invalidFlow => 'Nao foi possivel atualizar a missao.',
  };
}

enum QuestCompletionResult { success, notFound, alreadyCompleted, invalidFlow }

/// Uma confirmação idempotente do backend é uma reconciliação válida, não erro.
bool isQuestMutationReconciled(QuestCompletionResult result) =>
    result == QuestCompletionResult.success ||
    result == QuestCompletionResult.alreadyCompleted;

/// Constrói o rascunho local de uma missão guiada a partir de fatos já
/// publicados pelo catálogo. O sincronismo posterior continua submetendo esse
/// inventário ao backend autoritativo.
Quest guidedQuestFromCatalog({
  required String id,
  required String title,
  required AttributeType rewardAttribute,
  required String categoryId,
  required String modalityId,
  required String activityId,
  required String executionType,
  required int schemaVersion,
  String? ownerUid,
  String? jornadaId,
  DateTime? plannedFor,
}) => Quest(
  ownerUid: ownerUid,
  id: id,
  title: title,
  journeyId: jornadaId,
  plannedFor: plannedFor,
  mode: QuestMode.guided,
  activityCategoryId: categoryId,
  activityModalityId: modalityId,
  activityId: activityId,
  executionType: executionType,
  activitySchemaVersion: schemaVersion,
  rewardAttribute: rewardAttribute,
  xpReward: personalQuestDefaultXp,
);

/// Reconstitui o inventário sem descartar uma escrita local ainda ausente no
/// backend. Para o mesmo id, o registro remoto continua canônico.
List<Quest> mergeQuestInventoriesForRestore({
  required List<Quest> remote,
  required List<Quest> local,
}) {
  final remoteIds = remote.map((quest) => quest.id).toSet();
  return [...remote, ...local.where((quest) => !remoteIds.contains(quest.id))];
}

/// Controla apenas quests pessoais. XP e atributos sao confirmados pelo backend Java.
class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier(this.ref, this._isar, this._repositorio, this._ritualRota)
    : super(const []) {
    _assinaturaAuth = FirebaseAuth.instance.authStateChanges().listen(
      _carregarUsuario,
    );
    _carregarUsuario(FirebaseAuth.instance.currentUser);
  }

  final Ref ref;
  final Isar _isar;
  final QuestSyncRepository _repositorio;
  final RitualRotaService _ritualRota;
  StreamSubscription<User?>? _assinaturaAuth;
  String? _uid;
  int _versaoCarregamento = 0;
  String? _ultimaFalhaMutacao;

  String? get ultimaFalhaMutacao => _ultimaFalhaMutacao;

  Future<void> _carregarUsuario(User? usuario) async {
    final versao = ++_versaoCarregamento;
    _uid = usuario?.uid;
    if (usuario == null) {
      state = const [];
      return;
    }
    final locais = _isar.quests
        .where()
        .findAllSync()
        .where((quest) => quest.ownerUid == usuario.uid)
        .toList();
    state = locais;
    try {
      final remotas = await _repositorio.watchQuests(usuario.uid).first;
      if (versao != _versaoCarregamento || _uid != usuario.uid) return;
      final locaisAtuais = state
          .where((quest) => quest.ownerUid == usuario.uid)
          .toList(growable: false);
      final restauradas = mergeQuestInventoriesForRestore(
        remote: remotas,
        local: locaisAtuais,
      );
      _substituir(restauradas, sincronizar: false);
      if (restauradas.length > remotas.length) {
        unawaited(_sincronizarInventario(usuario.uid, restauradas));
      }
    } catch (_) {
      // O cache local preserva o fluxo quando a rede estiver indisponivel.
    }
  }

  void applyStarterKit(AwakeningPath foco) {
    if (state.isNotEmpty) return;
    final quests = starterQuestsForFocus(
      foco,
    ).map((quest) => quest.copyWith(ownerUid: _uid)).toList();
    _substituir(quests);
  }

  void addPersonalQuest(
    String titulo,
    AttributeType atributo,
    int xp, {
    String? jornadaId,
    DateTime? plannedFor,
  }) {
    final quest = Quest(
      ownerUid: _uid,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: titulo,
      journeyId: jornadaId,
      plannedFor: plannedFor,
      rewardAttribute: atributo,
      xpReward: normalizePersonalQuestXp(xp),
    );
    _substituir([...state, quest]);
  }

  void addGuidedQuest({
    required String title,
    required AttributeType rewardAttribute,
    required String categoryId,
    required String modalityId,
    required String activityId,
    required String executionType,
    required int schemaVersion,
    String? jornadaId,
    DateTime? plannedFor,
  }) {
    final quest = guidedQuestFromCatalog(
      ownerUid: _uid,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      jornadaId: jornadaId,
      plannedFor: plannedFor,
      categoryId: categoryId,
      modalityId: modalityId,
      activityId: activityId,
      executionType: executionType,
      schemaVersion: schemaVersion,
      // A compatibilidade legada requer um atributo único. Ele é derivado do
      // catálogo autoritativo e nunca é escolhido no formulário guiado.
      rewardAttribute: rewardAttribute,
    );
    _substituir([...state, quest]);
  }

  Future<GuidedExecutionResult> registerGuidedExecution({
    required Quest quest,
    required Map<String, Object?> metrics,
    String? observation,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Sessão do usuário indisponível.');
    // A criação local é otimista. Antes de concluir, aguarda o inventário
    // autoritativo para que o backend localize a Quest desta execução.
    await _repositorio.replaceQuests(uid: uid, quests: state);
    final response = await _repositorio.registerActivityExecution(
      quest: quest,
      executionId: '${quest.id}-${DateTime.now().microsecondsSinceEpoch}',
      metrics: metrics,
      observation: observation,
    );
    final completion = Map<String, dynamic>.from(
      (response['completion'] as Map).cast<Object?, Object?>(),
    );
    final result = PersonalQuestMutationResult(
      status: PersonalQuestMutationStatus.completed,
      player: parsePlayerProfileData(
        Map<String, dynamic>.from(
          (completion['profile'] as Map).cast<Object?, Object?>(),
        ),
        uid: uid,
        fallbackName: ref.read(playerProvider).name,
      ),
      quest: parseQuestSyncData(
        Map<String, dynamic>.from(
          (completion['quest'] as Map).cast<Object?, Object?>(),
        ),
        uid: uid,
        questId: quest.id,
      ),
    );
    state = state
        .map((item) => item.id == quest.id ? result.quest : item)
        .toList();
    _persistirLocal();
    ref.read(playerProvider.notifier).applyAuthoritativeProfile(result.player);
    final calculated = response['calculatedMetrics'];
    return GuidedExecutionResult(
      completion: result,
      calculatedMetrics: calculated is Map
          ? Map<String, dynamic>.from(calculated.cast<Object?, Object?>())
          : const {},
    );
  }

  void deleteQuest(String id) =>
      _substituir(state.where((quest) => quest.id != id).toList());

  Future<QuestCompletionResult> toggleQuest(
    String id, {
    void Function(int level)? onLevelUp,
  }) async {
    Quest? quest;
    for (final item in state) {
      if (item.id == id) {
        quest = item;
        break;
      }
    }
    final uid = _uid;
    _ultimaFalhaMutacao = null;
    if (quest == null) return QuestCompletionResult.notFound;
    if (uid == null) {
      _ultimaFalhaMutacao = 'Sessão do usuário indisponível. Entre novamente.';
      return QuestCompletionResult.invalidFlow;
    }
    try {
      final resultado = quest.isCompleted
          ? await _repositorio.revokePersonalQuestCompletion(
              uid: uid,
              fallbackName: ref.read(playerProvider).name,
              quest: quest,
            )
          : await _repositorio.completePersonalQuest(
              uid: uid,
              fallbackName: ref.read(playerProvider).name,
              quest: quest,
            );
      state = state
          .map((item) => item.id == id ? resultado.quest : item)
          .toList();
      _persistirLocal();
      ref
          .read(playerProvider.notifier)
          .applyAuthoritativeProfile(resultado.player, onLevelUp: onLevelUp);
      return resultado.status == PersonalQuestMutationStatus.alreadyCompleted
          ? QuestCompletionResult.alreadyCompleted
          : QuestCompletionResult.success;
    } on ActiveSessionConflictException {
      _ultimaFalhaMutacao =
          'A sessão ativa mudou. Atualize a conta e tente novamente.';
      return QuestCompletionResult.invalidFlow;
    } catch (error) {
      _ultimaFalhaMutacao = error.toString().replaceFirst('Exception: ', '');
      // A recompensa permanece autoritativa: em falha remota, nada é alterado localmente.
      return QuestCompletionResult.invalidFlow;
    }
  }

  Future<bool> addRecurringQuest(
    String titulo,
    AttributeType atributo,
    List<int> diasSemana, {
    String? jornadaId,
  }) async {
    if (_uid == null || diasSemana.isEmpty) return false;
    try {
      await _repositorio.createRecurringQuest(
        title: titulo,
        attribute: atributo,
        weekdays: diasSemana,
        journeyId: jornadaId,
      );
      final remotas = await _repositorio.watchQuests(_uid!).first;
      _substituir(remotas, sincronizar: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pausarRotina(String recurrenceId) async {
    try {
      await _repositorio.pauseRecurringQuest(recurrenceId);
      final remotas = await _repositorio.watchQuests(_uid!).first;
      _substituir(remotas, sincronizar: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> arquivarQuest(String id) async {
    final quest = state.where((item) => item.id == id).firstOrNull;
    if (quest == null || _uid == null || quest.isCompleted) return false;
    try {
      final atualizada = await _repositorio.archivePersonalQuest(
        uid: _uid!,
        quest: quest,
      );
      state = state.map((item) => item.id == id ? atualizada : item).toList();
      _persistirLocal();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reagendarQuest(String id, DateTime quando) async {
    final quest = state.where((item) => item.id == id).firstOrNull;
    if (quest == null ||
        _uid == null ||
        quest.isCompleted ||
        quest.isArchived) {
      return false;
    }
    try {
      final atualizada = await _repositorio.reschedulePersonalQuest(
        uid: _uid!,
        quest: quest,
        plannedFor: quando,
      );
      state = state.map((item) => item.id == id ? atualizada : item).toList();
      _persistirLocal();
      return true;
    } catch (_) {
      return false;
    }
  }

  void ensureDailyReset() {}

  void _substituir(List<Quest> quests, {bool sincronizar = true}) {
    state = quests.map((quest) => quest.copyWith(ownerUid: _uid)).toList();
    _persistirLocal();
    unawaited(_ritualRota.sync(state));
    if (sincronizar && _uid != null) {
      unawaited(_sincronizarInventario(_uid!, state));
    }
  }

  Future<void> _sincronizarInventario(String uid, List<Quest> quests) async {
    try {
      await _repositorio.replaceQuests(uid: uid, quests: quests);
    } catch (_) {
      // O inventário em Isar permanece como fonte de restauração até a próxima
      // sincronização bem-sucedida.
    }
  }

  void _persistirLocal() => _isar.writeTxnSync(() {
    _isar.quests.putAllSync(state);
  });

  @override
  void dispose() {
    _assinaturaAuth?.cancel();
    super.dispose();
  }
}

class GuidedExecutionResult {
  const GuidedExecutionResult({
    required this.completion,
    required this.calculatedMetrics,
  });

  final PersonalQuestMutationResult completion;
  final Map<String, dynamic> calculatedMetrics;
}
