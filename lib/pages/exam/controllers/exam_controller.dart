// ===================== File: lib/pages/exam/controllers/exam_controller.dart =====================
// Purpose: Sınav başlatma, yanıt yönetimi, zamanlayıcı ve sonuç ekranına geçiş.
//          Firestore'dan filtreye göre dinamik olarak alınan soru listesini destekler.
// =================================================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/ai_exam_result.dart';
import '../../../models/ai_interview_result.dart';
import '../../../models/exam.dart';
import '../../../models/interview.dart';
import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/interview/interview_service.dart';
import '../../interview/pages/interview/submitted/interview_submitted_page.dart';
import 'create_exam_controller.dart'; // ✅ düzeltildi
import 'exam_coding_controller.dart';
import '../result/exam_result_page.dart'; // ✅ bir üst klasörde
import '../services/exam_xp_service.dart';
import '../../../services/sfx/sound_service.dart';

class ExamController extends GetxController {
  final Exam exam;

  ExamController(this.exam);

  final _db = FirebaseFirestore.instance;

  late Rx<ExamStateModel> state;
  Timer? _ticker;
  bool _paused = false;
  bool _warningPlayed = false; // Track if warning sound has been played

  Question get currentQuestion => exam.questions[state.value.currentIndex];

  int get total => exam.questions.length;

  int get answeredCount => state.value.answers.length;

  int get flaggedCount => flaggedQuestions.length;

  int get unansweredCount => total - answeredCount;

  int get currentNumber => state.value.currentIndex + 1;

  final Map<String, dynamic> answers = {};
  final Map<String, TextEditingController> shortControllers = {};
  final RxSet<String> flaggedIds = <String>{}.obs;
  final RxSet<String> flaggedQuestions = <String>{}.obs;
  final clearTick = 0.obs;


  @override
  void onInit() {
    super.onInit();
    state = ExamStateModel(
      examId: exam.id,
      secondsLeft: exam.duration.inSeconds,
    ).obs;

    _startTicker();

    Future.microtask(() async {
      await _loadSavedAnswers();
      state.refresh();
    });
  }

  // ===========================
  // 🔹 EXAM BAŞLATMA (Yeni yapı)
  // ===========================
  static Future<ExamController> createFromFilters() async {
    final createExamController = Get.find<CreateExamController>();
    final questions = await createExamController.generateExamQuestions();

    // ✅ Exam modelinde createdAt zorunlu olduğu için eklendi
    final exam = Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Custom Exam',
      questions: questions,
      duration: Duration(minutes: questions.length),
      // 1 dk/soru
      createdAt: DateTime.now(),
    );

    final controller = ExamController(exam);
    Get.put(controller);
    return controller;
  }

  // ===========================
  // 🔹 Timer, navigation, progress vb.
  // ===========================
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.value.submitted) return;
      if (_paused) return; // ⬅️ paused ise zaman akmasın
      final left = state.value.secondsLeft - 1;
      
      // 🔊 Play warning sound when 10 seconds left (only once)
      if (left == 10  && !_warningPlayed) {
        print("Warning sound played!");
        SoundService.play(SoundEffect.timerWarning);
        _warningPlayed = true;
      }
      
      if (left <= 0) {
        submit(auto: true);
      } else {
        state.value = state.value.copyWith(secondsLeft: left);
        state.refresh();
      }
    });
  }

  void pauseTimer() {
    _paused = true;
  }

  void resumeTimer() {
    if (!state.value.submitted) {
      _paused = false;
    }
  }

  void answerCurrent(dynamic value) {
    final q = currentQuestion;
    final newAnswers = Map<String, dynamic>.from(state.value.answers);

    if (value == null) {
      newAnswers.remove(q.id);
    } else {
      newAnswers[q.id] = value;
    }

    state.value = state.value.copyWith(answers: newAnswers);
    state.refresh();
  }

  Future<void> _loadSavedAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exam_${exam.id}_answers';
    final saved = prefs.getString(key);
    if (saved == null) return;

    try {
      final decoded = jsonDecode(saved);
      if (decoded is Map<String, dynamic>) {
        answers.clear();
        decoded.forEach((key, value) {
          answers[key] = value;
        });

        state.value = state.value.copyWith(
          answers: Map<String, dynamic>.from(answers),
        );
        state.refresh();
        updateProgress();
      }
    } catch (e) {
      debugPrint('Failed to load saved answers: $e');
    }
  }

  Future<void> _persistAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exam_${exam.id}_answers';

    final safeMap = <String, dynamic>{};
    answers.forEach((key, value) {
      if (value is Map) {
        safeMap[key] =
            value.map((k, v) => MapEntry(k.toString(), v.toString()));
      } else if (value is List) {
        safeMap[key] = value.map((e) => e.toString()).toList();
      } else {
        safeMap[key] = value.toString();
      }
    });

    await prefs.setString(key, jsonEncode(safeMap));
  }

  void saveAnswer(String questionId, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(state.value.answers);

    if (answer == null || (answer is String && answer.trim().isEmpty)) {
      answers.remove(questionId);
      newAnswers.remove(questionId);
    } else {
      answers[questionId] = answer;
      newAnswers[questionId] = answer;
    }

    state.value = state.value.copyWith(answers: newAnswers);
    state.refresh();
    updateProgress();
    _persistAnswers();
  }

  void toggleFlag(String questionId) {
    if (flaggedQuestions.contains(questionId)) {
      flaggedQuestions.remove(questionId);
    } else {
      flaggedQuestions.add(questionId);
    }
    state.refresh();
    // 🔊 Flag toggle sound
    SoundService.playSync(SoundEffect.flagToggle);
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= exam.questions.length) return;
    state.value = state.value.copyWith(currentIndex: index);
    state.refresh();
  }

  bool isAnswered(String questionId) => answers.containsKey(questionId);

  bool isFlagged(String questionId) => flaggedQuestions.contains(questionId);

  void clearAnswer(String questionId) {
    // 🔹 1. Local cache
    answers.remove(questionId);

    // 🔹 2. State answers'tan da sil
    final newAnswers = Map<String, dynamic>.from(state.value.answers);
    newAnswers.remove(questionId);

    state.value = state.value.copyWith(
      answers: newAnswers,
    );
    state.refresh();

    // 🔹 3. MCQ key-reset için
    clearTick.value++;

    // 🔹 4. Progress yeniden hesapla
    updateProgress();
  }


  void updateProgress() {
    final total = exam.questions.length;
    final answered = answers.length;
    final unanswered = total - answered;
    final newState = state.value.copyWith(
      answered: answered,
      unanswered: unanswered,
    );
    state.value = newState;
    state.refresh();
  }

  void clearCurrent() {
    final q = currentQuestion;
    final newAnswers = Map<String, dynamic>.from(state.value.answers);
    newAnswers.remove(q.id);
    state.value = state.value.copyWith(answers: newAnswers);
    state.refresh();
  }

  void next() {
    if (state.value.currentIndex < exam.questions.length - 1) {
      state.value =
          state.value.copyWith(currentIndex: state.value.currentIndex + 1);
      state.refresh();
      // 🔊 Page swipe sound
      SoundService.playSync(SoundEffect.swipe);
    }
  }

  void prev() {
    if (state.value.currentIndex > 0) {
      state.value =
          state.value.copyWith(currentIndex: state.value.currentIndex - 1);
      state.refresh();
      // 🔊 Page swipe sound
      SoundService.playSync(SoundEffect.swipe);
    }
  }

  Future<void> submit({bool auto = false}) async {
    _ticker?.cancel();
    state.value = state.value.copyWith(submitted: true);
    state.refresh();

    final snapshotAnswers = Map<String, dynamic>.from(state.value.answers);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exam_${exam.id}_answers');

    // 1️⃣ Kullanıcının cevaplarını ekleyerek yeni exam oluştur
    final resultExam = exam.copyWith(answers: snapshotAnswers);

    try {
      // =======================================================
      // 🔥 INTERVIEW MODE CHECK
      // =======================================================
      // TODO (Backend):
      // - Replace this flag with real interview session type
      // - Backend should determine if this is an interview
      final bool isInterview = exam.isInterview;

      // =======================================================
      // 🔥 INTERVIEW FLOW — AI EVALUATION
      // =======================================================
      if (isInterview) {
        print('');
        print('╔══════════════════════════════════════════════════════╗');
        print('║       🎯 INTERVIEW SUBMIT — AI SCORING STARTED      ║');
        print('╚══════════════════════════════════════════════════════╝');
        print('📋 Interview ID: ${exam.id}');
        print('📋 Total Questions: ${exam.questions.length}');
        print('📋 Answers Provided: ${snapshotAnswers.length}/${exam.questions.length}');
        print('📋 Unanswered: ${exam.questions.length - snapshotAnswers.length}');
        print('');

        // Log answer preview per question
        for (int i = 0; i < exam.questions.length; i++) {
          final q = exam.questions[i];
          final ans = snapshotAnswers[q.id];
          final ansPreview = ans == null
              ? '⬜ (empty)'
              : (ans.toString().length > 60
                  ? '${ans.toString().substring(0, 60)}...'
                  : ans.toString());
          print('   Q$i [${q.type.name}] ${q.title.length > 40 ? q.title.substring(0, 40) + '...' : q.title}');
          print('      → Answer: $ansPreview');
        }
        print('');

        // Build Interview object from exam data.
        // NOTE: The InterviewSessionController currently converts the real
        // interview into an Exam. Ideally the Interview object should be
        // passed through navigation arguments. For now we reconstruct it.
        // TODO (Backend): Pass the real Interview object through Get.arguments
        //   instead of reconstructing it here.
        final interview = Interview(
          id: exam.id,
          companyId: '',        // TODO (Backend): populate from session
          createdByHrId: '',    // TODO (Backend): populate from session
          title: exam.title,
          position: '',         // TODO (Backend): populate from session
          questions: exam.questions,
          candidateIds: [],
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          joinCode: '',
          status: InterviewStatus.completed,
          reviewStatus: ReviewStatus.pending,
          createdAt: exam.createdAt,
        );

        print('✅ Interview object built successfully');
        print('🚀 Sending to AI evaluation pipeline (2-stage)...');
        print('');

        // 🔥 Create a pending AI Result
        final pendingAiResult = const AiInterviewResult(
          finalDecision: "pending",
          overallInterviewScore: 0.0,
        );

        // =======================================================
        // ✅ BACKEND: Save "pending" interview result to Firestore immediately
        // =======================================================
        try {
          final interviewService = Get.find<InterviewService>();
          final currentUserId =
              FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

          await interviewService.saveInterviewResult(
            interviewId: exam.id,
            userId: currentUserId,
            answers: snapshotAnswers,
            aiResult: pendingAiResult,
          );
          print('✅ Pending interview result persisted to Firestore');
        } catch (e) {
          print('❌ Failed to save pending interview result: $e');
        }

        // 🔥 ALWAYS mark THIS CANDIDATE as completed (per-candidate tracking)
        // Don't mark the whole interview as 'completed' — other candidates still need it!
        try {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
          final interviewRef = _db.collection('interviews').doc(exam.id);
          
          // Add this candidate to completedCandidateIds AND ensure they are in candidateIds
          await interviewRef.update({
            'completedCandidateIds': FieldValue.arrayUnion([currentUserId]),
            'candidateIds': FieldValue.arrayUnion([currentUserId]),
          });
          
          // Check if ALL candidates have completed → then mark the whole interview as 'completed'
          final interviewDoc = await interviewRef.get();
          if (interviewDoc.exists) {
            final data = interviewDoc.data()!;
            final candidateIds = List<String>.from(data['candidateIds'] ?? []);
            final completedIds = List<String>.from(data['completedCandidateIds'] ?? []);
            
            // Only mark as 'completed' if everyone is done
            if (candidateIds.isNotEmpty &&
                candidateIds.every((id) => completedIds.contains(id))) {
              await interviewRef.update({'status': 'completed'});
              print('✅ All candidates done — interview status set to completed');
            } else {
              print('✅ This candidate done. Waiting for ${candidateIds.length - completedIds.length} more candidate(s).');
            }
          }
        } catch (e) {
          print('❌ Failed to update per-candidate completion: $e');
        }

        // 🔥 Fire & Forget: Run AI Evaluation in Background
        Future.microtask(() async {
          try {
            print('🚀 Sending to AI evaluation pipeline in background...');
            final aiService = Get.find<AiService>();
            final aiResult = await aiService.evaluateInterview(
              interview: interview,
              userAnswers: snapshotAnswers,
            );
            print('✅ Background AI evaluation completed!');
            
            // Save updated result
            final interviewService = Get.find<InterviewService>();
            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
            await interviewService.saveInterviewResult(
              interviewId: exam.id,
              userId: currentUserId,
              answers: snapshotAnswers,
              aiResult: aiResult,
            );
            print('✅ Updated AI result saved to Firestore.');
          } catch (e) {
            print('❌ Background AI evaluation failed: $e');
          }
        });

        // 🔊 Completion sound
        SoundService.play(SoundEffect.examComplete);

        print('🔄 Navigating to InterviewSubmittedPage...');

        Get.offAll(
              () => InterviewSubmittedPage(),
          arguments: {
            'exam': resultExam,
            'aiResult': pendingAiResult,
          },
        );

        return;
      }

      // =======================================================
      // 🔥 NORMAL EXAM FLOW (UNCHANGED)
      // =======================================================

      // 2️⃣ AI değerlendirmesi
      final aiService = Get.find<AiService>();
      final aiEval = await aiService.evaluateExam(
        exam: resultExam,
        userAnswers: snapshotAnswers,
      );

      final aiResult = AiExamResult.fromEvaluateResult(aiEval);

      final Map<String, dynamic> aiFeedbackMap = {
        for (final qEval in aiEval.questionEvaluations)
          qEval.questionGeneralIndex: qEval.explanation,
      };

      // 3️⃣ Exam istatistiklerini güncelle
      final updatedExam = resultExam.copyWith(
        aiFeedback: aiFeedbackMap,
        stats: {
          'correct': aiResult.correctCount,
          'wrong': aiResult.wrongCount,
          'unanswered': aiResult.unansweredCount,
        },
        aiResult: aiEval,
      );

      // 🔥🔥 4️⃣ EXAM XP KAYDI
      await ExamXpService.saveExamResult(
        exam: updatedExam,
        aiResult: aiResult,
      );

      // 🔊 Exam completed celebration sound
      SoundService.play(SoundEffect.examComplete);

      // 5️⃣ Sonuç sayfasına yönlendir
      Get.offAll(
            () => const ExamResultPage(),
        arguments: {
          'exam': updatedExam,
          'aiResult': aiResult,
        },
      );
    } catch (e, st) {
      debugPrint("⚠️ AI evaluation failed: $e\n$st");

      // =======================================================
      // 🔥 ERROR CASE → INTERVIEW VS EXAM AYRIMI
      // =======================================================
      final bool isInterview = exam.isInterview;

      if (isInterview) {
        // AI evaluation failed — navigate without aiResult
        Get.offAll(
              () => InterviewSubmittedPage(),
          arguments: {
            'exam': resultExam,
            // aiResult is null — AI evaluation failed
          },
        );
      } else {
        Get.offAll(
              () => const ExamResultPage(),
          arguments: {
            'exam': resultExam,
          },
        );
      }
    }
  }

  @override
  void onClose() {
    _ticker?.cancel();
    for (final q in exam.questions) {
      if (q.type == QuestionType.coding) {
        Get.delete<ExamCodingController>(tag: q.id, force: true);
      }
    }
    super.onClose();
  }
}
