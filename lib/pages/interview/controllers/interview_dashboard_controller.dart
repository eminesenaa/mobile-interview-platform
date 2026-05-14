// ===================== File: interview_dashboard_controller.dart =====================
// Purpose:
// Controls Candidate Interview Dashboard using real-time Firestore data.
// ===============================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../models/interview_result.dart';
import '../pages/interview/waiting/interview_waiting_page.dart';

class InterviewDashboardController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ===============================
  // STATE
  // ===============================
  final openPositions = <Map<String, dynamic>>[].obs;
  final applications = <Map<String, dynamic>>[].obs;
  final upcomingInterview = Rxn<Map<String, dynamic>>();
  final results = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToDashboardData();
  }

  // ===============================
  // REAL-TIME DATA LISTENERS
  // ===============================
  void _listenToDashboardData() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;

    // 1. Listen to open positions
    _db.collection('job_postings')
        .where('status', isEqualTo: 'active')
        .limit(10)
        .snapshots()
        .listen((snap) {
          openPositions.value = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });

    // 2. Listen to applications
    _db.collection('applications')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .listen((snap) async {
          final List<Map<String, dynamic>> updatedApps = [];
          
          for (var doc in snap.docs) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            
            // If missing info, fetch from job_postings
            if (data['workType'] == null || data['location'] == null) {
              final postingDoc = await _db.collection('job_postings').doc(data['jobPostingId']).get();
              if (postingDoc.exists) {
                final postingData = postingDoc.data()!;
                data['workType'] = postingData['workType'];
                data['location'] = postingData['location'];
                data['company'] = postingData['company'] ?? "Company";
                data['description'] = postingData['description'];
                data['requirements'] = postingData['requirements'];
                if (data['jobTitle'] == null) data['jobTitle'] = postingData['title'];
              }
            }
            updatedApps.add(data);
          }
          applications.value = updatedApps;
        });

    // 3. Listen to upcoming interview
    _db.collection('interviews')
        .where('candidateIds', arrayContains: user.uid)
        .where('status', isEqualTo: 'scheduled')
        .orderBy('startTime', descending: false)
        .limit(1)
        .snapshots()
        .listen((snap) {
          if (snap.docs.isNotEmpty) {
            final data = snap.docs.first.data();
            data['id'] = snap.docs.first.id;
            upcomingInterview.value = data;
          } else {
            upcomingInterview.value = null;
          }
        });

    // 4. Listen to results
    _db.collection('ai_interview_results')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .listen((snap) {
          results.value = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });

    isLoading.value = false;
  }

  // ===============================
  // DERIVED STATS
  // ===============================
  int get activeApplicationsCount => applications.where((a) => a["status"] == "pending").length;
  int get readyInterviewsCount => upcomingInterview.value != null ? 1 : 0;
  int get pendingResultsCount => results.where((r) => r["decision"] == "pending").length;

  // ===============================
  // ACTIONS
  // ===============================
  void joinInterview(String inviteCode) {
    if (inviteCode.isEmpty) {
      Get.snackbar("Error", "Please enter invite code");
      return;
    }

    // Navigation logic
    Get.to(
      () => const InterviewWaitingPage(),
      arguments: {
        "code": inviteCode,
      },
    );
  }

  // ===============================
  // DATE FORMATTERS
  // ===============================
  String formatDate(dynamic date) {
    if (date == null) return "";
    final dt = (date is Timestamp) ? date.toDate() : (date is DateTime ? date : DateTime.parse(date.toString()));
    return DateFormat('MMM dd, yyyy').format(dt);
  }

  String formatTimeRange(dynamic start, dynamic end) {
    if (start == null || end == null) return "";
    final sDt = (start is Timestamp) ? start.toDate() : (start is DateTime ? start : DateTime.parse(start.toString()));
    final eDt = (end is Timestamp) ? end.toDate() : (end is DateTime ? end : DateTime.parse(end.toString()));
    return "${DateFormat('h:mm a').format(sDt)} – ${DateFormat('h:mm a').format(eDt)}";
  }
}
