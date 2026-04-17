// ===================== File: interview_controller.dart =====================
// Purpose:
// Main state controller for Interview feature (Candidate side)
//
// Responsibilities:
// - Fetch interviews
// - Handle interview entry flow (too early / waiting / active)
// - Manage session lifecycle
// - Control timer
//
// Uses InterviewService (currently fake implementation)
//
// ==========================================================================

import 'dart:async';

import 'package:get/get.dart';

import '../../../models/interview.dart';
import '../../../models/interview_session.dart';
import '../../../models/interview_result.dart';
import '../../../services/interview/interview_service.dart';
import '../../../services/interview/fake_interview_service.dart';

enum InterviewFlowState {
  loading,
  tooEarly,
  waiting,
  ready,
  active,
  completed,
}

class InterviewController extends GetxController {
  // ===================== SERVICE =====================

  /// ⚠️ Fake service for now (backend later)
  final InterviewService _service = FakeInterviewService();

  // ===================== STATE =====================

  var interviews = <Interview>[].obs;
  var selectedInterview = Rxn<Interview>();

  var currentSession = Rxn<InterviewSession>();
  var currentResult = Rxn<InterviewResult>();

  var flowState = InterviewFlowState.loading.obs;

  /// Timer
  Timer? _timer;

  // ===================== INIT =====================

  @override
  void onInit() {
    super.onInit();
    loadInterviews();
  }

  // ===================== LOAD =====================

  Future<void> loadInterviews() async {
    flowState.value = InterviewFlowState.loading;

    final result = await _service.getUserInterviews("user_1");

    interviews.assignAll(result);

    flowState.value = InterviewFlowState.ready;
  }

  // ===================== SELECT =====================

  void selectInterview(Interview interview) {
    selectedInterview.value = interview;
    checkInterviewState();
  }

  // ===================== FLOW LOGIC =====================

  void checkInterviewState() {
    final interview = selectedInterview.value;
    if (interview == null) return;

    final now = DateTime.now();

    if (now.isBefore(interview.joinOpenTime)) {
      flowState.value = InterviewFlowState.tooEarly;
    } else if (now.isBefore(interview.startTime)) {
      flowState.value = InterviewFlowState.waiting;
    } else if (now.isBefore(interview.endTime)) {
      flowState.value = InterviewFlowState.active;
    } else {
      flowState.value = InterviewFlowState.completed;
    }
  }

  // ===================== START =====================

  Future<void> startInterview() async {
    final interview = selectedInterview.value;
    if (interview == null) return;

    final session = await _service.startSession(
      interviewId: interview.id,
      userId: "user_1",
    );

    currentSession.value = session;

    flowState.value = InterviewFlowState.active;

    _startTimer();
  }

  // ===================== TIMER =====================

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final session = currentSession.value;
      if (session == null) return;

      if (session.secondsLeft <= 0) {
        submitInterview();
        return;
      }

      final updated = session.copyWith(
        secondsLeft: session.secondsLeft - 1,
        lastUpdatedAt: DateTime.now(),
      );

      currentSession.value = updated;

      _service.updateSession(updated);
    });
  }

  // ===================== ANSWER =====================

  void answerQuestion(String questionId, dynamic answer) {
    final session = currentSession.value;
    if (session == null) return;

    final updatedAnswers = Map<String, dynamic>.from(session.answers);
    updatedAnswers[questionId] = answer;

    final updated = session.copyWith(
      answers: updatedAnswers,
    );

    currentSession.value = updated;

    _service.updateSession(updated);
  }

  // ===================== NAVIGATION =====================

  void nextQuestion() {
    final session = currentSession.value;
    if (session == null) return;

    final updated = session.copyWith(
      currentQuestionIndex: session.currentQuestionIndex + 1,
    );

    currentSession.value = updated;
  }

  // ===================== SUBMIT =====================

  Future<void> submitInterview() async {
    _timer?.cancel();

    final session = currentSession.value;
    if (session == null) return;

    final result = await _service.submitInterview(session);

    currentResult.value = result;

    flowState.value = InterviewFlowState.completed;
  }

  // ===================== CLEANUP =====================

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}