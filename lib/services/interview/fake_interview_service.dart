// ===================== File: lib/services/interview/fake_interview_service.dart =====================
// Purpose:
// FAKE implementation of InterviewService.
//
// ⚠️ THIS IS A TEMPORARY MOCK SERVICE FOR FRONTEND DEVELOPMENT ONLY.
//
// It simulates:
// - Interview fetching
// - Session creation
// - Answer submission
// - Result generation
//
// 🚨 IMPORTANT FOR BACKEND TEAM:
// This class MUST be replaced with a real implementation:
// → FirebaseInterviewService or API-based service
//
// Expected real behavior:
// - Fetch from Firestore / backend API
// - Persist sessions in real-time
// - Handle concurrency safely
// - Validate join codes
// - Secure user access
//
// ====================================================================================================

import 'dart:async';
import 'dart:math';

import '../../models/interview.dart';
import '../../models/interview_result.dart';
import '../../models/interview_session.dart';
import '../../models/question.dart';
import 'interview_service.dart';

class FakeInterviewService implements InterviewService {
  // ===================== FAKE STORAGE =====================

  final List<Interview> _interviews = [];
  final List<InterviewSession> _sessions = [];
  final List<InterviewResult> _results = [];

  // ===================== MOCK DATA =====================

  FakeInterviewService() {
    _seedMockData();
  }

  void _seedMockData() {
    final now = DateTime.now();

    _interviews.addAll([
      // ================= COMPLETED - NEEDS REVIEW =================
      Interview(
        id: "int_2",
        companyId: "comp_1",
        createdByHrId: "hr_1",
        title: "Backend Engineer Interview",
        position: "Node.js Developer",
        questions: _generateMockQuestions(),
        candidateIds: ["user_2", "user_3"],
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1, hours: 1)),
        joinCode: "XYZ789",
        status: InterviewStatus.completed,
        reviewStatus: ReviewStatus.pending,
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // ================= COMPLETED - REVIEWED =================
      Interview(
        id: "int_3",
        companyId: "comp_1",
        createdByHrId: "hr_1",
        title: "iOS Developer Interview",
        position: "Swift Developer",
        questions: _generateMockQuestions(),
        candidateIds: ["user_4"],
        startTime: now.subtract(const Duration(days: 2, hours: 3)),
        endTime: now.subtract(const Duration(days: 2, hours: 2)),
        joinCode: "IOS555",
        status: InterviewStatus.completed,
        reviewStatus: ReviewStatus.reviewed,
        createdAt: now.subtract(const Duration(days: 2)),
      ),

      // ================= ONGOING =================
      Interview(
        id: "int_4",
        companyId: "comp_1",
        createdByHrId: "hr_1",
        title: "Product Designer Interview",
        position: "UI/UX Designer",
        questions: _generateMockQuestions(),
        candidateIds: ["user_5", "user_6"],
        startTime: now.subtract(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 40)),
        joinCode: "DES123",
        status: InterviewStatus.active,
        reviewStatus: ReviewStatus.pending,
        createdAt: now,
      ),
    ]);
  }

  List<Question> _generateMockQuestions() {
    return List.generate(
      5,
      (index) => Question(
        id: "q_$index",
        title: "Sample Question $index",
        description: "This is a mock question",
        topic: "General",
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: [],
        type: QuestionType.mcq,
        options: ["A", "B", "C", "D"],
        correctAnswer: "0",
      ),
    );
  }

  // ===================== INTERVIEW =====================

  @override
  Future<List<Interview>> getUserInterviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _interviews.where((i) => i.candidateIds.contains(userId)).toList();
  }

  @override
  Future<Interview?> getInterviewById(String interviewId) async {
    return _interviews.firstWhere(
      (i) => i.id == interviewId,
      orElse: () => throw Exception("Interview not found"),
    );
  }

  // ===================== SESSION =====================

  @override
  Future<InterviewSession> startSession({
    required String interviewId,
    required String userId,
  }) async {
    final interview = await getInterviewById(interviewId);

    final session = InterviewSession(
      id: "session_${DateTime.now().millisecondsSinceEpoch}",
      interviewId: interviewId,
      candidateId: userId,
      secondsLeft: interview!.duration.inSeconds,
      isStarted: true,
      startedAt: DateTime.now(),
    );

    _sessions.add(session);

    return session;
  }

  @override
  Future<void> updateSession(InterviewSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    }
  }

  @override
  Future<InterviewSession?> getSession(
    String interviewId,
    String userId,
  ) async {
    return _sessions.firstWhere(
      (s) => s.interviewId == interviewId && s.candidateId == userId,
      orElse: () => throw Exception("Session not found"),
    );
  }

  // ===================== SUBMIT =====================

  @override
  Future<InterviewResult> submitInterview(
    InterviewSession session,
  ) async {
    final random = Random();

    final result = InterviewResult(
      id: "res_${DateTime.now().millisecondsSinceEpoch}",
      interviewId: session.interviewId,
      candidateId: session.candidateId,
      score: random.nextInt(100),
      correctCount: random.nextInt(10),
      wrongCount: random.nextInt(5),
      unansweredCount: random.nextInt(3),
      isSubmitted: true,
      submittedAt: DateTime.now(),
    );

    _results.add(result);

    return result;
  }

  @override
  Future<void> saveInterviewResult({
    required String interviewId,
    required String userId,
    required Map<String, dynamic> answers,
    required dynamic aiResult,
  }) async {
    print('FakeInterviewService: saving interview result for $interviewId');
    await Future.delayed(const Duration(seconds: 1));
  }

  // ===================== RESULTS =====================

  @override
  Future<List<InterviewResult>> getUserResults(String userId) async {
    return _results.where((r) => r.candidateId == userId).toList();
  }
}
