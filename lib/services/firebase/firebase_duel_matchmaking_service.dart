import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/duel_config.dart';
import '../../models/duel_match.dart';
import '../../models/duel_player.dart';
import '../../models/duel_enums.dart';
import '../../models/question.dart';
import '../duel/duel_matchmaking_service.dart';

class FirebaseDuelMatchmakingService implements DuelMatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<DuelMatch> _controller =
      StreamController<DuelMatch>.broadcast();

  StreamSubscription<DocumentSnapshot>? _matchSubscription;
  String? _queueDocId;
  String? _currentMatchId;
  Timer? _lobbyTimer;

  String _getUsername(User user) {
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }
    return user.email?.split('@').first ?? 'Player';
  }

  @override
  Stream<DuelMatch> startMatch(DuelConfig config) {
    print('🎮 [MATCHMAKING] startMatch called');
    _findOrCreateMatch(config);
    return _controller.stream;
  }

  Future<void> _findOrCreateMatch(DuelConfig config) async {
    final user = _auth.currentUser;
    if (user == null) {
      _controller.addError(Exception('Kullanıcı giriş yapmamış.'));
      return;
    }

    final username = _getUsername(user);

    try {
      // Başlangıç durumu: Searching
      _controller.add(DuelMatch(
        matchId: '',
        players: [
          DuelPlayer(
              userId: user.uid, username: username, avatarUrl: user.photoURL)
        ],
        questions: [],
        status: DuelStatus.searching,
        duelType: config.duelType,
        createdAt: DateTime.now(),
      ));

      // Multi modda hem 'waiting' hem 'lobbyCountdown' odalarını ara
      final statusFilters = config.duelType == DuelType.multi
          ? ['waiting', 'lobbyCountdown']
          : ['waiting'];

      final waitingQuery = await _firestore
          .collection('matchQueue')
          .where('status', whereIn: statusFilters)
          .where('duelType', isEqualTo: config.duelType.name)
          .where('category', isEqualTo: config.category)
          .limit(5)
          .get();

      final validDocs = waitingQuery.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['userId'] != user.uid;
      }).toList();

      if (validDocs.isNotEmpty) {
        final existingDoc = validDocs.first;
        final data = existingDoc.data() as Map<String, dynamic>?;
        final existingMatchId = data?['matchId'] as String?;

        if (existingMatchId != null && existingMatchId.isNotEmpty) {
          await _joinExistingMatch(
            matchId: existingMatchId,
            queueDocId: existingDoc.id,
            user: user,
            username: username,
            config: config,
          );
        } else {
          await _createNewMatch(user: user, username: username, config: config);
        }
      } else {
        await _createNewMatch(user: user, username: username, config: config);
      }
    } catch (e) {
      print('❌ [MATCHMAKING] Error: $e');
      _controller.addError(Exception('Matchmaking hatası: $e'));
    }
  }

  Future<void> _createNewMatch(
      {required User user,
      required String username,
      required DuelConfig config}) async {
    print('📥 [MATCHMAKING] Fetching MCQ questions...');
    final questions = await _fetchQuestions(config);

    final matchRef = _firestore.collection('matches').doc();
    final matchId = matchRef.id;
    _currentMatchId = matchId;

    final questionsData = questions.map((q) {
      return {
        'id': q.id,
        'title': q.title.trim(),
        'text': q.description?.trim() ?? '',
        'topic': q.topic,
        'type': 'MCQ',
        'options':
            (q.options ?? []).map((opt) => opt.toString().trim()).toList(),
        'correctAnswer': q.correctAnswer?.toString().trim(),
        'difficulty': q.difficulty.name,
      };
    }).toList();

    await matchRef.set({
      'matchId': matchId,
      'players': [
        {
          'userId': user.uid,
          'username': username,
          'avatarUrl': user.photoURL,
          'score': 0,
          'correctCount': 0,
          'totalXpGained': 0,
        }
      ],
      'questions': questionsData,
      'currentQuestionIndex': 0,
      'status': 'searching',
      'questionPhase': 'active',
      'duelType': config.duelType.name,
      'category': config.category,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final queueRef = await _firestore.collection('matchQueue').add({
      'userId': user.uid,
      'username': username,
      'duelType': config.duelType.name,
      'category': config.category,
      'status': 'waiting',
      'matchId': matchId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _queueDocId = queueRef.id;
    _listenToMatch(matchId, config.duelType);
  }

  Future<void> _joinExistingMatch(
      {required String matchId,
      required String queueDocId,
      required User user,
      required String username,
      required DuelConfig config}) async {
    _currentMatchId = matchId;
    final matchRef = _firestore.collection('matches').doc(matchId);

    // Atomik olarak oyuncuyu ekle
    await matchRef.update({
      'players': FieldValue.arrayUnion([
        {
          'userId': user.uid,
          'username': username,
          'avatarUrl': user.photoURL,
          'score': 0,
          'correctCount': 0,
          'totalXpGained': 0,
        }
      ]),
    });

    // Güncel player count'u oku
    final updatedSnapshot = await matchRef.get();
    final updatedData = updatedSnapshot.data()!;
    final playerCount = (updatedData['players'] as List).length;
    final duelTypeName = updatedData['duelType'] as String? ?? 'oneVsOne';
    final isMulti = duelTypeName == 'multi';

    if (!isMulti) {
      // ─── 1v1 MOD: Hemen başlat ───
      await matchRef.update({'status': 'matched'});
      await _firestore
          .collection('matchQueue')
          .doc(queueDocId)
          .update({'status': 'matched'});

      _listenToMatch(matchId, DuelType.oneVsOne);

      await Future.delayed(const Duration(seconds: 1));
      await matchRef.update({'status': 'countdown'});
      await Future.delayed(const Duration(seconds: 3));
      await matchRef.update(
          {'status': 'inProgress', 'startedAt': FieldValue.serverTimestamp()});
    } else {
      // ─── MULTI MOD: Flexible Lobby ───
      _listenToMatch(matchId, DuelType.multi);

      if (playerCount >= 5) {
        // 5. oyuncu → hemen başlat
        print('🚀 [MATCHMAKING] 5th player joined — starting immediately');
        _lobbyTimer?.cancel();
        await _firestore
            .collection('matchQueue')
            .doc(queueDocId)
            .update({'status': 'matched'});
        await matchRef.update({
          'status': 'inProgress',
          'startedAt': FieldValue.serverTimestamp(),
        });
        // Tüm queue'daki diğer waiting dokümanları da matched yap
        await _markAllQueueMatched(matchId);
      } else if (playerCount == 3) {
        // 3. oyuncu → 18 sn countdown başlat
        print('⏱ [MATCHMAKING] 3rd player joined — starting 18s countdown');
        final countdownEnd =
            DateTime.now().add(const Duration(seconds: 18));
        await matchRef.update({
          'status': 'lobbyCountdown',
          'lobbyCountdownEndAt': Timestamp.fromDate(countdownEnd),
        });
        _startLobbyCountdown(matchRef, matchId);
      } else if (playerCount < 3) {
        // 2. oyuncu (multi modda) → bekle
        print('⏳ [MATCHMAKING] $playerCount players — waiting for 3+');
      }
      // playerCount == 4 → hiçbir şey yapma, timer devam ediyor
    }
  }

  /// Multi modda 18 sn lobby countdown timer'ı
  void _startLobbyCountdown(DocumentReference matchRef, String matchId) {
    _lobbyTimer?.cancel();

    _lobbyTimer = Timer(const Duration(seconds: 18), () async {
      try {
        // Timer dolduğunda durumu kontrol et — hâlâ lobbyCountdown mu?
        final snap = await matchRef.get();
        if (!snap.exists) return;
        final data = snap.data() as Map<String, dynamic>?;
        if (data == null) return;

        final currentStatus = data['status'] as String?;
        if (currentStatus != 'lobbyCountdown') {
          // Zaten başlamış (5. oyuncu geldi) veya iptal edilmiş
          return;
        }

        print('⏰ [MATCHMAKING] Lobby countdown expired — starting game');
        await matchRef.update({
          'status': 'inProgress',
          'startedAt': FieldValue.serverTimestamp(),
        });
        await _markAllQueueMatched(matchId);
      } catch (e) {
        print('❌ [MATCHMAKING] Lobby countdown error: $e');
      }
    });
  }

  /// matchId'ye ait tüm queue dokümanlarını 'matched' olarak işaretle
  Future<void> _markAllQueueMatched(String matchId) async {
    final queueDocs = await _firestore
        .collection('matchQueue')
        .where('matchId', isEqualTo: matchId)
        .where('status', whereIn: ['waiting', 'lobbyCountdown'])
        .get();
    for (final doc in queueDocs.docs) {
      await doc.reference.update({'status': 'matched'});
    }
  }

  void _listenToMatch(String matchId, DuelType duelType) {
    _matchSubscription?.cancel();
    _matchSubscription = _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final match = _mapFirestoreToMatch(matchId, data);

      // Multi modda: 5. oyuncu gelirse lobby timer'ı iptal et ve başlat
      if (duelType == DuelType.multi &&
          match.status == DuelStatus.lobbyCountdown &&
          match.players.length >= 5) {
        _lobbyTimer?.cancel();
        _firestore.collection('matches').doc(matchId).update({
          'status': 'inProgress',
          'startedAt': FieldValue.serverTimestamp(),
        });
        _markAllQueueMatched(matchId);
        return; // Sonraki snapshot'ta inProgress olarak gelecek
      }

      _controller.add(match);
    });
  }

  Future<List<Question>> _fetchQuestions(DuelConfig config) async {
    print('🔎 [FETCH] MCQ Filtreleme başlatıldı...');

    Query query =
        _firestore.collection('questions').where('type', isEqualTo: 'MCQ');

    if (config.category != 'Mixed') {
      final topics = _getMappedTopics(config.category);
      if (topics.isNotEmpty) {
        query = query.where('topic', whereIn: topics.take(30).toList());
      }
    }

    final snapshot = await query.get();

    final cleanQuestions = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Question.fromFirestore(data, doc.id).copyWith(
        description:
            (data['text'] ?? data['description'] ?? '').toString().trim(),
        options: data['options'] != null
            ? List<String>.from(
                (data['options'] as List).map((o) => o.toString().trim()))
            : [],
        correctAnswer: data['correctAnswer']?.toString().trim(),
      );
    }).where((q) {
      final bool isMcq = q.type == QuestionType.mcq;
      final bool hasOptions = q.options != null && q.options!.length >= 2;
      final bool hasAnswer =
          q.correctAnswer != null && q.correctAnswer!.isNotEmpty;
      if (!isMcq)
        print('⛔ [FETCH] Elendi (type != MCQ): ${q.id} | type=${q.type}');
      if (isMcq && !hasOptions)
        print('⛔ [FETCH] Elendi (options boş): ${q.id}');
      if (isMcq && hasOptions && !hasAnswer)
        print('⛔ [FETCH] Elendi (correctAnswer yok): ${q.id}');
      return isMcq && hasOptions && hasAnswer;
    }).toList();

    cleanQuestions.shuffle();
    final result = cleanQuestions.take(10).toList();

    print('✅ [FETCH] ${result.length} adet saf MCQ hazırlandı.');
    if (result.length < 10) {
      print('⚠️ [FETCH] Yeterli MCQ bulunamadı! Bulunan: ${result.length}');
    }
    return result;
  }

  List<String> _getMappedTopics(String macroCategory) {
    switch (macroCategory) {
      case 'Programming':
        return ['C / C++', 'Java', 'Python'];
      case 'Algorithms':
        return ['Algorithms', 'Data Structures'];
      case 'Data & AI':
        return ['Data Science', 'Machine Learning'];
      case 'Databases':
        return ['SQL'];
      case 'Systems':
        return ['Network', 'Git'];
      case 'Soft Skills':
        return ['Soft Skills'];
      default:
        return [];
    }
  }

  DuelMatch _mapFirestoreToMatch(String matchId, Map<String, dynamic> data) {
    final players = (data['players'] as List? ?? [])
        .map((p) => DuelPlayer(
              userId: p['userId'] ?? '',
              username: p['username'] ?? p['displayName'] ?? 'Player',
              avatarUrl: p['avatarUrl'] ?? p['photoUrl'] ?? p['photoURL'],
              score: p['score'] ?? 0,
              correctCount: p['correctCount'] ?? 0,
              totalXpGained: p['totalXpGained'] ?? 0,
            ))
        .toList();

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
      final valid = q.options != null &&
          q.options!.length >= 2 &&
          q.correctAnswer != null &&
          q.correctAnswer!.isNotEmpty;
      if (!valid) print('⛔ [MAP] Geçersiz soru atlandı: ${q.id}');
      return valid;
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
      lobbyCountdownEndAt: lobbyCountdownEndAt,
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

  @override
  Future<void> cancelMatch() async {
    _lobbyTimer?.cancel();
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final activeQueues = await _firestore
          .collection('matchQueue')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['waiting', 'matched', 'lobbyCountdown']).get();
      for (var doc in activeQueues.docs) {
        final mId = doc.data()['matchId'];
        await doc.reference.update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp()
        });
        if (mId != null && mId.isNotEmpty) {
          await _firestore.collection('matches').doc(mId).update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp()
          });
        }
      }
      _queueDocId = null;
      _currentMatchId = null;
    } catch (e) {
      print('❌ [CANCEL ERROR]: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _lobbyTimer?.cancel();
    _matchSubscription?.cancel();
    await _controller.close();
  }
}
