// ===================== File: hr_job_postings_controller.dart =====================
// Purpose:
// Controls job postings (Applications system) using real Firestore data.
// ===============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/user.dart';
import '../job_postings/candidate_application_detail_page.dart';
import '../job_postings/job_posting_applicants_page.dart';
import '../job_postings/job_posting_create_page.dart';
import '../job_postings/job_posting_detail_page.dart';

class HrJobPostingsController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ===============================
  // STATE
  // ===============================

  /// active / closed
  final selectedTab = "active".obs;

  /// postings lists
  final activePostings = <Map<String, dynamic>>[].obs;
  final closedPostings = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // ===============================
  // CREATE POSTING FORM STATE
  // ===============================

  final jobTitle = "".obs;
  final jobLevel = "".obs;
  final workType = "".obs;
  final country = "".obs;
  final city = "".obs;
  final salary = "".obs; 
  final description = "".obs;
  final requirements = "".obs;

  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();
    _listenToPostings();
  }

  // ===============================
  // REAL-TIME POSTINGS
  // ===============================
  void _listenToPostings() {
    isLoading.value = true;
    _db.collection('job_postings').snapshots().listen((snap) {
      final all = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      activePostings.value = all.where((p) => p['status'] == 'active').toList();
      closedPostings.value = all.where((p) => p['status'] == 'closed').toList();
      isLoading.value = false;
    });
  }

  // ===============================
  // TAB CHANGE
  // ===============================
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  // ===============================
  // NAVIGATION
  // ===============================

  void openPosting(Map<String, dynamic> posting) {
    Get.to(() => JobPostingDetailPage(posting: posting));
  }

  void createPosting() {
    Get.to(() => const JobPostingCreatePage());
  }

  void openApplicants(Map<String, dynamic> posting) {
    Get.to(() => JobPostingApplicantsPage(posting: posting));
  }

  void openCandidateDetail(String postingId, String userId) async {
    final posting = getPostingById(postingId);
    if (posting == null) return;

    final applicants = List<Map<String, dynamic>>.from(posting['applicants'] ?? []);
    final applicant = applicants.firstWhereOrNull((a) => a['userId'] == userId);
    
    if (applicant != null) {
      Get.to(() => CandidateApplicationDetailPage(
        application: {
          ...applicant,
          'postingId': postingId,
          'id': userId, // For consistency
        },
      ));
    }
  }

  // ===============================
  // ACTIONS
  // ===============================

  Future<void> submitPosting() async {
    if (!isFormValid) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    try {
      final newPosting = {
        "title": jobTitle.value,
        "level": jobLevel.value,
        "location": "${city.value}, ${country.value}",
        "workType": workType.value,
        "salary": salary.value,
        "description": description.value,
        "requirements": requirements.value.split('\n').where((s) => s.isNotEmpty).toList(),
        "status": "active",
        "createdAt": FieldValue.serverTimestamp(),
        "applicants": [],
        "applicantCount": 0,
        "accepted": 0,
        "rejected": 0,
        "pending": 0,
      };

      await _db.collection('job_postings').add(newPosting);

      resetForm();
      Get.back();
      Get.snackbar("Success", "Job posting published");
    } catch (e) {
      Get.snackbar("Error", "Failed to create posting: $e");
    }
  }

  Future<void> closePosting(String id) async {
    try {
      await _db.collection('job_postings').doc(id).update({"status": "closed"});
      Get.snackbar("Success", "Posting closed");
    } catch (e) {
      Get.snackbar("Error", "Failed to close posting: $e");
    }
  }

  Future<void> finalizePosting(String id) => closePosting(id);

  void resetForm() {
    jobTitle.value = "";
    jobLevel.value = "";
    workType.value = "";
    country.value = "";
    city.value = "";
    salary.value = "";
    description.value = "";
    requirements.value = "";
  }

  bool get isFormValid =>
      jobTitle.isNotEmpty &&
      jobLevel.isNotEmpty &&
      workType.isNotEmpty &&
      country.isNotEmpty &&
      city.isNotEmpty &&
      description.isNotEmpty &&
      requirements.isNotEmpty;

  Map<String, dynamic>? getPostingById(String id) {
    try {
      return [...activePostings, ...closedPostings].firstWhere((p) => p["id"] == id);
    } catch (e) {
      return null;
    }
  }

  // ===============================
  // APPLICANT MANAGEMENT
  // ===============================

  String getApplicantStatus(String postingId, String userId) {
    final posting = getPostingById(postingId);
    if (posting == null) return 'pending';

    final applicants = List<dynamic>.from(posting['applicants'] ?? []);
    final applicant = applicants.firstWhereOrNull((a) => a['userId'] == userId);
    
    return applicant?['status'] ?? 'pending';
  }

  List<Map<String, dynamic>> searchApplicants(List<dynamic> applicants, String query) {
    if (query.isEmpty) return List<Map<String, dynamic>>.from(applicants);
    return applicants
        .where((a) => a['name'].toString().toLowerCase().contains(query.toLowerCase()))
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
  }

  void updateApplicantStatus(String postingId, String userId, String status) async {
    try {
      final postingRef = _db.collection('job_postings').doc(postingId);
      final doc = await postingRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final applicants = List<Map<String, dynamic>>.from(data['applicants'] ?? []);
      
      final idx = applicants.indexWhere((a) => a['userId'] == userId);
      if (idx == -1) return;

      final oldStatus = applicants[idx]['status'];
      applicants[idx]['status'] = status;

      // Update counters
      int accepted = data['accepted'] ?? 0;
      int rejected = data['rejected'] ?? 0;
      int pending = data['pending'] ?? 0;

      if (oldStatus == 'pending') pending--;
      else if (oldStatus == 'accepted') accepted--;
      else if (oldStatus == 'rejected') rejected--;

      if (status == 'pending') pending++;
      else if (status == 'accepted') accepted++;
      else if (status == 'rejected') rejected++;

      await postingRef.update({
        'applicants': applicants,
        'accepted': accepted,
        'rejected': rejected,
        'pending': pending,
      });

      Get.snackbar("Success", "Status updated to $status");
    } catch (e) {
      Get.snackbar("Error", "Failed to update status: $e");
    }
  }
}
