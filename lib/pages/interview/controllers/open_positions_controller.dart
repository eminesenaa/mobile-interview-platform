// ===================== File: open_positions_controller.dart =====================
// Purpose:
// Controls Open Positions (Browse All) page using real Firestore data.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/job_application.dart';
import '../../../services/interview/job_application_service.dart';

class OpenPositionsController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _applicationService = Get.find<JobApplicationService>();

  // ===============================
  // STATE
  // ===============================

  /// All jobs (raw)
  final jobs = <Map<String, dynamic>>[].obs;

  /// Filtered jobs (UI uses this)
  final filteredJobs = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;

  // ===============================
  // SEARCH & FILTER STATE
  // ===============================

  final searchQuery = "".obs;
  final selectedFilter = "All Roles".obs;

  // ===============================
  // APPLY FORM STATE
  // ===============================

  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final universityCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final portfolioCtrl = TextEditingController();
  final githubCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final skillCtrl = TextEditingController();
  final skills = <String>[].obs;
  final selectedResume = Rxn<String>();

  // ===============================
  // SELECTED JOB (DETAIL PAGE)
  // ===============================

  final selectedJob = Rxn<Map<String, dynamic>>();

  // ===============================
  // FILTER OPTIONS
  // ===============================

  final filters = [
    "All Roles",
    "Remote",
    "Senior",
    "Mid-Level",
    "Intern",
  ];

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      selectedJob.value = Get.arguments;
    }
    _listenToJobs();
  }

  // ===============================
  // REAL-TIME JOBS
  // ===============================
  void _listenToJobs() {
    isLoading.value = true;
    _db.collection('job_postings')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snap) {
          jobs.value = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          applyFilters();
          isLoading.value = false;
        });
  }

  // ===============================
  // ACTIONS
  // ===============================

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value.toLowerCase();
    final filter = selectedFilter.value;

    filteredJobs.value = jobs.where((job) {
      final title = (job["title"] ?? "").toString().toLowerCase();
      final level = job["level"];
      final workType = job["workType"];

      final matchesSearch = title.contains(query);
      bool matchesFilter = true;

      if (filter != "All Roles") {
        if (filter == "Remote") {
          matchesFilter = workType == "Remote";
        } else {
          matchesFilter = level == filter;
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void addSkill() {
    final skill = skillCtrl.text.trim();
    if (skill.isEmpty) return;
    skills.add(skill);
    skillCtrl.clear();
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  void pickResume() {
    selectedResume.value = "resume_${DateTime.now().millisecondsSinceEpoch}.pdf";
  }

  void applyToJob(Map<String, dynamic> job) {
    setSelectedJob(job);
  }

  void setSelectedJob(Map<String, dynamic> job) {
    selectedJob.value = job;
  }

  // ===============================
  // SUBMIT APPLICATION (BACKEND)
  // ===============================

  Future<void> submitApplication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You must be logged in to apply");
      return;
    }

    final jobId = selectedJob.value?["id"];
    if (jobId == null) return;

    isLoading.value = true;

    try {
      final application = JobApplication(
        id: "", // Service will generate
        jobPostingId: jobId,
        candidateId: user.uid,
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
        candidateName: user.displayName ?? "Anonymous",
        jobTitle: selectedJob.value?["title"] ?? "Unknown Position",
        skills: skills.toList(),
        githubUrl: githubCtrl.text,
        linkedinUrl: linkedinCtrl.text,
        portfolioUrl: portfolioCtrl.text,
        resumeUrl: selectedResume.value,
      );

      await _applicationService.submitApplication(application);

      Get.back(); // Back from apply page
      Get.back(); // Back from job detail
      
      Get.snackbar(
        "Success", 
        "Your application has been submitted!",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to submit application: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    universityCtrl.dispose();
    departmentCtrl.dispose();
    portfolioCtrl.dispose();
    githubCtrl.dispose();
    linkedinCtrl.dispose();
    skillCtrl.dispose();
    super.onClose();
  }
}
