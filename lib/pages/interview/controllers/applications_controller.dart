// ===================== File: applications_controller.dart =====================
// Purpose:
// Controls "My Applications - View All" page using real-time Firestore data.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ApplicationsController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // =========================================================
  // 🔹 STATE
  // =========================================================

  final applications = <Map<String, dynamic>>[].obs;
  final searchQuery = "".obs;
  final selectedFilter = "All".obs;
  final filters = ["All", "Accepted", "Pending", "Rejected"];
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToApplications();
  }

  // =========================================================
  // 🔹 REAL-TIME APPLICATIONS
  // =========================================================

  void _listenToApplications() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    
    // We fetch applications by searching within job_postings sub-collections or a top-level applications collection
    // Based on previous work, we have a top-level 'applications' collection
    _db.collection('applications')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .listen((snap) {
          final list = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // 🔥 Sort by appliedAt descending
          list.sort((a, b) {
            final aTime = a['appliedAt'];
            final bTime = b['appliedAt'];

            DateTime parseTime(dynamic time) {
              if (time is Timestamp) return time.toDate();
              if (time is String) return DateTime.parse(time);
              return DateTime(2000);
            }

            return parseTime(bTime).compareTo(parseTime(aTime));
          });

          applications.value = list;
          isLoading.value = false;
        });
  }

  // =========================================================
  // 🔹 ACTIONS
  // =========================================================

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // =========================================================
  // 🔹 FILTER + SEARCH + SORT
  // =========================================================

  List<Map<String, dynamic>> get filteredApplications {
    List<Map<String, dynamic>> result = applications.toList();

    if (searchQuery.value.isNotEmpty) {
      result = result.where((app) {
        final title = (app["jobTitle"] ?? "").toString().toLowerCase();
        return title.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    if (selectedFilter.value != "All") {
      result = result.where((app) {
        return (app["status"] ?? "pending").toString().toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }

    result.sort((a, b) {
      return _getPriority(a["status"]).compareTo(_getPriority(b["status"]));
    });

    return result;
  }

  int _getPriority(dynamic status) {
    final s = status.toString().toLowerCase();
    switch (s) {
      case "accepted": return 0;
      case "pending": return 1;
      case "rejected": return 2;
      default: return 3;
    }
  }

  // =========================================================
  // 🔹 HELPERS
  // =========================================================

  String formatTimeRange(dynamic start, dynamic end) {
    if (start == null || end == null) return "";
    final startDt = (start is Timestamp) ? start.toDate() : DateTime.parse(start.toString());
    final endDt = (end is Timestamp) ? end.toDate() : DateTime.parse(end.toString());
    return "${DateFormat('HH:mm').format(startDt)} - ${DateFormat('HH:mm').format(endDt)}";
  }

  String formatDate(dynamic date) {
    if (date == null) return "";
    final dt = (date is Timestamp) ? date.toDate() : DateTime.parse(date.toString());
    return DateFormat('MMM dd, yyyy').format(dt);
  }
}
