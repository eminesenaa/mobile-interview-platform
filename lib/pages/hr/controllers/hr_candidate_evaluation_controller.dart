import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/interview_result.dart';
import '../../../services/ai/ai_service.dart';
import '../interviews/needs_review/hr_candidate_evaluation_success_page.dart';

class HrCandidateEvaluationController extends GetxController {
  final Map<String, dynamic>? candidate;
  final isAccepted = RxnBool();

  RxnBool get decision => isAccepted;

  HrCandidateEvaluationController({this.candidate});

  // ===============================
  // HEADER DATA (DYNAMIC FROM ARGS)
  // ===============================

  final candidateName = "".obs;
  final interviewTitle = "".obs;
  final interviewDate = "".obs;
  final rank = 0.obs;
  final score = 0.obs;

  final messageController = TextEditingController();

  bool get isDecisionSelected => isAccepted.value != null;

  final messageText = "".obs;
  final isGeneratingMessage = false.obs;

  bool get canSubmit =>
      isDecisionSelected && messageText.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();

    if (candidate != null) {
      _initFromCandidate(candidate!);
    } else {
      _loadMockData();
    }

    messageController.addListener(() {
      messageText.value = messageController.text;
    });
  }

  // ===============================
  // ACTIONS
  // ===============================

  void _initFromCandidate(Map<String, dynamic> candidate) {
    candidateName.value = candidate["name"] ?? "Candidate";
    score.value = candidate["score"] ?? 0;

    /// 🔥 şimdilik mock (backend gelince değişecek)
    interviewTitle.value = "Frontend Developer Interview";
    interviewDate.value = "Apr 14";

    /// 🔥 rank hesap (sorted listten gelmeli aslında)
    rank.value = candidate["rank"] ?? 0;
  }

  void selectDecision(bool value) {
    isAccepted.value = value;
  }

  // ===============================================================
  // 🔥 AI MESSAGE GENERATION
  // ===============================================================

  void generateAiMessage() async {
    if (isAccepted.value == null) return;

    isGeneratingMessage.value = true;

    try {
      // TODO (Backend Teammate):
      // Fetch the real InterviewResult from database using candidateId / interviewId.
      // Example:
      //   final interviewResult = await interviewService.getInterviewResult(
      //     candidateId: candidate?["candidateId"],
      //     interviewId: candidate?["interviewId"],
      //   );
      //
      // For now, we build a minimal InterviewResult from the available candidate data.

      final interviewResult = InterviewResult(
        id: candidate?["id"] ?? "",
        interviewId: candidate?["interviewId"] ?? "",
        candidateId: candidate?["candidateId"] ?? "",
        score: score.value,
        correctCount: candidate?["correctCount"] ?? 0,
        wrongCount: candidate?["wrongCount"] ?? 0,
        unansweredCount: candidate?["unansweredCount"] ?? 0,
        aiResult: candidate?["aiResult"],
      );

      final message = await AiService().generateHrMessage(
        interviewResult: interviewResult,
        candidateName: candidateName.value,
        position: interviewTitle.value,
        isAccepted: isAccepted.value!,
      );

      messageController.text = message;
    } catch (e) {
      print('❌ [HR MESSAGE] Error in controller: $e');
      // Fallback to static messages
      if (isAccepted.value == true) {
        messageController.text =
            "We are pleased to inform you that you have successfully passed the interview. Welcome aboard!";
      } else {
        messageController.text =
            "Thank you for your time. Unfortunately, we will not be moving forward with your application.";
      }
    } finally {
      isGeneratingMessage.value = false;
    }
  }

  void submitEvaluation() {
    final decisionResult = isAccepted.value == true ? "accepted" : "rejected";

    Get.back(result: {
      "decision": decisionResult,
    });

    Get.to(
      () => HrCandidateEvaluationSuccessPage(
        candidateName: candidateName.value,
        interview: candidate?["interview"],
      ),
    );
  }

  void _loadMockData() {
    candidateName.value = "John Doe";
    interviewTitle.value = "Frontend Developer Interview";
    interviewDate.value = "Apr 14";
    rank.value = 2;
    score.value = 91;
  }
}
