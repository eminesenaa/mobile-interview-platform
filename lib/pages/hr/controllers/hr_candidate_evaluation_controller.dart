// ===================== File: hr_candidate_evaluation_controller.dart =====================
// Purpose:
// Controls HR Candidate Evaluation Page using real data.
// ================================================================================

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

  final candidateName = "".obs;
  final interviewTitle = "".obs;
  final interviewDate = "".obs;
  final rank = 0.obs;
  final score = 0.obs;

  final messageController = TextEditingController();
  final messageText = "".obs;
  final isGeneratingMessage = false.obs;

  bool get isDecisionSelected => isAccepted.value != null;
  bool get canSubmit => isDecisionSelected && messageText.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();

    if (candidate != null) {
      _initFromCandidate(candidate!);
    }

    messageController.addListener(() {
      messageText.value = messageController.text;
    });
  }

  void _initFromCandidate(Map<String, dynamic> data) {
    candidateName.value = data["name"] ?? "Candidate";
    score.value = (data["score"] ?? 0).toInt();
    interviewTitle.value = data["interviewTitle"] ?? "Interview Result";
    interviewDate.value = data["interviewDate"] ?? "";
    rank.value = data["rank"] ?? 0;
  }

  void selectDecision(bool value) {
    isAccepted.value = value;
  }

  Future<void> generateAiMessage() async {
    if (isAccepted.value == null) return;

    isGeneratingMessage.value = true;

    try {
      final interviewResult = InterviewResult(
        id: candidate?["resultId"] ?? "",
        interviewId: candidate?["interviewId"] ?? "",
        candidateId: candidate?["candidateId"] ?? "",
        score: score.value,
        correctCount: (candidate?["correct"] ?? 0).toInt(),
        wrongCount: (candidate?["wrong"] ?? 0).toInt(),
        unansweredCount: (candidate?["unanswered"] ?? 0).toInt(),
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
      if (isAccepted.value == true) {
        messageController.text = "Congratulations! You passed the interview.";
      } else {
        messageController.text = "Thank you for your time. Unfortunately, we are not moving forward.";
      }
    } finally {
      isGeneratingMessage.value = false;
    }
  }

  void submitEvaluation() {
    final decisionResult = isAccepted.value == true ? "accepted" : "rejected";

    Navigator.of(Get.context!).pop({
      "decision": decisionResult,
      "message": messageController.text,
    });

    Get.to(() => HrCandidateEvaluationSuccessPage(
      candidateName: candidateName.value,
      interview: candidate?["interview"] ?? {},
    ));
  }
}
