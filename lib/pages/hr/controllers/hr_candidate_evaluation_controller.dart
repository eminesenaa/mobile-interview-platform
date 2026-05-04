import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  void generateAiMessage() {
    if (isAccepted.value == true) {
      messageController.text =
          "We are pleased to inform you that you have successfully passed the interview. Welcome aboard!";
    } else {
      messageController.text =
          "Thank you for your time. Unfortunately, we will not be moving forward with your application.";
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
