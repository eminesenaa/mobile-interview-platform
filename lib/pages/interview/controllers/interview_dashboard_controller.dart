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

import '../../../models/interview_result.dart';
import '../pages/interview/waiting/interview_waiting_page.dart';

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
        "position": "Product Designer",
        "workType": "Remote",
        "salary": "\$4,000 - \$6,000",
        "description":
            "Join our design team to create intuitive and user-friendly experiences. Collaborate with product managers and engineers to design seamless user journeys, improve usability, and contribute to design system consistency.",
        "requirements": [
          "3+ years experience in product design",
          "Figma / Adobe XD knowledge",
          "Strong UX thinking",
        ],
        "company": "CreativeWorks",
        "location": "Berlin",
        "status": "pending",
        "message": "Waiting for HR review...",
        "date": "May 12, 2026",
        "startTime": "2026-05-12T14:00:00",
        "endTime": "2026-05-12T15:00:00",
        "inviteCode": "PQ-Z040",
        "hrMessage":
            "Your application is currently under review. If selected, you will receive an interview invitation with further details.",
      },
      {
        "title": "iOS Engineer",
        "position": "iOS Engineer",
        "workType": "On-site",
        "salary": "\$5,000 - \$7,000",
        "description":
            "Develop high-quality iOS applications using Swift and modern Apple frameworks. Work closely with cross-functional teams to build scalable, maintainable mobile solutions and deliver smooth user experiences.",
        "requirements": [
          "3+ years of iOS development experience",
          "Strong knowledge of Swift and UIKit/SwiftUI",
          "Experience with REST API integration",
          "Understanding of mobile app architecture patterns",
        ],
        "company": "AppNova",
        "location": "San Francisco",
        "status": "accepted",
        "message": "You have been accepted.",
        "date": "May 14, 2026",
        "startTime": "2026-05-14T10:00:00",
        "endTime": "2026-05-14T11:00:00",
        "inviteCode": "IO-A921",
        "hrMessage":
            "Hi! We are happy to inform you that you have been selected for an interview. Please be available at the scheduled time and use your invite code to join.",
      },
      {
        "title": "Data Analyst",
        "position": "Data Analyst",
        "workType": "Remote",
        "salary": "\$3,000 - \$4,500",
        "description":
            "Analyze datasets to generate actionable insights and support business decisions. Build dashboards, create reports, and collaborate with teams to identify trends and improve data-driven strategies.",
        "requirements": [
          "2+ years of experience in data analysis",
          "Strong SQL and Excel skills",
          "Experience with data visualization tools (Tableau, Power BI)",
          "Basic knowledge of Python or R",
        ],
        "company": "Metrics Corp",
        "location": "Remote",
        "status": "rejected",
        "message": "Application not progressed",
        "date": "May 10, 2026",
        "startTime": "2026-05-10T00:00:00",
        "endTime": "2026-05-10T00:00:00",
        "inviteCode": "—",
        "hrMessage":
            "Thank you for your interest. After careful consideration, we will not be moving forward with your application at this time.",
      },
      {
        "title": "Backend Engineer",
        "position": "Backend Engineer",
        "workType": "Hybrid",
        "salary": "\$4,000 - \$6,000",
        "description":
            "Design and maintain backend systems and APIs with a focus on scalability and performance. Work with distributed systems, integrate services, and ensure secure and efficient data handling.",
        "requirements": [
          "3+ years of backend development experience",
          "Strong knowledge of Node.js or similar backend technologies",
          "Experience with databases (SQL/NoSQL)",
          "Understanding of API design and system architecture",
        ],
        "company": "Cloudify",
        "location": "Berlin",
        "status": "accepted",
        "message": "You have been accepted.",
        "date": "May 16, 2026",
        "startTime": "2026-05-16T16:00:00",
        "endTime": "2026-05-16T17:00:00",
        "inviteCode": "BE-X552",
        "hrMessage":
            "Hi! We are happy to inform you that you have been selected for an interview. Please be available at the scheduled time and use your invite code to join.",
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
        "company": "AppNova",
        "location": "San Francisco",
        "startTime": "2026-05-14T10:00:00",
        "endTime": "2026-05-14T11:00:00",
        "result": InterviewResult(
          id: "1",
          interviewId: "int_1",
          candidateId: "user_1",
          score: 95,
          correctCount: 9,
          wrongCount: 1,
          unansweredCount: 0,
          decision: InterviewDecisionStatus.accepted,
          hrMessage: "Excellent performance!",
          isSubmitted: true,
          isReviewed: true,
          submittedAt: DateTime.now().subtract(const Duration(days: 2)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      },
      {
        "title": "Product Designer",
        "company": "CreativeWorks",
        "location": "Amsterdam",
        "startTime": "2026-05-18T09:00:00",
        "endTime": "2026-05-18T10:00:00",
        "result": InterviewResult(
          id: "2",
          interviewId: "int_2",
          candidateId: "user_1",
          decision: InterviewDecisionStatus.pending,
          isSubmitted: true,
          isReviewed: false,
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      },
      {
        "title": "Backend Engineer",
        "company": "Cloudify",
        "location": "Berlin",
        "startTime": "2026-05-10T14:00:00",
        "endTime": "2026-05-10T15:00:00",
        "result": InterviewResult(
          id: "3",
          interviewId: "int_3",
          candidateId: "user_1",
          score: 62,
          correctCount: 6,
          wrongCount: 4,
          unansweredCount: 0,
          decision: InterviewDecisionStatus.rejected,
          hrMessage: "Did not meet expectations.",
          isSubmitted: true,
          isReviewed: true,
          submittedAt: DateTime.now().subtract(const Duration(days: 4)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
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
    // =======================================================
    // 🔥 MOCK NAVIGATION (TEMPORARY)
    // =======================================================
    // TODO (Backend):
    // - Validate invite code
    // - Fetch real interview session data
    // - Replace mock values below

    if (inviteCode.isEmpty) {
      Get.snackbar("Error", "Please enter invite code");
      return;
    }

    Get.to(
      () => const InterviewWaitingPage(),
      arguments: {
        "date": "May 14, 2026",
        "time": "10:00 – 11:00",
        "code": inviteCode,
      },
    );
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
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month];
  }
}
