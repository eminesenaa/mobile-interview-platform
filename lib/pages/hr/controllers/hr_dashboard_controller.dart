// ===================== File: hr_dashboard_controller.dart =====================
// Purpose:
// Controls HR Dashboard data (activities, stats) using real-time Firestore data.
// ============================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HRDashboardController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ===============================
  // STATS (TOP CARDS)
  // ===============================
  final interviewCount = 0.obs;
  final candidateCount = 0.obs;

  // ===============================
  // RECENT ACTIVITIES (INTERVIEW BASED)
  // ===============================
  final activities = <Map<String, dynamic>>[].obs;

  // ===============================
  // HR USER INFO (HEADER)
  // ===============================
  final companyName = "Loading...".obs;
  final initials = "HR".obs;

  @override
  void onInit() {
    super.onInit();
    _listenToStats();
    _listenToActivities();
    fetchHRUserInfo();
  }

  // ===============================
  // REAL-TIME STATS
  // ===============================
  void _listenToStats() {
    // 📊 Count interviews
    _db.collection('interviews').snapshots().listen((snap) {
      interviewCount.value = snap.docs.length;
    });

    // 👥 Count total job postings candidates
    _db.collection('job_postings').snapshots().listen((snap) {
      int total = 0;
      for (var doc in snap.docs) {
        final applicants = doc.data()['applicants'] as List?;
        total += applicants?.length ?? 0;
      }
      candidateCount.value = total;
    });
  }

  // ===============================
  // REAL-TIME ACTIVITIES
  // ===============================
  void _listenToActivities() {
    _db.collection('interviews')
        .orderBy('startTime', descending: true)
        .limit(5)
        .snapshots()
        .listen((snap) {
          activities.value = snap.docs.map((doc) {
            final data = doc.data();
            final status = data['status'] ?? 'scheduled';
            final startTime = data['startTime'] as Timestamp?;
            
            String subtitle = "";
            
            if (status == "completed") {
              subtitle = "Waiting for HR review";
            } else if (status == "ongoing") {
              subtitle = "Interview is currently live";
            } else if (startTime != null) {
              final date = startTime.toDate();
              final now = DateTime.now();
              if (date.day == now.day && date.month == now.month && date.year == now.year) {
                subtitle = "Scheduled for today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
              } else {
                subtitle = "Scheduled for ${date.day}/${date.month}";
              }
            } else {
              subtitle = "Interview ${status}";
            }

            return {
              "id": doc.id,
              "type": status == "completed" ? "pending" : "upcoming",
              "title": data['title'] ?? "New Interview",
              "subtitle": subtitle,
              "data": {...data, "id": doc.id}, // Full interview data for navigation
            };
          }).toList();
    });
  }

  // ===============================
  // FETCH HR USER INFO
  // ===============================
  Future<void> fetchHRUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await _db.collection('hr_users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        companyName.value = data['companyName'] ?? "Company Name";
        
        final name = data['name'] ?? "";
        final surname = data['surname'] ?? "";
        if (name.isNotEmpty && surname.isNotEmpty) {
          initials.value = "${name[0]}${surname[0]}".toUpperCase();
        }
      }
    } catch (e) {
      print("HRDashboardController: Error fetching HR info: $e");
    }
  }
}
