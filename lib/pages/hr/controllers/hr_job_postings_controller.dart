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
    final user = _auth.currentUser;
    if (user == null) return;
    
    isLoading.value = true;
    _db.collection('job_postings')
       .where('createdByHrId', isEqualTo: user.uid)
       .snapshots()
       .listen((snap) {
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

      // 🔥 BACKGROUND SYNC: Fix "Anonymous" names automatically
      _autoFixAnonymousNames(all);
      // 🔥 BACKGROUND SYNC: Fix "Unknown Company" postings
      _autoFixUnknownCompany(all);
    });
  }

  /// Finds any candidate marked as "Anonymous" and resolves their real name from 'users' collection.
  /// This fixes the database data so names appear correctly everywhere without manual intervention.
  void _autoFixAnonymousNames(List<Map<String, dynamic>> postings) async {
    for (var p in postings) {
      final applicants = List<Map<String, dynamic>>.from(p['applicants'] ?? []);
      bool changed = false;

      for (var a in applicants) {
        // If name is "Anonymous", try to fetch real name from users collection
        if (a['name'] == 'Anonymous' || a['name'] == null || a['name'] == '') {
          final userId = a['userId'];
          if (userId == null) continue;

          try {
            final userDoc = await _db.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final fName = userData['name'] ?? "";
              final lName = userData['surname'] ?? "";
              final fullName = "$fName $lName".trim();
              final resolved = fullName.isNotEmpty ? fullName : (userData['displayName'] ?? "Anonymous");

              if (resolved != "Anonymous" && resolved.isNotEmpty) {
                a['name'] = resolved;
                changed = true;
                debugPrint("HR Sync: Resolved Anonymous -> $resolved");
              }
            }
          } catch (e) {
            debugPrint("HR Sync Error: $e");
          }
        }
      }

      // If we fixed any names, update the posting document in Firestore
      if (changed) {
        try {
          await _db.collection('job_postings').doc(p['id']).update({
            'applicants': applicants,
          });
          
          // Also sync to 'applications' collection for consistency
          for (var a in applicants) {
            final appSnap = await _db.collection('applications')
                .where('candidateId', isEqualTo: a['userId'])
                .where('jobPostingId', isEqualTo: p['id'])
                .limit(1)
                .get();
            
            if (appSnap.docs.isNotEmpty) {
              await appSnap.docs.first.reference.update({'candidateName': a['name']});
            }
          }
        } catch (e) {
          debugPrint("HR Database Update Error: $e");
        }
      }
    }
  }

  /// Finds any posting with "Unknown Company" and resolves the real company name from hr_users.
  void _autoFixUnknownCompany(List<Map<String, dynamic>> postings) async {
    for (var p in postings) {
      if (p['company'] == 'Unknown Company' || p['company'] == null || (p['company'] as String? ?? '').isEmpty) {
        final hrId = p['createdByHrId'];
        if (hrId == null) continue;

        try {
          final hrDoc = await _db.collection('hr_users').doc(hrId).get();
          if (!hrDoc.exists) continue;

          final data = hrDoc.data()!;
          final name = data['name'] ?? '';
          final surname = data['surname'] ?? '';
          final cName = (data['companyName'] ?? '').toString().trim();

          String resolvedCompany;
          if (cName.isNotEmpty && cName != 'Company') {
            resolvedCompany = cName;
          } else if (name.isNotEmpty) {
            resolvedCompany = '$name $surname'.trim();
          } else {
            continue; // Can't resolve, skip
          }

          debugPrint('HR Sync: Fixing company "${p['company']}" -> "$resolvedCompany" for posting ${p['id']}');

          // Update job_postings
          await _db.collection('job_postings').doc(p['id']).update({'company': resolvedCompany});

          // Update related application documents
          final appSnap = await _db
              .collection('applications')
              .where('jobPostingId', isEqualTo: p['id'])
              .get();

          for (var appDoc in appSnap.docs) {
            if (appDoc.data()['company'] == 'Unknown Company' ||
                appDoc.data()['company'] == null) {
              await appDoc.reference.update({'company': resolvedCompany});
            }
          }
        } catch (e) {
          debugPrint('HR Sync Error (company fix): $e');
        }
      }
    }
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
          final resolvedName = fullName.isNotEmpty ? fullName : (userData['displayName'] ?? mergedData['name']);
          
          // 🔥 SYNC BACK TO JOB POSTING IF IT WAS ANONYMOUS
          if (mergedData['name'] == 'Anonymous' && resolvedName != 'Anonymous') {
            _syncNameBackToPosting(postingId, userId, resolvedName);
          }
          
          mergedData['name'] = resolvedName;
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

  // 🔥 Helper to fix "Anonymous" names in the background
  Future<void> _syncNameBackToPosting(String postingId, String userId, String name) async {
    try {
      final docRef = _db.collection('job_postings').doc(postingId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final applicants = List<Map<String, dynamic>>.from(doc.data()?['applicants'] ?? []);
      final idx = applicants.indexWhere((a) => a['userId'] == userId);
      
      if (idx != -1) {
        applicants[idx]['name'] = name;
        await docRef.update({'applicants': applicants});
      }
      
      // Also update in 'applications' collection
      final appSnap = await _db.collection('applications')
          .where('candidateId', isEqualTo: userId)
          .where('jobPostingId', isEqualTo: postingId)
          .limit(1)
          .get();
      
      if (appSnap.docs.isNotEmpty) {
        await appSnap.docs.first.reference.update({'candidateName': name});
      }
    } catch (e) {
      print("Error syncing name: $e");
    }
  }

  // ===============================
  // ACTIONS
  // ===============================

  Future<void> submitPosting() async {
    if (isLoading.value) return; // 🔥 Mükerrer tıklamayı önle

    if (!isFormValid) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;

    try {
      final user = _auth.currentUser;
      if (user == null) throw "User not logged in";

      // 🔥 Fetch Company Name for Job Posting
      String companyName = "";
      final hrDoc = await _db.collection('hr_users').doc(user.uid).get();
      if (hrDoc.exists) {
        final data = hrDoc.data()!;
        final name = (data['name'] ?? '').toString().trim();
        final surname = (data['surname'] ?? '').toString().trim();
        final cName = (data['companyName'] ?? '').toString().trim();

        if (cName.isNotEmpty && cName != 'Company') {
          // Real company name exists
          companyName = cName;
        } else if (name.isNotEmpty) {
          // Fallback: use HR user's full name
          companyName = '$name $surname'.trim();
        }
      }

      if (companyName.isEmpty) companyName = 'Unknown Company';

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
        "company": companyName, // 🔥 Added company name
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
    } finally {
      isLoading.value = false;
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
      String? generatedInviteCode;
      if (status == 'accepted') {
        generatedInviteCode = _generateUniqueCode();
      }

      // Update the status in the array
      applicants[idx]['status'] = status;
      if (generatedInviteCode != null) {
        applicants[idx]['inviteCode'] = generatedInviteCode; // 🔥 Save to array
      }

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

        // 🔥 3. If accepted, use the ALREADY generated code
        if (status == 'accepted' && generatedInviteCode != null) {
          updateData['inviteCode'] = generatedInviteCode;
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
