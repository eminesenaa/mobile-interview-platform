// ===================== File: interview_session_controller.dart =====================
// Purpose:
// Controls Interview Waiting & Session Flow
//
// Responsibilities:
// - Hold interview session data
// - Manage waiting state
// - Auto-start interview (simulate host start)
// - Navigate to exam page
//
// IMPORTANT:
// - Uses mock logic for now
// - Backend-ready structure
//
// TODO (Backend):
// - Validate invite code via API
// - Fetch interview session details
// - Listen to "session started" event (WebSocket / Firestore)
// - Replace timer-based auto start
// ==============================================================================

import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/exam.dart';
import '../../../models/question.dart';
import '../../exam/take/exam_page.dart'; // 🔥 REUSE

class InterviewSessionController extends GetxController {
  // ===============================
  // INTERVIEW DATA
  // ===============================

  final date = "".obs;
  final time = "".obs;
  final sessionCode = "".obs;
  final isWaiting = true.obs;

  // ===============================
  // INTERNAL TIMER
  // ===============================

  Timer? _autoStartTimer;

  // ===============================
  // FIRESTORE
  // ===============================

  final _db = FirebaseFirestore.instance;

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    // ⚠️ IMPORTANT (TEMPORARY)
    // - Currently generating mock Interview ID
    // - Invite code and interview ID are DIFFERENT
    // TODO (Backend):
    // - Replace with real interview session ID from API
    if (args != null) {
      date.value = args["date"] ?? "May 14, 2026";
      time.value = args["time"] ?? "10:00 – 11:00";
      // 🔥 Invite Code (user input)
      final inviteCode = args["code"] ?? "TEMP";

      // 🔥 Mock Interview ID (different from invite code)
      sessionCode.value =
          "INT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    }

    startWaitingFlow();
  }

  // ===============================
  // WAITING FLOW
  // ===============================

  void startWaitingFlow() {
    _autoStartTimer = Timer(
      const Duration(seconds: 5),
      () {
        startInterview();
      },
    );
  }

  // ===============================
  // START INTERVIEW
  // ===============================

  Future<void> startInterview() async {
    isWaiting.value = false;

    final mockExam = await _createMockInterviewExam();

    Get.offAll(
      () => const ExamPage(),
      arguments: mockExam,
    );
  }

  // ===============================
  // 🔥 MOCK EXAM BUILDER (FIRESTORE)
  // ===============================

  Future<Exam> _createMockInterviewExam() async {
    // =======================================================
    // ⚠️ IMPORTANT NOTE (VERY IMPORTANT)
    // =======================================================
    // 🔴 ASIL BACKEND GELENE KADAR GÖSTERMELİK ÇEKİLEN RASTGELE 10 SORU
    //
    // TODO (Backend):
    // - Replace this logic with:
    //   → API call using invite code
    //   → Fetch questions selected by HR (by question IDs)
    // - Example:
    //   final questions = await fetchQuestionsByIds(ids);
    // =======================================================

    final questions = await _fetchRandomQuestions(limit: 10);

    return Exam(
      id: "interview_${DateTime.now().millisecondsSinceEpoch}",
      title: "Interview",
      duration: Duration(minutes: questions.length),
      createdAt: DateTime.now(),
      questions: questions,
    );
  }

  // ===============================
  // 🔥 RANDOM QUESTION FETCH (REUSE LOGIC)
  // ===============================

  Future<List<Question>> _fetchRandomQuestions({int limit = 10}) async {
    final col = _db.collection('questions');

    // 🔹 Firestore'dan soru havuzunu çek
    final snap = await col.limit(1000).get();

    final allQuestions =
        snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();

    // 🔹 Shuffle (rastgele karıştır)
    allQuestions.shuffle(Random());

    // 🔹 İlk 10 soruyu al
    return allQuestions.take(limit).toList();
  }

  // ===============================
  // CLEANUP
  // ===============================

  @override
  void onClose() {
    _autoStartTimer?.cancel();
    super.onClose();
  }
}
