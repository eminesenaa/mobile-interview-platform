// ===================== File: create_interview_controller.dart =====================
// Purpose:
// Handles state & logic for Create Interview
//
// IMPORTANT:
// - Backend-ready
// - UI bağımsız
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class CreateInterviewController extends GetxController {
  // ===============================
  // TEXT FIELDS
  // ===============================
  final titleCtrl = TextEditingController();
  final positionCtrl = TextEditingController();

  // ===============================
  // DATE & TIME
  // ===============================
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  // ===============================
  // DURATION (NEW - iOS PICKER)
  // ===============================
  final selectedDuration = 45.obs; // dakika

  // ===============================
  // INVITE CODE
  // ===============================
  final inviteCode = "—".obs;

  // ===============================
  // QUESTION MODE
  // ===============================
  final isManual = false.obs;

  // ===============================
  // MOCK CANDIDATES
  // ===============================
  final selectedCandidates = <String>[].obs;

  // ===============================
  // ALL CANDIDATES (MOCK DATA)
  // ===============================
  /// TODO (Backend):
  /// - Replace with Firestore users collection
  /// - Should return List<User> instead of String
  final allCandidates = <String>[
    "James Anderson",
    "Sophie Miller",
    "Benjamin Clark",
    "Elena Richardson",
    "Oliver Bennett",
  ].obs;

  @override
  void onInit() {
    super.onInit();

    // ===============================
    // AUTO GENERATE INVITE CODE
    // ===============================
    generateInviteCode();
  }


  // ===============================
  // ACTIONS
  // ===============================
  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) selectedDate.value = picked;
  }

  void pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) selectedTime.value = picked;
  }

  // ===============================
  // GENERATE UNIQUE INVITE CODE
  // ===============================
  /// Generates a random invite code like: FE-29A7
  /// Called once when page opens
  ///
  /// TODO (Backend):
  /// - Ensure uniqueness (check Firestore)
  /// - Store under interview document
  void generateInviteCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final random = Random();

    final part1 = String.fromCharCodes(
      Iterable.generate(2, (_) => chars.codeUnitAt(random.nextInt(26))),
    );

    final part2 = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    inviteCode.value = "$part1-$part2";
  }

  void toggleManual(bool value) {
    isManual.value = value;
  }

  void addCandidate(String name) {
    selectedCandidates.add(name);
  }

  void removeCandidate(String name) {
    selectedCandidates.remove(name);
  }


  // ===============================
  // SET DURATION
  // ===============================
  void setDuration(int minutes) {
    selectedDuration.value = minutes;
  }

  // ===============================
  // CREATE INTERVIEW
  // ===============================
  void createInterview() {
    if (titleCtrl.text.isEmpty ||
        positionCtrl.text.isEmpty ||
        selectedDate.value == null ||
        selectedTime.value == null ||
        selectedDuration.value <= 0 ||
        inviteCode.value == "—") {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    // TODO: Backend integration
    /*
    await api.createInterview(...)
    */

    Get.snackbar("Success", "Interview created (mock)");
    Get.back();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    positionCtrl.dispose();
    super.onClose();
  }
}
