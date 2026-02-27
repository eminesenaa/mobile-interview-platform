import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../models/duel_match.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_result.dart';
import '../../../models/question.dart';
import '../duel_result_page.dart';

class DuelGameController extends GetxController {
  final DuelMatch initialMatch;

  DuelGameController(this.initialMatch);

  final match = Rx<DuelMatch?>(null);
  final remainingSeconds = 0.obs;
  final isLoadingQuestions = true.obs;

  Timer? _questionTimer;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    print('🎮 [GAME] DuelGameController onInit');

    match.value = initialMatch;
    _initializeGame();
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeGame() async {
    final currentMatch = match.value;
    if (currentMatch == null) return;

    print('🎮 [GAME] _initializeGame tetiklendi');

    // 1. ADIM: Matchmaking servisinden gelen soruları kontrol et
    if (currentMatch.questions.isNotEmpty) {
      print(
          '✅ [GAME] Match dokümanından ${currentMatch.questions.length} soru başarıyla alındı');

      // Veritabanındaki 'text' alanının 'description'a doğru geçtiğinden emin olalım
      isLoadingQuestions.value = false;
    }
    // 2. ADIM: Eğer sorular boş geldiyse (Matchmaking'de hata olduysa)
    else {
      print(
          '⚠️ [GAME] Match dokümanında soru bulunamadı! Yedek çekim deneniyor...');
      isLoadingQuestions.value = true;
      try {
        final category = initialMatch.category ?? 'Mixed';

        // Sadece MCQ tipindeki yedek soruları çek
        final questions = await _fetchQuestionsFromFirestore(
          category: category,
          count: 10,
        );

        currentMatch.questions.clear();
        currentMatch.questions.addAll(questions);
        print('✅ [GAME] Yedek MCQ soruları yüklendi: ${questions.length} adet');
      } catch (e) {
        print('❌ [GAME] Firestore fallback failed: $e');
        currentMatch.questions.clear();
        currentMatch.questions.addAll(_fallbackQuestions());
      } finally {
        isLoadingQuestions.value = false;
        match.refresh();
      }
    }

    print('🚀 [GAME] Soru fazına geçiliyor...');
    _startQuestion();
  }

  Future<List<Question>> _fetchQuestionsFromFirestore({
    required String category,
    required int count,
  }) async {
    // Sadece "MCQ" tipindeki soruları çekmek için filtre ekledik
    Query query =
        _firestore.collection('questions').where('type', isEqualTo: 'MCQ');

    if (category != 'Mixed') {
      final mappedTopics = _getMappedTopics(category);
      if (mappedTopics.isNotEmpty) {
        query = query.where('topic', whereIn: mappedTopics.take(30).toList());
      }
    }

    final snapshot = await query.limit(count * 3).get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Uygun MCQ sorusu bulunamadı.');
    }

    final allQuestions = snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Question.fromFirestore zaten data['text'] -> description dönüşümünü yapar
          return Question.fromFirestore(data, doc.id);
        })
        .where((q) => q.type == QuestionType.mcq)
        .toList(); // Double-check filtreleme

    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  List<String> _getMappedTopics(String macroCategory) {
    switch (macroCategory) {
      case 'Programming':
      case 'Programming Languages':
        return ['C / C++', 'Java', 'Python'];
      case 'Algorithms':
      case 'Algorithms & Data Structures':
        return ['Algorithms', 'Data Structures'];
      case 'Data & AI':
        return ['Data Science', 'Machine Learning', 'SQL'];
      case 'Systems':
      case 'Systems & Networking':
        return ['Network', 'Git'];
      case 'Soft Skills':
        return ['Soft Skills'];
      default:
        return [];
    }
  }

  void _startQuestion() {
    final currentMatch = match.value!;
    if (currentMatch.questions.isEmpty) return;

    remainingSeconds.value = 10;
    currentMatch.questionPhase = DuelQuestionPhase.active;
    match.refresh();

    _startTimer();
  }

  void _startTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        _forceReveal();
      }
    });
  }

  void selectOption(int optionIndex) {
    final currentMatch = match.value!;
    if (currentMatch.questionPhase != DuelQuestionPhase.active) return;

    currentMatch.submitAnswer(
      userId: _localUserId(),
      selectedOptionIndex: optionIndex,
      answerTimeSeconds: 10 - remainingSeconds.value,
    );

    match.refresh();

    if (currentMatch.allPlayersAnswered) {
      _questionTimer?.cancel();
      _forceReveal();
    }
  }

  String _localUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  }

  void _forceReveal() {
    final currentMatch = match.value!;
    currentMatch.questionPhase = DuelQuestionPhase.reveal;
    match.refresh();

    Future.delayed(const Duration(seconds: 2), () {
      _afterReveal();
    });
  }

  void _afterReveal() {
    final currentMatch = match.value!;

    if (currentMatch.isLastQuestion) {
      currentMatch.finalizeMatch();
      final result = currentMatch.buildResult();
      Get.off(() => const DuelResultPage(), arguments: result);
    } else {
      currentMatch.moveToNextQuestion();
      match.refresh();
      _startQuestion();
    }
  }

  List<Question> _fallbackQuestions() {
    return [
      Question(
        id: 'fallback_q1',
        title: 'Binary Search Time Complexity',
        description: 'What is the average time complexity of Binary Search?',
        topic: 'Algorithms',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['binary search'],
        type: QuestionType.mcq,
        options: const ['O(n)', 'O(log n)', 'O(n log n)', 'O(1)'],
        correctAnswer: '1',
      ),
    ];
  }
}
