// ===================== File: send_decision_message_controller.dart =====================
// Purpose:
// Handles HR decision message flow (after Accept / Reject)
//
// Features:
// - Stores decision (accept / reject)
// - Manages message input
// - AI message generation (stub for now)
// - Submit action (backend-ready)
//
// IMPORTANT:
// - This is a lightweight controller
// - Does NOT duplicate evaluation logic
// - Receives decision from previous page
//
// TODO (Backend):
// - Send decision + message to API
// - Trigger notification to candidate
// - Integrate real AI service
// ======================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hr_job_postings_controller.dart';

enum DecisionType { accept, reject }

class SendDecisionMessageController extends GetxController {
  // =========================
  // INPUT (FROM PREVIOUS PAGE)
  // =========================
  final DecisionType decision;
  final Map<String, dynamic> application;
  final String? postingId; // 🔥 Added postingId
  final RxString messageText = ''.obs;

  SendDecisionMessageController({
    required this.decision,
    required this.application,
    this.postingId,
  });

  @override
  void onInit() {
    super.onInit();

    messageController.addListener(() {
      messageText.value = messageController.text;
    });
  }


  // =========================
  // STATE
  // =========================

  // Message input controller
  final TextEditingController messageController = TextEditingController();

  // Loading state (submit / AI)
  final RxBool isLoading = false.obs;

  // =========================
  // COMPUTED
  // =========================

  // Can submit only if message is not empty
  bool get canSubmit => messageText.value.trim().isNotEmpty;

  // =========================
  // AI GENERATION (STUB)
  // =========================
  void generateAiMessage() {
    // 🔥 simple mock (backend gelince değişecek)
    if (decision == DecisionType.accept) {
      messageController.text =
          "We are happy to invite you to the interview stage of our hiring process.";
    } else {
      messageController.text =
          "Thank you for your interest. Unfortunately, we will not be moving forward with your application at this time.";
    }
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> submit() async {
    if (!canSubmit) return;

    try {
      isLoading.value = true;
      final message = messageController.text.trim();
      final userId = application["userId"];
      final pId = postingId ?? application["jobPostingId"];

      if (userId == null || pId == null) {
        throw "Missing user or posting ID";
      }

      // 🔥 1. Update status using HrJobPostingsController
      final hrController = Get.find<HrJobPostingsController>();
      final status = decision == DecisionType.accept ? "accepted" : "rejected";
      
      await hrController.updateApplicantStatusWithFeedback(
        pId, 
        userId, 
        status, 
        message
      );

      // =========================
      // SUCCESS
      // =========================
      Navigator.of(Get.context!).pop(true);

      Get.snackbar(
        "Success",
        "Decision sent successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send decision: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CLEANUP
  // =========================
  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
