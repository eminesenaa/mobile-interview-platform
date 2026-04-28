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

import '../../../models/job_application.dart';
import '../../../models/job_posting.dart';


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
  // SEARCH
  // ===============================
  final searchQuery = "".obs;

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


  // ===============================
  // JOB POSTINGS (MOCK)
  // ===============================
  /// TODO (Backend):
  /// - Fetch from Firestore
  /// - Include applications relation
  final jobPostings = <JobPosting>[].obs;

  // ===============================
  // APPLICATIONS (MOCK)
  // ===============================
  /// TODO (Backend):
  /// - Fetch applications by postingId
  final applications = <JobApplication>[].obs;

  // ===============================
  // SELECTED JOB POSTING
  // ===============================
  /// Selected posting from previous page
  /// Passed via Get.arguments
  final selectedPosting = Rxn<JobPosting>();

  @override
  void onInit() {
    super.onInit();

    // ===============================
    // AUTO GENERATE INVITE CODE
    // ===============================
    generateInviteCode();

    // ===============================
    // RECEIVE SELECTED POSTING
    // ===============================
    if (Get.arguments != null && Get.arguments is JobPosting) {
      selectedPosting.value = Get.arguments as JobPosting;

      // Auto-fill position
      positionCtrl.text = selectedPosting.value!.title;

      // Optional: title auto-fill
      titleCtrl.text = "${selectedPosting.value!.title} Interview";
    }

    // ===============================
    // AUTO LOAD ACCEPTED CANDIDATES
    // ===============================
    /// TODO (Backend):
    /// - Fetch accepted candidates from JobPosting
    /// - Replace candidateId list with full User objects
    _loadAcceptedCandidates();

    // ===============================
    // MOCK JOB POSTINGS
    // ===============================
    jobPostings.value = [
      JobPosting(
        id: "1",
        companyId: "c1",
        createdByHrId: "hr1",
        title: "Frontend Developer",
        level: JobLevel.senior,
        workType: WorkType.remote,
        country: "Turkey",
        city: "Istanbul",
        description: "",
        requirements: "",
        status: JobPostingStatus.closed,
        applicationIds: ["a1", "a2", "a3"],
        acceptedCandidateIds: ["a1", "a2", "a3"],
        createdAt: DateTime.now(),
      ),
      JobPosting(
        id: "2",
        companyId: "c1",
        createdByHrId: "hr1",
        title: "Backend Engineer",
        level: JobLevel.mid,
        workType: WorkType.hybrid,
        country: "Germany",
        city: "Berlin",
        description: "",
        requirements: "",
        status: JobPostingStatus.closed,
        applicationIds: ["a4", "a5"],
        acceptedCandidateIds: ["a4", "a5"],
        createdAt: DateTime.now(),
      ),
    ];
    // ===============================
// MOCK APPLICATIONS
// ===============================
    applications.value = [
      JobApplication(
        id: "a1",
        jobPostingId: "1",
        candidateId: "u1",
        appliedAt: DateTime.now(),
        status: ApplicationStatus.accepted,
      ),
      JobApplication(
        id: "a2",
        jobPostingId: "1",
        candidateId: "u2",
        appliedAt: DateTime.now(),
        status: ApplicationStatus.accepted,
      ),
      JobApplication(
        id: "a3",
        jobPostingId: "1",
        candidateId: "u3",
        appliedAt: DateTime.now(),
        status: ApplicationStatus.accepted,
      ),
      JobApplication(
        id: "a4",
        jobPostingId: "2",
        candidateId: "u4",
        appliedAt: DateTime.now(),
        status: ApplicationStatus.accepted,
      ),
      JobApplication(
        id: "a5",
        jobPostingId: "2",
        candidateId: "u5",
        appliedAt: DateTime.now(),
        status: ApplicationStatus.accepted,
      ),
    ];
  }

  // ===============================
  // READY POSTINGS
  // ===============================
  List<JobPosting> get readyPostings {
    return jobPostings.where((p) => p.isReady).toList();
  }

  // SEARCH
  List<JobPosting> get filteredPostings {
    final query = searchQuery.value.toLowerCase();

    return readyPostings.where((p) {
      return p.title.toLowerCase().contains(query);
    }).toList();
  }
  void setSearchQuery(String value) {
    searchQuery.value = value;
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
  // LOAD ACCEPTED CANDIDATES
  // ===============================
  void _loadAcceptedCandidates() {
    if (selectedPosting.value == null) return;

    final postingId = selectedPosting.value!.id;

    final acceptedApps = applications.where((a) =>
    a.jobPostingId == postingId &&
        a.status == ApplicationStatus.accepted);

    // For now: just use candidateId as placeholder
    selectedCandidates.value =
        acceptedApps.map((a) => a.candidateId).toList();

    /// TODO (Backend):
    /// - Replace candidateId with full User model
    /// - Example:
    /// selectedCandidates.value = acceptedUsers;
  }

  // ===============================
  // RESET STATE (OPTIONAL)
  // ===============================
  void clearSelectedPosting() {
    selectedPosting.value = null;
    selectedCandidates.clear();
  }

  // ===============================
  // STATS HELPERS
  // ===============================

  int getApplicantsCount(String postingId) {
    return applications
        .where((a) => a.jobPostingId == postingId)
        .length;
  }

  int getAcceptedCount(String postingId) {
    return applications
        .where((a) =>
    a.jobPostingId == postingId &&
        a.status == ApplicationStatus.accepted)
        .length;
  }

  int getRejectedCount(String postingId) {
    return applications
        .where((a) =>
    a.jobPostingId == postingId &&
        a.status == ApplicationStatus.rejected)
        .length;
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
