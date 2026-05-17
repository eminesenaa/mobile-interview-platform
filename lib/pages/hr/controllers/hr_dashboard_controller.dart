// ===================== File: hr_dashboard_controller.dart =====================
// Purpose:
// Controls HR Dashboard data (activities, stats)
//
// IMPORTANT:
// - Uses mock data for now
// - Structured for easy backend integration later
//
// TODO (Backend):
// - Replace mock data with Firestore/API
// - Fetch interview-based activities dynamically
// ============================================================================

import 'package:get/get.dart';

class HRDashboardController extends GetxController {
  // ===============================
  // STATS (TOP CARDS)
  // ===============================
  final interviewCount = 5.obs;
  final candidateCount = 34.obs;

  // ===============================
  // RECENT ACTIVITIES (INTERVIEW BASED)
  // ===============================
  final activities = <Map<String, dynamic>>[].obs;

  // ===============================
  // HR USER INFO (HEADER)
  // ===============================
  /// Company name & initials (header için)
  /// TODO: backend'den gelecek (HR user document)
  final companyName = "Beyond Technologies".obs;
  final initials = "HR".obs;

  @override
  void onInit() {
    super.onInit();

    // Load mock data initially
    loadMockData();

    // Prepare backend-ready function
    fetchDashboardStats();

    fetchHRUserInfo();
  }

  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    // Activities
    activities.value = [
      {
        "type": "pending",
        "title": "Frontend interview ended",
        "subtitle": "3 candidates awaiting review",
      },
      {
        "type": "upcoming",
        "title": "Backend interview scheduled",
        "subtitle": "Thu 17 Apr — 14:00",
      },
      {
        "type": "pending",
        "title": "Mobile interview ended",
        "subtitle": "1 candidate awaiting review",
      },
    ];

    // Stats (mock)
    interviewCount.value = 5;
    candidateCount.value = 34;

    // ===============================
    // MOCK HR USER INFO
    // ===============================
    companyName.value = "Beyond Technologies";
    initials.value = "HR";
  }

  // ===============================
  // FETCH STATS (BACKEND READY)
  // ===============================
  Future<void> fetchDashboardStats() async {
    // TODO: Replace with backend call

    /*
    final result = await api.getDashboardStats();

    interviewCount.value = result["interviewCount"];
    candidateCount.value = result["candidateCount"];
    */

    // Mock fallback (şimdilik aynı kalır)
    interviewCount.value = 5;
    candidateCount.value = 34;
  }

// ===============================
// TODO: BACKEND INTEGRATION
// ===============================
/*
  Future<void> fetchActivitiesFromBackend() async {
    // Example:
    // final data = await api.getActivities();
    // activities.value = data;
  }
  */

  // ===============================
  // FETCH HR USER INFO (BACKEND READY)
  // ===============================
  Future<void> fetchHRUserInfo() async {
    // TODO: Replace with backend call

    /*
    final user = await api.getHRUser();

    companyName.value = user.companyName;
    initials.value = user.initials;
    */

    // Mock fallback
    companyName.value = "Beyond Technologies";
    initials.value = "HR";
  }
}
