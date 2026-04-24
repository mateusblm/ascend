import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/main_navigation_screen.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/quests_screen.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets('onboarding confirms starter kit and hands off to first quest', (
    tester,
  ) async {
    _setLargeSurface(tester);
    final isar = _MemoryIsar();

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => _FakeAuthController()),
        playerProvider.overrideWith(
          (ref) => PlayerNotifier(
            isar,
            Player.initial(name: 'TESTER', now: DateTime(2026, 4, 24)),
            enableLocalPersistence: false,
          ),
        ),
        questProvider.overrideWith((ref) => QuestNotifier(ref, isar)),
        questLiveNowProvider.overrideWith(
          (ref) => Stream.value(DateTime(2026, 4, 24)),
        ),
        remoteWeeklyBossProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MainNavigationScreen()),
      ),
    );
    await _pumpFrame(tester);

    expect(container.read(questProvider), isEmpty);
    expect(container.read(playerProvider).hasCompletedOnboarding, isFalse);
    expect(
      find.byKey(const ValueKey('onboarding-focus-section')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('onboarding-focus-health')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('onboarding-focus-health')));
    await _pumpFrame(tester);

    await _dragUntilVisible(
      tester,
      find.byKey(const ValueKey('onboarding-starter-quest-health-personal')),
    );
    expect(
      find.byKey(const ValueKey('onboarding-starter-quest-health-personal')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('onboarding-primary-cta')));
    await _pumpFrame(tester);

    expect(container.read(navigationProvider), 1);
    expect(container.read(playerProvider).hasCompletedOnboarding, isTrue);
    expect(container.read(playerProvider).primaryFocus, AwakeningPath.health);
    expect(find.byKey(const ValueKey('quests-screen')), findsOneWidget);

    final starterKit = container.read(questProvider);
    expect(starterKit, hasLength(3));
    expect(starterKit.where((quest) => !quest.isCompetitive), hasLength(1));
    expect(
      starterKit.any(
        (quest) => quest.id == 'health-personal' && !quest.isCompleted,
      ),
      isTrue,
    );

    final personalPrimaryAction = find.byKey(
      const ValueKey('quest-card-primary-health-personal'),
    );
    await tester.scrollUntilVisible(
      personalPrimaryAction,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(personalPrimaryAction, findsOneWidget);
    expect(
      tester.widget<FilledButton>(personalPrimaryAction).onPressed,
      isNotNull,
    );

    await tester.tap(personalPrimaryAction);
    await _pumpFrame(tester);

    final completedQuest = container
        .read(questProvider)
        .singleWhere((quest) => quest.id == 'health-personal');
    expect(completedQuest.isCompleted, isTrue);
    expect(completedQuest.verificationStatus, QuestVerificationStatus.verified);
    expect(container.read(playerProvider).xp, personalQuestDefaultXp);
  });
}

Future<void> _dragUntilVisible(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await _pumpFrame(tester);
  }
}

Future<void> _pumpFrame(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 350));
}

void _setLargeSurface(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1080, 2200);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController() : super(AuthInitial());

  @override
  Future<void> handleActiveSessionConflict() async {}

  @override
  Future<void> refreshActiveSession() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class _MemoryIsar extends Isar {
  _MemoryIsar() : super('memory_${DateTime.now().microsecondsSinceEpoch}') {
    attachCollections({
      Player: _MemoryCollection<Player>(this, PlayerSchema),
      Quest: _MemoryCollection<Quest>(this, QuestSchema),
    });
  }

  @override
  String? get directory => null;

  @override
  T txnSync<T>(T Function() callback) => callback();

  @override
  Future<T> txn<T>(Future<T> Function() callback) => callback();

  @override
  T writeTxnSync<T>(T Function() callback, {bool silent = false}) => callback();

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) =>
      callback();

  @override
  Future<void> copyToFile(String targetPath) async {}

  @override
  Future<int> getSize({
    bool includeIndexes = false,
    bool includeLinks = false,
  }) async => 0;

  @override
  int getSizeSync({bool includeIndexes = false, bool includeLinks = false}) =>
      0;

  @override
  Future<void> verify() async {}
}

class _MemoryCollection<OBJ> extends IsarCollection<OBJ> {
  _MemoryCollection(this.isar, this.schema);

  final List<OBJ> _items = [];
  var _nextId = 1;

  @override
  final Isar isar;

  @override
  final CollectionSchema<OBJ> schema;

  @override
  List<OBJ?> getAllSync(List<Id> ids) {
    return ids
        .map(
          (id) => _items.cast<dynamic>().cast<OBJ?>().firstWhere(
            (item) => _isarIdOf(item) == id,
            orElse: () => null,
          ),
        )
        .toList();
  }

  @override
  Future<List<OBJ?>> getAll(List<Id> ids) async => getAllSync(ids);

  @override
  List<Id> putAllSync(List<OBJ> objects, {bool saveLinks = true}) {
    final ids = <Id>[];
    for (final object in objects) {
      final id = _ensureId(object);
      ids.add(id);
      final existingIndex = _items.indexWhere((item) => _isarIdOf(item) == id);
      if (existingIndex == -1) {
        _items.add(object);
      } else {
        _items[existingIndex] = object;
      }
    }
    return ids;
  }

  @override
  Future<List<Id>> putAll(List<OBJ> objects) async => putAllSync(objects);

  @override
  int deleteAllSync(List<Id> ids) {
    final before = _items.length;
    _items.removeWhere((item) => ids.contains(_isarIdOf(item)));
    return before - _items.length;
  }

  @override
  Future<int> deleteAll(List<Id> ids) async => deleteAllSync(ids);

  @override
  void clearSync() {
    _items.clear();
  }

  @override
  Future<void> clear() async => clearSync();

  @override
  Query<R> buildQuery<R>({
    List<WhereClause> whereClauses = const [],
    bool whereDistinct = false,
    Sort whereSort = Sort.asc,
    FilterOperation? filter,
    List<SortProperty> sortBy = const [],
    List<DistinctProperty> distinctBy = const [],
    int? offset,
    int? limit,
    String? property,
  }) {
    return _MemoryQuery<R>(isar, _items.cast<R>());
  }

  @override
  int countSync() => _items.length;

  @override
  Future<int> count() async => countSync();

  Id _ensureId(Object? object) {
    final current = _isarIdOf(object);
    if (current != Isar.autoIncrement) return current;
    final next = _nextId++;
    if (object is Quest) {
      object.isarId = next;
    } else if (object is Player) {
      object.id = next;
    }
    return next;
  }

  Id _isarIdOf(Object? object) {
    if (object is Quest) return object.isarId;
    if (object is Player) return object.id;
    return Isar.autoIncrement;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryQuery<R> extends Query<R> {
  _MemoryQuery(this.isar, this._items);

  @override
  final Isar isar;

  final List<R> _items;

  @override
  List<R> findAllSync() => List<R>.of(_items);

  @override
  Future<List<R>> findAll() async => findAllSync();

  @override
  R? findFirstSync() => _items.isEmpty ? null : _items.first;

  @override
  Future<R?> findFirst() async => findFirstSync();

  @override
  T? aggregateSync<T>(AggregationOp op) {
    if (op == AggregationOp.count) return _items.length as T;
    if (op == AggregationOp.isEmpty) return (_items.isEmpty ? 1 : 0) as T;
    return null;
  }

  @override
  Future<T?> aggregate<T>(AggregationOp op) async => aggregateSync<T>(op);

  @override
  bool deleteFirstSync() {
    if (_items.isEmpty) return false;
    _items.removeAt(0);
    return true;
  }

  @override
  Future<bool> deleteFirst() async => deleteFirstSync();

  @override
  int deleteAllSync() {
    final count = _items.length;
    _items.clear();
    return count;
  }

  @override
  Future<int> deleteAll() async => deleteAllSync();

  @override
  Stream<List<R>> watch({bool fireImmediately = false}) =>
      Stream.value(findAllSync());

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) =>
      const Stream<void>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
