// ===================== File: lib/services/interview/interview_service.dart =====================
// Purpose:
// Abstract service layer for Interview system.
//
// This defines the CONTRACT for all interview-related operations.
// The UI and Controllers MUST depend on this, NOT on concrete implementations.
//
// Current implementation: FakeInterviewService (for frontend development)
// Future implementation: FirebaseInterviewService (real backend)
//
// ⚠️ IMPORTANT:
// Backend developer will replace fake implementation with real API/Firebase logic.
// =================================================================================================

import '../../models/interview.dart';
import '../../models/interview_result.dart';
import '../../models/interview_session.dart';

abstract class InterviewService {
  // ===================== INTERVIEW =====================

  /// Get all interviews assigned to a candidate
  Future<List<Interview>> getUserInterviews(String userId);

  /// Get single interview by ID
  Future<Interview?> getInterviewById(String interviewId);

  // ===================== SESSION =====================

  /// Start interview session
  Future<InterviewSession> startSession({
    required String interviewId,
    required String userId,
  });

  /// Update session (answers, timer, etc.)
  Future<void> updateSession(InterviewSession session);

  /// Get existing session (resume support)
  Future<InterviewSession?> getSession(
      String interviewId,
      String userId,
      );

  // ===================== SUBMIT =====================

  /// Submit interview → creates InterviewResult
  Future<InterviewResult> submitInterview(
      InterviewSession session,
      );

  /// Submit interview → creates InterviewResult
  Future<void> saveInterviewResult({
    required String interviewId,
    required String userId,
    required Map<String, dynamic> answers,
    required dynamic aiResult,
  });

  // ===================== RESULTS =====================

  /// Get widgets for candidate
  Future<List<InterviewResult>> getUserResults(String userId);
}