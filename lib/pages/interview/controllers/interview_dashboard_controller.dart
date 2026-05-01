// ===================== File: interview_dashboard_controller.dart =====================
// Purpose:
// Controls Candidate Interview Dashboard
//
// Responsibilities:
// - Fetch open job postings
// - Manage user applications
// - Provide upcoming interview data
// - Provide interview results
//
// IMPORTANT:
// - Uses mock data for now
// - Fully backend-ready
//
// TODO (Backend):
// - Replace all mock lists with API / Firestore calls
// - Normalize data models (User, JobPosting, Interview, Result)
// - Add pagination & filtering if needed
// ===============================================================================

import 'package:get/get.dart';

class InterviewDashboardController extends GetxController {
  // ===============================
  // OPEN POSITIONS (APPLY)
  // ===============================
  /// Jobs that candidate can apply to
  final openPositions = <Map<String, dynamic>>[].obs;

  // ===============================
  // MY APPLICATIONS
  // ===============================
  /// Candidate’s applications
  /// Includes status: pending / accepted / rejected
  final applications = <Map<String, dynamic>>[].obs;

  // ===============================
  // UPCOMING INTERVIEW
  // ===============================
  /// Single upcoming interview (if exists)
  final upcomingInterview = Rxn<Map<String, dynamic>>();

  // ===============================
  // INTERVIEW RESULTS
  // ===============================
  /// Completed / pending interview results
  final results = <Map<String, dynamic>>[].obs;

  // ===============================
  // LOADING STATES
  // ===============================
  final isLoading = false.obs;

  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();

    loadMockData();

    // Backend-ready calls
    fetchDashboardData();
  }

  // ===============================
  // MOCK DATA (TEMPORARY)
  // ===============================
  void loadMockData() {
    // ================= OPEN POSITIONS =================
    openPositions.value = [
      {
        "id": "JP-1",
        "title": "Frontend Developer",
        "level": "Senior",
        "location": "Istanbul, Turkey",
        "workType": "Remote",
        "description":
        "Build and maintain modern, scalable, and high-performance user interfaces using React and TypeScript. Collaborate closely with designers and backend teams to deliver seamless user experiences. Optimize applications for speed and responsiveness, ensure cross-browser compatibility, and contribute to UI architecture decisions.",
        "requirements": [
          "4+ years of frontend development experience",
          "Strong proficiency in React and TypeScript",
          "Experience with state management libraries (Redux, Zustand, etc.)",
          "Solid understanding of responsive design and UI/UX principles",
          "Familiarity with REST APIs and modern frontend tooling",
        ],
        "salary": "\$4,000 - \$6,000",
      },
      {
        "id": "JP-2",
        "title": "Backend Engineer",
        "level": "Mid-Level",
        "location": "Berlin, Germany",
        "workType": "Hybrid",
        "description":
        "Design, develop, and maintain scalable backend systems and APIs using Node.js. Work with microservice architectures, integrate third-party services, and ensure high availability and performance. Collaborate with frontend and DevOps teams to deliver end-to-end solutions.",
        "requirements": [
          "3+ years of backend development experience",
          "Strong knowledge of Node.js and Express.js",
          "Experience with RESTful API design and microservices",
          "Familiarity with databases (PostgreSQL, MongoDB)",
          "Understanding of authentication, security, and performance optimization",
        ],
        "salary": "\$3,500 - \$5,000",
      },
    ];

    // ================= APPLICATIONS =================
    applications.value = [
      {
        "title": "Product Designer",
        "company": "CreativeWorks",
        "status": "pending",
        "message": "Waiting for HR review...",
      },
      {
        "title": "iOS Engineer",
        "company": "AppNova",
        "status": "accepted",
        "message": "You have been accepted.",
      },
      {
        "title": "Data Analyst",
        "company": "Metrics Corp",
        "status": "rejected",
        "message": "Application not progressed",
      },
    ];

    // ================= UPCOMING INTERVIEW =================
    upcomingInterview.value = {
      "id": "INT-1",
      "title": "iOS Engineer Interview",

      // 🔥 REAL MODEL FORMAT
      "startTime": DateTime(2025, 4, 28, 14, 0),
      "endTime": DateTime(2025, 4, 28, 15, 0),

      "joinCode": "PQ-Z04O",
      "status": "scheduled",
    };

    // ================= RESULTS =================
    results.value = [
      {
        "title": "Frontend Developer",
        "status": "accepted",
        "date": "Apr 14, 2025",
        "feedback": "Excellent performance across all topics.",
      },
      {
        "title": "Product Designer",
        "status": "pending",
        "date": "Apr 20, 2025",
        "feedback": "Under HR review",
      },
      {
        "title": "Backend Engineer",
        "status": "rejected",
        "date": "Apr 18, 2025",
        "feedback": "Did not meet expectations.",
      },
    ];
  }

  // Normalize job model (backend ready)
  Map<String, dynamic> normalizeJob(Map<String, dynamic> job) {
    return {
      "id": job["id"],
      "title": job["title"],
      "level": job["level"],
      "location": job["location"],
      "workType": job["workType"],
      "description": job["description"],
    };
  }

  // ===============================
  // FETCH DASHBOARD DATA (BACKEND READY)
  // ===============================
  Future<void> fetchDashboardData() async {
    isLoading.value = true;

    try {
      // ===============================
      // TODO: BACKEND INTEGRATION
      // ===============================

      /*
      final response = await api.getInterviewDashboard();

      openPositions.value = response.openPositions;
      applications.value = response.applications;
      upcomingInterview.value = response.upcomingInterview;
      results.value = response.results;
      */
    } catch (e) {
      // TODO: error handling
    } finally {
      isLoading.value = false;
    }
  }

  // ===============================
  // DERIVED STATS (FOR UI CHIPS)
  // ===============================

  int get activeApplicationsCount {
    return applications.where((a) => a["status"] == "pending").length;
  }

  int get readyInterviewsCount {
    return upcomingInterview.value != null ? 1 : 0;
  }

  int get pendingResultsCount {
    return results.where((r) => r["status"] == "pending").length;
  }

  // ===============================
  // ACTIONS
  // ===============================

  void applyToJob(Map<String, dynamic> job) {
    // ===============================
    // TODO (Backend):
    // ===============================
    /*
  await api.applyToJob(
    jobId: job["id"],
    candidateId: currentUserId,
  );
  */

    applications.add({
      "title": job["title"],
      "company": job["company"] ?? "Unknown",
      "status": "pending",
      "message": "Waiting for HR review...",
    });

    Get.snackbar("Applied", "Application submitted successfully");
  }

  void joinInterview(String inviteCode) {
    // TODO (Backend):
    // - Validate invite code
    // - Fetch interview session
    // - Navigate to interview (Exam module)

    print("Joining interview with code: $inviteCode");
  }

  // ===============================
// 🕒 DATE FORMATTERS (UI READY)
// ===============================

  String formatDate(DateTime date) {
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String formatTimeRange(DateTime start, DateTime end) {
    return "${_formatTime(start)} – ${_formatTime(end)}";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  String _monthName(int month) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month];
  }
}
