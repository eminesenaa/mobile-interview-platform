// ===================== File: lib/services/duel/fake_duel_matchmaking_service.dart =====================
// Purpose: Frontend development için sahte (fake) matchmaking servisi.
//          Backend henüz hazır olmadığı için match lifecycle simüle edilir.
// ================================================================================================

import 'dart:async';
import 'dart:math';

import '../../models/duel_config.dart';
import '../../models/duel_match.dart';
import '../../models/duel_player.dart';
import '../../models/duel_enums.dart';
import '../../models/question.dart';
import 'duel_matchmaking_service.dart';

class FakeDuelMatchmakingService implements DuelMatchmakingService {
  final StreamController<DuelMatch> _controller = StreamController.broadcast();

  DuelMatch? _currentMatch;
  bool _isCancelled = false;

  @override
  Stream<DuelMatch> startMatch(DuelConfig config) async* {
    _isCancelled = false;

    // 1️⃣ Searching state simülasyonu
    final searchingMatch = DuelMatch(
      matchId: 'fake_match_${DateTime.now().millisecondsSinceEpoch}',
      players: [],
      questions: [],
      status: DuelStatus.searching,
      createdAt: DateTime.now(),
    );

    _controller.add(searchingMatch);

    // Fake bekleme süresi
    await Future.delayed(const Duration(seconds: 2));

    if (_isCancelled) return;

    // 2️⃣ Oyuncu sayısını belirle
    final playerCount = _determinePlayerCount(config);

    final players = _generateFakePlayers(playerCount);

    // 3️⃣ Soruları üret
    final questions = _generateFakeQuestions(config.totalQuestions);

    _currentMatch = DuelMatch(
      matchId: searchingMatch.matchId,
      players: players,
      questions: questions,
      status: DuelStatus.matched,
      createdAt: searchingMatch.createdAt,
    );

    _controller.add(_currentMatch!);

    await Future.delayed(const Duration(seconds: 2));

    if (_isCancelled) return;

    // 4️⃣ Countdown
    _currentMatch = DuelMatch(
      matchId: _currentMatch!.matchId,
      players: players,
      questions: questions,
      status: DuelStatus.countdown,
      createdAt: _currentMatch!.createdAt,
    );

    _controller.add(_currentMatch!);

    await Future.delayed(const Duration(seconds: 3));

    if (_isCancelled) return;

    // 5️⃣ InProgress
    _currentMatch!.status = DuelStatus.inProgress;
    _currentMatch!.startedAt = DateTime.now();

    _controller.add(_currentMatch!);

    yield* _controller.stream;
  }

  @override
  Future<void> cancelMatch() async {
    _isCancelled = true;

    if (_currentMatch != null) {
      _currentMatch!.status = DuelStatus.cancelled;
      _controller.add(_currentMatch!);
    }
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  // ===================== PRIVATE HELPERS =====================

  int _determinePlayerCount(DuelConfig config) {
    if (config.duelType == DuelType.oneVsOne) {
      return 2;
    }

    // Multi için min 3 max 5
    final random = Random();
    return random.nextInt(3) + 3; // 3-5 arası
  }

  List<DuelPlayer> _generateFakePlayers(int count) {
    final players = <DuelPlayer>[];

    // Local user (frontend varsayımı)
    players.add(
      DuelPlayer(
        userId: 'local_user',
        username: 'You',
      ),
    );

    for (int i = 1; i < count; i++) {
      players.add(
        DuelPlayer(
          userId: 'bot_$i',
          username: 'Player $i',
        ),
      );
    }

    return players;
  }

  List<Question> _generateFakeQuestions(int count) {
    final questions = <Question>[];
    final random = Random();

    for (int i = 0; i < count; i++) {
      final correctIndex = random.nextInt(4);

      questions.add(
        Question(
          id: 'q_$i',
          title: 'Sample Question $i',
          description: 'What is the correct answer for question $i?',
          topic: 'General',

          // ✅ ENUM olarak veriyoruz
          difficulty: Difficulty.easy,
          status: Status.todo,

          tags: const ['duel', 'mock'],
          type: QuestionType.mcq,

          options: const ['A', 'B', 'C', 'D'],

          // correctAnswer modelde String?
          correctAnswer: correctIndex.toString(),
        ),
      );
    }

    return questions;
  }
}
