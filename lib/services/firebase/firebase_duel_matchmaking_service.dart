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

  String _getUsername(User user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
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
      // Başlangıç durumu: Searching [cite: 38, 61]
      _controller.add(DuelMatch(
        matchId: '',
        players: [
          DuelPlayer(
              userId: user.uid, username: username, avatarUrl: user.photoURL)
        ],
        questions: [],
        status: DuelStatus.searching,
        createdAt: DateTime.now(),
      ));

      final waitingQuery = await _firestore
          .collection('matchQueue')
          .where('status', isEqualTo: 'waiting')
          .where('duelType', isEqualTo: config.duelType.name)
          .where('category', isEqualTo: config.category)
          .where('userId', isNotEqualTo: user.uid)
          .limit(1)
          .get();

      if (waitingQuery.docs.isNotEmpty) {
        final existingDoc = waitingQuery.docs.first;
        final existingMatchId = existingDoc.data()['matchId'] as String?;

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
      // 🔥 KRİTİK: Veritabanına yazarken 'text' ve 'options' alanlarını paketliyoruz
      return {
        'id': q.id,
        'title': q.title.trim(),
        'text': q.description?.trim() ?? '', // Beyaz kutu metni
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
    _listenToMatch(matchId);
  }

  Future<void> _joinExistingMatch(
      {required String matchId,
      required String queueDocId,
      required User user,
      required String username,
      required DuelConfig config}) async {
    _currentMatchId = matchId;
    final matchRef = _firestore.collection('matches').doc(matchId);

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
      'status': 'matched',
    });

    await _firestore
        .collection('matchQueue')
        .doc(queueDocId)
        .update({'status': 'matched'});

    _listenToMatch(matchId);

    // Lifecycle: matched -> countdown -> inProgress [cite: 39, 62-64]
    await Future.delayed(const Duration(seconds: 1));
    await matchRef.update({'status': 'countdown'});
    await Future.delayed(const Duration(seconds: 3));
    await matchRef.update(
        {'status': 'inProgress', 'startedAt': FieldValue.serverTimestamp()});
  }

  void _listenToMatch(String matchId) {
    _matchSubscription?.cancel();
    _matchSubscription = _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      _controller.add(_mapFirestoreToMatch(matchId, data));
    });
  }

  Future<List<Question>> _fetchQuestions(DuelConfig config) async {
    print('🔎 [FETCH] MCQ Filtreleme başlatıldı...');

    // 1. ADIM: Firestore'dan tipi MCQ olanları iste.
    // Eğer burada bir hata oluyorsa (örneğin indeks eksikliği),
    // sorgu tüm soruları çekiyor olabilir.
    Query query =
        _firestore.collection('questions').where('type', isEqualTo: 'MCQ');

    if (config.category != 'Mixed') {
      final topics = _getMappedTopics(config.category);
      if (topics.isNotEmpty) {
        query = query.where('topic', whereIn: topics.take(30).toList());
      }
    }

    final snapshot = await query.get();

    // 2. ADIM: MANUEL TİP KONTROLÜ (En önemli kısım)
    // Firestore sorgusu bazen yanlış sonuç verse bile (cache vs. kaynaklı),
    // bu 'where' filtresi coding sorularını kapıdan içeri sokmaz.
    final cleanQuestions = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Question.fromFirestore(data, doc.id).copyWith(
        description: data['text'] ?? data['description'] ?? '',
      );
    }).where((q) {
      // 🔥 BURASI KRİTİK: Sadece tipi MCQ olan VE şıkları olanları al!
      // Senin paylaştığın 'coding' tipi sorular burada elenecek.
      return q.type == QuestionType.mcq &&
          q.options != null &&
          q.options!.isNotEmpty;
    }).toList();

    // 3. ADIM: Karıştır ve tam 10 tane al
    cleanQuestions.shuffle();

    final result = cleanQuestions.take(10).toList();
    print('✅ [FETCH] ${result.length} adet gerçek MCQ hazırlandı.');
    return result;
  }

  List<String> _getMappedTopics(String macroCategory) {
    // PDF Sayfa 4 ve TXT dokümanına göre mapping [cite: 96-110, 141]
    switch (macroCategory) {
      case 'Programming Languages':
        return ['C / C++', 'Java', 'Python'];
      case 'Algorithms & Data Structures':
        return ['Algorithms', 'Data Structures'];
      case 'Data & AI':
        return ['Data Science', 'Machine Learning', 'SQL'];
      case 'Systems & Networking':
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
              username: p['username'] ?? 'Player',
              avatarUrl: p[
                  'avatarUrl'], // Network image hatası için URL formatında kalmalı
              score: p['score'] ?? 0,
              correctCount: p['correctCount'] ?? 0,
              totalXpGained: p['totalXpGained'] ?? 0,
            ))
        .toList();

    final questions = (data['questions'] as List? ?? []).map((q) {
      final qMap = q as Map<String, dynamic>;

      // matches dokümanından geri okurken veriyi garantiliyoruz
      return Question.fromFirestore(qMap, qMap['id'] ?? '').copyWith(
        description: qMap['text'] ?? qMap['description'] ?? '',
        options:
            qMap['options'] != null ? List<String>.from(qMap['options']) : [],
        type: QuestionType.mcq,
      );
    }).toList();

    return DuelMatch(
      matchId: matchId,
      players: players,
      questions: questions,
      currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
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
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final activeQueues = await _firestore
          .collection('matchQueue')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['waiting', 'matched']).get();
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
    _matchSubscription?.cancel();
    await _controller.close();
  }
}
