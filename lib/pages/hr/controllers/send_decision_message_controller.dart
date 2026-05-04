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

enum DecisionType { accept, reject }

class SendDecisionMessageController extends GetxController {
  // =========================
  // INPUT (FROM PREVIOUS PAGE)
  // =========================
  final DecisionType decision;
  final Map<String, dynamic> application;
  final RxString messageText = ''.obs;


  SendDecisionMessageController({
    required this.decision,
    required this.application,
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

  // UI helper (for title etc.)
  String get decisionLabel {
    return decision == DecisionType.accept ? "Accepted" : "Rejected";
  }

  // =========================
  // AI GENERATION (STUB)
  // =========================
  void generateAiMessage() {
    // 🔥 simple mock (backend gelince değişecek)
    if (decision == DecisionType.accept) {
      messageController.text =
          "Congratulations! We are pleased to inform you that you have successfully passed the interview process.";
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

      // =========================
      // TODO: BACKEND INTEGRATION
      // =========================
      /*
      await api.sendDecision(
        decision: decision,
        message: message,
      );
      */

      // 🔥 mock delay
      await Future.delayed(const Duration(milliseconds: 600));

      // =========================
      // SUCCESS
      // =========================
      Get.back(result: {
        "decision": decision,
        "message": message,
      });

      Get.snackbar(
        "Success",
        "Decision sent successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send decision",
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
