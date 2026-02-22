// ===================== File: lib/services/duel/fake_duel_matchmaking_service.dart =====================
// Purpose:
// ----------------------------------------------------------------------------
// Frontend geliştirme sırasında gerçek backend olmadan matchmaking lifecycle'ını
// simüle eder.
//
// ⚠️ GERÇEK BACKEND MANTIĞI NASIL OLUR?
// - Client startMatch çağırır.
// - Backend bir match oluşturur ve local user'ı ekler.
// - Diğer oyuncular bağlandıkça backend match state'ini publish eder.
// - Status sırasıyla: searching → matched → countdown → inProgress olur.
// - Client sürekli stream üzerinden state dinler.
//
// Bu fake servis aynı lifecycle'ı simüle eder.
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
  final StreamController<DuelMatch> _controller =
      StreamController<DuelMatch>.broadcast();

  DuelMatch? _currentMatch;
  bool _isCancelled = false;

  // ===============================================================================================
  // START MATCH
  // ===============================================================================================
  @override
  Stream<DuelMatch> startMatch(DuelConfig config) {
    _simulateMatch(config);
    return _controller.stream;
  }

  Future<void> _simulateMatch(DuelConfig config) async {
    _isCancelled = false;

    // ----------------------------------------------------------------------------
    // 1️⃣ MATCH OLUŞTURULUR (Searching başlar)
    // ----------------------------------------------------------------------------
    // Gerçek backend'de:
    // - Match DB'de oluşturulur
    // - Local user match'e eklenir
    // - Status = searching olur
    // ----------------------------------------------------------------------------

    final matchId = 'fake_match_${DateTime.now().millisecondsSinceEpoch}';

    final localPlayer = DuelPlayer(
      userId: 'local_user',
      username: 'You',
    );

    _currentMatch = DuelMatch(
      matchId: matchId,
      players: [localPlayer],
      questions: [],
      status: DuelStatus.searching,
      createdAt: DateTime.now(),
    );

    _controller.add(_currentMatch!);

    // ----------------------------------------------------------------------------
    // 2️⃣ OYUNCU SAYISI BELİRLENİR
    // ----------------------------------------------------------------------------
    final totalPlayers = _determinePlayerCount(config);

    // ----------------------------------------------------------------------------
    // 3️⃣ BOTLAR SIRAYLA EKLENİR (Gerçekçi simülasyon)
    // ----------------------------------------------------------------------------
    // Gerçek backend'de:
    // - Yeni oyuncu bağlandığında match state güncellenir.
    // - Client'a yeni state push edilir.
    // ----------------------------------------------------------------------------

    for (int i = 1; i < totalPlayers; i++) {
      if (_isCancelled) return;

      await Future.delayed(
        Duration(milliseconds: 800 + Random().nextInt(1200)),
      );

      final bot = DuelPlayer(
        userId: 'bot_$i',
        username: 'Player $i',
      );

      _currentMatch!.players.add(bot);
      _controller.add(_currentMatch!);
    }

    if (_isCancelled) return;

    // ----------------------------------------------------------------------------
    // 4️⃣ MATCHED STATE
    // ----------------------------------------------------------------------------
    // Gerçek backend'de:
    // - Oyuncu sayısı yeterli olunca status = matched olur
    // - Sorular generate edilir
    // ----------------------------------------------------------------------------

    final questions = _generateFakeQuestions(config.totalQuestions);

    _currentMatch = DuelMatch(
      matchId: _currentMatch!.matchId,
      players: _currentMatch!.players,
      questions: questions,
      status: DuelStatus.matched,
      createdAt: _currentMatch!.createdAt,
    );

    _controller.add(_currentMatch!);

    await Future.delayed(const Duration(seconds: 2));

    if (_isCancelled) return;

    // ----------------------------------------------------------------------------
    // 5️⃣ COUNTDOWN
    // ----------------------------------------------------------------------------
    // Gerçek backend'de:
    // - Tüm oyuncular hazır
    // - Geri sayım başlar
    // ----------------------------------------------------------------------------

    _currentMatch!.status = DuelStatus.countdown;
    _controller.add(_currentMatch!);

    await Future.delayed(const Duration(seconds: 3));

    if (_isCancelled) return;

    // ----------------------------------------------------------------------------
    // 6️⃣ IN PROGRESS
    // ----------------------------------------------------------------------------
    // Gerçek backend'de:
    // - Match başlar
    // - startedAt set edilir
    // ----------------------------------------------------------------------------

    _currentMatch!.status = DuelStatus.inProgress;
    _currentMatch!.startedAt = DateTime.now();

    _controller.add(_currentMatch!);
  }

  // ===============================================================================================
  // CANCEL MATCH
  // ===============================================================================================
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

  // ===============================================================================================
  // PRIVATE HELPERS
  // ===============================================================================================

  int _determinePlayerCount(DuelConfig config) {
    if (config.duelType == DuelType.oneVsOne) {
      return 2;
    }

    return Random().nextInt(3) + 3;
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
          difficulty: Difficulty.easy,
          status: Status.todo,
          tags: const ['duel', 'mock'],
          type: QuestionType.mcq,
          options: const ['A', 'B', 'C', 'D'],
          correctAnswer: correctIndex.toString(),
        ),
      );
    }

    return questions;
  }
}
