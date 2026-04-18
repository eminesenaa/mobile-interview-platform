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

import 'package:wheel_picker/wheel_picker.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

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

  final selectedStartTime = Rxn<TimeOfDay>();
  final selectedEndTime = Rxn<TimeOfDay>();


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

  void pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) selectedStartTime.value = picked;
  }

  void pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) selectedEndTime.value = picked;
  }

  // ===============================
  // SET START TIME
  // ===============================
  void setStartTime(TimeOfDay time) {
    selectedStartTime.value = time;
  }

  // ===============================
  // SET END TIME
  // ===============================
  void setEndTime(TimeOfDay time) {
    selectedEndTime.value = time;
  }

  // ===============================
  // AUTO DURATION (READ ONLY)
  // ===============================
  int get durationInMinutes {
    if (selectedStartTime.value == null || selectedEndTime.value == null) {
      return 0;
    }

    final start = selectedStartTime.value!;
    final end = selectedEndTime.value!;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return endMinutes - startMinutes;
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
      Iterable.generate(
          4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
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
  // CREATE INTERVIEW
  // ===============================
  void createInterview() {
    if (titleCtrl.text.isEmpty ||
        positionCtrl.text.isEmpty ||
        selectedDate.value == null ||
        selectedStartTime.value == null ||
        selectedEndTime.value == null ||
        inviteCode.value == "—") {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    // ===============================
    // BUILD DATETIME OBJECTS
    // ===============================
    final startDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    final endDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      selectedEndTime.value!.hour,
      selectedEndTime.value!.minute,
    );

    // ===============================
    // VALIDATE TIME RANGE
    // ===============================
    if (endDateTime.isBefore(startDateTime)) {
      Get.snackbar("Error", "End time must be after start time");
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
