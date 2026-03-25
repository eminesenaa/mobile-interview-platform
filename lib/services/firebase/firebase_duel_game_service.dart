// ===================== File: lib/services/firebase/firebase_duel_game_service.dart =====================
// Purpose: Gerçek zamanlı düello oyun servisi (1v1 ve multi).
//          Firestore üzerinden answer/submit, round ilerletme, disconnect yönetimi.
//          Matchmaking değil — oyun başladıktan sonraki lifecycle'ı yönetir.
// ================================================================================================

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/duel_match.dart';
import '../../models/duel_player.dart';
import '../../models/duel_enums.dart';
import '../../models/question.dart';

class FirebaseDuelGameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot>? _matchSubscription;

  // ─────────────────────────────────────────
  // MATCH LISTENER — tek kaynak, onSnapshot
  // ─────────────────────────────────────────

  /// Firestore `matches/{matchId}` dokümanına real-time listener bağlar.
  /// Her güncelleme `DuelMatch` olarak stream'e eklenir.
  Stream<DuelMatch> listenToMatch(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .where((snap) => snap.exists)
        .map((snap) => _mapFirestoreToMatch(matchId, snap.data()!));
  }

  // ─────────────────────────────────────────
  // SUBMIT ANSWER — sadece currentRoundAnswers'a yaz
  // ─────────────────────────────────────────

  /// Oyuncunun cevabını `currentRoundAnswers/{userId}` altına yazar.
  /// Skor artışı burada YAPILMAZ — reveal sonrası `applyRoundScores` ile yapılır.
  /// Böylece progress bar sadece reveal'dan sonra ilerler.
  Future<void> submitAnswer({
    required String matchId,
    required String userId,
    required int selectedOptionIndex,
    required int answerTimeSeconds,
    required bool isCorrect,
    required int scoreGained,
    required int xpGained,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    // Sadece cevap verisini yaz — skor/xp bilgisi de sakla (reveal sonrası uygulanacak)
    await matchRef.update({
      'currentRoundAnswers.$userId': {
        'selectedOptionIndex': selectedOptionIndex,
        'answerTimeSeconds': answerTimeSeconds,
        'isCorrect': isCorrect,
        'scoreGained': scoreGained,
        'xpGained': xpGained,
      },
    });
  }

  // ─────────────────────────────────────────
  // CHECK & ADVANCE ROUND
  // ─────────────────────────────────────────

  /// Her iki oyuncu cevap verdi mi kontrol eder.
  /// Verdiyse → reveal fazına geçirir.
  Future<void> checkAndReveal({
    required String matchId,
    required int expectedPlayerCount,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    final snapshot = await matchRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final answers = data['currentRoundAnswers'] as Map<String, dynamic>? ?? {};

    if (answers.length >= expectedPlayerCount) {
      // Tüm oyuncular cevap verdi → reveal
      await matchRef.update({'questionPhase': 'reveal'});
    }
  }

  /// Reveal bittikten sonra skorları uygula ve bir sonraki soruya ilerlet.
  /// Son soruysa match'i sonlandırır.
  Future<void> advanceToNextQuestion({
    required String matchId,
    required int currentIndex,
    required int totalQuestions,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    // 🔥 Önce bu rounddaki skorları uygula (reveal sonrası)
    await _applyRoundScores(matchRef);

    if (currentIndex >= totalQuestions - 1) {
      // Son soru — match bitti
      await matchRef.update({
        'status': 'finished',
        'questionPhase': 'reveal',
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Sonraki soru
      await matchRef.update({
        'currentQuestionIndex': currentIndex + 1,
        'questionPhase': 'active',
        'currentRoundAnswers': {}, // Temizle
      });
    }
  }

  /// currentRoundAnswers içindeki skor verilerini playerScores/playerCorrectCounts/playerXp'ye uygular.
  /// Bu sayede progress bar sadece reveal fazından SONRA ilerler.
  ///
  /// ⚠️ Transaction kullanılıyor çünkü her iki oyuncu da advanceToNextQuestion
  /// çağırıyor. Transaction olmadan ikisi de aynı currentRoundAnswers'ı okuyup
  /// aynı increment'leri uyguluyor → skorlar/correctCount 2× oluyor.
  /// Transaction ile ilk commit eden cevapları temizler, ikinci çağrı boş
  /// cevap görüp atlar.
  Future<void> _applyRoundScores(DocumentReference matchRef) async {
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final answers =
          data['currentRoundAnswers'] as Map<String, dynamic>? ?? {};

      // Zaten başka client tarafından işlendi — atla
      if (answers.isEmpty) return;

      final Map<String, dynamic> scoreUpdates = {
        // Cevapları atomik olarak temizle — ikinci çağrı boş görüp atlayacak
        'currentRoundAnswers': {},
      };

      for (final entry in answers.entries) {
        final userId = entry.key;
        final answer = entry.value as Map<String, dynamic>? ?? {};

        final scoreGained = answer['scoreGained'] as int? ?? 0;
        final xpGained = answer['xpGained'] as int? ?? 0;
        final isCorrect = answer['isCorrect'] as bool? ?? false;

        if (scoreGained > 0) {
          scoreUpdates['playerScores.$userId'] =
              FieldValue.increment(scoreGained);
        }
        if (isCorrect) {
          scoreUpdates['playerCorrectCounts.$userId'] =
              FieldValue.increment(1);
        }
        if (xpGained > 0) {
          scoreUpdates['playerXp.$userId'] = FieldValue.increment(xpGained);
        }
      }

      transaction.update(matchRef, scoreUpdates);
    });
  }

  // ─────────────────────────────────────────
  // DISCONNECT HANDLING
  // ─────────────────────────────────────────

  /// Oyuncu koptuğunda match'i iptal eder.
  Future<void> handleDisconnect(String matchId) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ [GAME SERVICE] Disconnect error: $e');
    }
  }

  // ─────────────────────────────────────────
  // FIRESTORE → MODEL MAPPING
  // ─────────────────────────────────────────

  DuelMatch _mapFirestoreToMatch(String matchId, Map<String, dynamic> data) {
    // Player'ları parse et
    final playersRaw = data['players'] as List? ?? [];
    final playerScores = data['playerScores'] as Map<String, dynamic>? ?? {};
    final playerCorrectCounts =
        data['playerCorrectCounts'] as Map<String, dynamic>? ?? {};
    final playerXp = data['playerXp'] as Map<String, dynamic>? ?? {};

    final players = playersRaw.map((p) {
      final uid = p['userId'] ?? '';
      return DuelPlayer(
        userId: uid,
        username: p['username'] ?? p['displayName'] ?? 'Player',
        avatarUrl: p['avatarUrl'] ?? p['photoUrl'] ?? p['photoURL'],
        score: playerScores[uid] as int? ?? p['score'] ?? 0,
        correctCount:
            playerCorrectCounts[uid] as int? ?? p['correctCount'] ?? 0,
        totalXpGained: playerXp[uid] as int? ?? p['totalXpGained'] ?? 0,
        comboCount: p['comboCount'] ?? 0,
      );
    }).toList();

    // currentRoundAnswers → player'lara bind et
    final roundAnswers =
        data['currentRoundAnswers'] as Map<String, dynamic>? ?? {};
    for (final player in players) {
      final answer = roundAnswers[player.userId] as Map<String, dynamic>?;
      if (answer != null) {
        player.answeredCurrentQuestion = true;
        player.selectedOptionIndex = answer['selectedOptionIndex'] as int?;
        player.answerTimeSeconds = answer['answerTimeSeconds'] as int?;
      }
    }

    // Soruları parse et — sert MCQ filtresi
    final questions = (data['questions'] as List? ?? []).map((q) {
      final qMap = q as Map<String, dynamic>;
      return Question.fromFirestore(qMap, qMap['id'] ?? '').copyWith(
        description:
            (qMap['text'] ?? qMap['description'] ?? '').toString().trim(),
        options: qMap['options'] != null
            ? List<String>.from(
                (qMap['options'] as List).map((o) => o.toString().trim()))
            : [],
        correctAnswer: qMap['correctAnswer']?.toString().trim(),
        type: QuestionType.mcq,
      );
    }).where((q) {
      return q.options != null &&
          q.options!.length >= 2 &&
          q.correctAnswer != null &&
          q.correctAnswer!.isNotEmpty;
    }).toList();

    // Parse duelType
    final duelTypeStr = data['duelType'] as String? ?? 'oneVsOne';
    final duelType = DuelType.values.firstWhere(
      (e) => e.name == duelTypeStr,
      orElse: () => DuelType.oneVsOne,
    );

    // Parse lobbyCountdownEndAt
    final lobbyTimestamp = data['lobbyCountdownEndAt'] as Timestamp?;
    final lobbyCountdownEndAt = lobbyTimestamp?.toDate();

    return DuelMatch(
      matchId: matchId,
      players: players,
      questions: questions,
      currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
      duelType: duelType,
      category: data['category'],
      lobbyCountdownEndAt: lobbyCountdownEndAt,
      isPrivate: data['isPrivate'] ?? false,
      password: data['password'],
      status: DuelStatus.values.firstWhere(
          (e) => e.name == (data['status'] ?? 'idle'),
          orElse: () => DuelStatus.idle),
      questionPhase: DuelQuestionPhase.values.firstWhere(
          (e) => e.name == (data['questionPhase'] ?? 'active'),
          orElse: () => DuelQuestionPhase.active),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ─────────────────────────────────────────
  // PRIVATE ROOM METHODS
  // ─────────────────────────────────────────

  /// Firestore'dan kullanıcı profil bilgilerini (username + avatar) çeker.
  /// Fallback zinciri: Firestore username → displayName param → email prefix
  Future<Map<String, String?>> _getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    final username = (data?['username'] as String?)?.trim();
    final avatar = data?['photoUrl'] as String? ??
        data?['duelAvatar'] as String? ??
        data?['photoURL'] as String?;

    return {'username': username, 'avatar': avatar};
  }

  /// Creates a private room, generates questions, returns the matchId and 6-digit password.
  Future<Map<String, String>> createPrivateRoom({
    required String category,
    required String userId,
    required String username,
    required String? avatarUrl,
  }) async {
    // 1. Generate 6-digit random alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final password = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join('');

    // 2. Fetch questions
    final questions = await _fetchQuestionsForPrivateRoom(category);

    // 3. Firestore'dan gerçek profili çek
    final profile = await _getUserProfile(userId);
    final resolvedUsername = (profile['username']?.isNotEmpty == true)
        ? profile['username']!
        : username;
    final resolvedAvatar = profile['avatar'] ?? avatarUrl;

    final questionsData = questions.map((q) {
      return {
        'id': q.id,
        'title': q.title.trim(),
        'text': q.description?.trim() ?? '',
        'topic': q.topic,
        'type': 'MCQ',
        'options': (q.options ?? []).map((opt) => opt.toString().trim()).toList(),
        'correctAnswer': q.correctAnswer?.toString().trim(),
        'difficulty': q.difficulty.name,
      };
    }).toList();

    final matchRef = _firestore.collection('matches').doc();
    final matchId = matchRef.id;

    await matchRef.set({
      'matchId': matchId,
      'isPrivate': true,
      'password': password,
      'players': [
        {
          'userId': userId,
          'username': resolvedUsername,
          'avatarUrl': resolvedAvatar,
          'score': 0,
          'correctCount': 0,
          'totalXpGained': 0,
        }
      ],
      'questions': questionsData,
      'currentQuestionIndex': 0,
      'status': 'waiting',
      'questionPhase': 'active',
      'duelType': DuelType.privateRoom.name,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return {'matchId': matchId, 'password': password};
  }

  /// Joins a private room. Returns the matchId if successful, or throws an exception.
  Future<String> joinPrivateRoom({
    required String password,
    required String userId,
    required String username,
    required String? avatarUrl,
  }) async {
    final query = await _firestore
        .collection('matches')
        .where('isPrivate', isEqualTo: true)
        .where('password', isEqualTo: password)
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Oda bulunamadı veya oyun çoktan başladı.');
    }

    final doc = query.docs.first;
    final matchId = doc.id;
    final data = doc.data();

    final players = data['players'] as List? ?? [];

    if (players.length >= 5) {
      throw Exception('Oda şu an dolu (Maksimum 5 kişi).');
    }

    // Oyuncu zaten odada mı?
    final alreadyJoined = players.any((p) => p['userId'] == userId);
    if (!alreadyJoined) {
      // Firestore'dan gerçek profili çek
      final profile = await _getUserProfile(userId);
      final resolvedUsername = (profile['username']?.isNotEmpty == true)
          ? profile['username']!
          : username;
      final resolvedAvatar = profile['avatar'] ?? avatarUrl;

      await doc.reference.update({
        'players': FieldValue.arrayUnion([
          {
            'userId': userId,
            'username': resolvedUsername,
            'avatarUrl': resolvedAvatar,
            'score': 0,
            'correctCount': 0,
            'totalXpGained': 0,
          }
        ]),
      });
    }

    return matchId;
  }

  /// Starts the private room game state (changes status to inProgress).
  Future<void> startPrivateRoom(String matchId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    await matchRef.update({
      'status': 'inProgress',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Question>> _fetchQuestionsForPrivateRoom(String category) async {
    // Matchmaking logic den copy-paste
    Query query = _firestore.collection('questions').where('type', isEqualTo: 'MCQ');

    if (category != 'Mixed') {
      List<String> topics = [];
      switch (category) {
        case 'Programming':
          topics = ['C / C++', 'Java', 'Python'];
          break;
        case 'Algorithms':
          topics = ['Algorithms', 'Data Structures'];
          break;
        case 'Data & AI':
          topics = ['Data Science', 'Machine Learning'];
          break;
        case 'Databases':
          topics = ['SQL'];
          break;
        case 'Systems':
          topics = ['Network', 'Git'];
          break;
        case 'Soft Skills':
          topics = ['Soft Skills'];
          break;
        case 'Programming Languages': // Diğer eşleşmeler için fallback
          topics = ['C / C++', 'Java', 'Python'];
          break;
        case 'Algorithms & Data Structures':
          topics = ['Algorithms', 'Data Structures'];
          break;
        case 'Systems & Networking':
          topics = ['Network', 'Git'];
          break;
      }
      if (topics.isNotEmpty) {
        query = query.where('topic', whereIn: topics.take(30).toList());
      }
    }

    final snapshot = await query.get();

    final cleanQuestions = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Question.fromFirestore(data, doc.id).copyWith(
        description: (data['text'] ?? data['description'] ?? '').toString().trim(),
        options: data['options'] != null
            ? List<String>.from((data['options'] as List).map((o) => o.toString().trim()))
            : [],
        correctAnswer: data['correctAnswer']?.toString().trim(),
      );
    }).where((q) {
      final bool isMcq = q.type == QuestionType.mcq;
      final bool hasOptions = q.options != null && q.options!.length >= 2;
      final bool hasAnswer = q.correctAnswer != null && q.correctAnswer!.isNotEmpty;
      return isMcq && hasOptions && hasAnswer;
    }).toList();

    cleanQuestions.shuffle();
    final result = cleanQuestions.take(10).toList();
    if (result.isEmpty) {
      throw Exception('Yeterli soru bulunamadı.');
    }
    return result;
  }

  // ─────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────

  void dispose() {
    _matchSubscription?.cancel();
  }
}
