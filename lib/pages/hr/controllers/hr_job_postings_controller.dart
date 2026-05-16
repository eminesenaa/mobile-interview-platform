// ===================== File: hr_job_postings_controller.dart =====================
// Purpose:
// Controls job postings (Applications system) using real Firestore data.
// ===============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:interview_project/models/user.dart';
import '../job_postings/candidate_application_detail_page.dart';
import '../job_postings/job_posting_applicants_page.dart';
import '../job_postings/job_posting_create_page.dart';
import '../job_postings/job_posting_detail_page.dart';
import '../../../constants/constants.dart';

class HrJobPostingsController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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

      // 🔥 Sort by createdAt descending (latest on top)
      all.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      activePostings.value = all.where((p) => p['status'] == 'active').toList();
      closedPostings.value = all.where((p) => p['status'] == 'closed' || p['status'] == 'finalized').toList();
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
      isLoading.value = true;
      try {
        // 1. Fetch latest Application document
        final appSnap = await _db.collection("applications")
            .where("candidateId", isEqualTo: userId)
            .where("jobPostingId", isEqualTo: postingId)
            .limit(1)
            .get();

        Map<String, dynamic> mergedData = Map<String, dynamic>.from(applicant);
        
        if (appSnap.docs.isNotEmpty) {
          mergedData.addAll(appSnap.docs.first.data());
        }

        // 2. Fetch latest User profile for core identity info
        final userDoc = await _db.collection("users").doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          
          // Identity merges (Users collection is the source of truth for these)
          final fName = userData['name'] ?? "";
          final lName = userData['surname'] ?? "";
          final fullName = "$fName $lName".trim();
          mergedData['name'] = fullName.isNotEmpty ? fullName : (userData['displayName'] ?? mergedData['name']);
          
          mergedData['email'] = userData['email'] ?? mergedData['email'];
          mergedData['phone'] = userData['phoneNumber'] ?? mergedData['phone'];
          mergedData['location'] = userData['location'] ?? mergedData['location'];
          
          // Education
          mergedData['university'] = userData['school'] ?? userData['university'] ?? mergedData['university'];
          mergedData['department'] = userData['department'] ?? mergedData['department'];
          
          // Links
          mergedData['githubUrl'] = userData['githubUrl'] ?? mergedData['githubUrl'];
          mergedData['linkedinUrl'] = userData['linkedinUrl'] ?? mergedData['linkedinUrl'];
          mergedData['portfolioUrl'] = userData['website'] ?? mergedData['portfolioUrl'];
        }

        Get.to(() => CandidateApplicationDetailPage(
          application: {
            ...mergedData,
            'position': posting['title'] ?? 'Unknown Position',
            'postingId': postingId,
            'id': userId,
          },
        ));
      } catch (e) {
        print("Error fetching candidate detail: $e");
      } finally {
        isLoading.value = false;
      }
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
      final user = _auth.currentUser;
      if (user == null) throw "User not logged in";

      final newPosting = {
        "title": jobTitle.value,
        "level": jobLevel.value,
        "location": "${city.value}, ${country.value}",
        "workType": workType.value,
        "salary": salary.value,
        "description": description.value,
        "requirements": requirements.value.split('\n').where((s) => s.isNotEmpty).toList(),
        "status": "active",
        "createdByHrId": user.uid,
        "companyId": user.uid, // HR is company owner for now
        "createdAt": FieldValue.serverTimestamp(),
        "applicants": [],
        "applicantCount": 0,
        "accepted": 0,
        "rejected": 0,
        "pending": 0,
        "acceptedCandidateIds": [],
      };

      await _db.collection('job_postings').add(newPosting);

      resetForm();
      
      // 🔥 Safer navigation
      if (Get.isOverlaysOpen) {
        Navigator.of(Get.overlayContext!).pop();
      }
      Navigator.of(Get.context!).pop();

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar("Success", "Job posting published", snackPosition: SnackPosition.BOTTOM);
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to create posting: $e");
    }
  }

  Future<bool> closePosting(String id) async {
    try {
      await _db.collection('job_postings').doc(id).update({"status": "closed"});
      
      if (Get.context != null) {
        Get.snackbar(
          "Success", 
          "Posting closed", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
      }
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to close posting: $e");
      return false;
    }
  }

  Future<bool> finalizePosting(String id) async {
    try {
      await _db.collection('job_postings').doc(id).update({"status": "finalized"});
      
      if (Get.context != null) {
        Get.snackbar(
          "Success", 
          "Evaluation finalized", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
        );
      }
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to finalize: $e");
      return false;
    }
  }

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

      // Update the status in the array
      applicants[idx]['status'] = status;

      // 🔥 Recalculate counters and accepted IDs
      final acceptedList = applicants.where((a) => a['status'] == 'accepted').toList();
      int accepted = acceptedList.length;
      int rejected = applicants.where((a) => a['status'] == 'rejected').length;
      int pending = applicants.where((a) => a['status'] == 'pending').length;
      int total = applicants.length;
      
      final acceptedIds = acceptedList.map((a) => (a['userId'] ?? '').toString()).toList();

      await postingRef.update({
        'applicants': applicants,
        'accepted': accepted,
        'rejected': rejected,
        'pending': pending,
        'applicantCount': total,
        'acceptedCandidateIds': acceptedIds,
      });

      // 🔥 2. Update the actual Application document in 'applications' collection
      final appSnap = await _db.collection('applications')
          .where('candidateId', isEqualTo: userId)
          .where('jobPostingId', isEqualTo: postingId)
          .limit(1)
          .get();
      
      if (appSnap.docs.isNotEmpty) {
        await appSnap.docs.first.reference.update({
          'status': status,
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      }

      Get.snackbar("Success", "Status updated to $status");
    } catch (e) {
      Get.snackbar("Error", "Failed to update status: $e");
    }
  }
  Future<void> updateApplicantStatusWithFeedback(String postingId, String userId, String status, String message) async {
    try {
      final postingRef = _db.collection('job_postings').doc(postingId);
      final doc = await postingRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final applicants = List<Map<String, dynamic>>.from(data['applicants'] ?? []);
      
      final idx = applicants.indexWhere((a) => a['userId'] == userId);
      if (idx == -1) return;

      // Update the status in the array
      applicants[idx]['status'] = status;

      // 🔥 Recalculate counters
      final acceptedList = applicants.where((a) => a['status'] == 'accepted').toList();
      int accepted = acceptedList.length;
      int rejected = applicants.where((a) => a['status'] == 'rejected').length;
      int pending = applicants.where((a) => a['status'] == 'pending').length;
      int total = applicants.length;
      
      final acceptedIds = acceptedList.map((a) => (a['userId'] ?? '').toString()).toList();

      await postingRef.update({
        'applicants': applicants,
        'accepted': accepted,
        'rejected': rejected,
        'pending': pending,
        'applicantCount': total,
        'acceptedCandidateIds': acceptedIds,
      });

      // 🔥 2. Update the actual Application document in 'applications' collection
      final appSnap = await _db.collection('applications')
          .where('candidateId', isEqualTo: userId)
          .where('jobPostingId', isEqualTo: postingId)
          .limit(1)
          .get();
      
      if (appSnap.docs.isNotEmpty) {
        final Map<String, dynamic> updateData = {
          'status': status,
          'hrMessage': message,
          'reviewedAt': FieldValue.serverTimestamp(),
        };

        // 🔥 3. If accepted, generate a unique interview code
        if (status == 'accepted') {
          final inviteCode = _generateUniqueCode();
          updateData['inviteCode'] = inviteCode;
        }

        await appSnap.docs.first.reference.update(updateData);
      }
    } catch (e) {
      print("Error updating status with feedback: $e");
      rethrow;
    }
  }

  String _generateUniqueCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ234567890';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
