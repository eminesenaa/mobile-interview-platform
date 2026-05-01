// ===================== File: applications_controller.dart =====================
// Purpose:
// Controls "My Applications - View All" page
//
// Responsibilities:
// - Holds application list (mock for now)
// - Manages search query
// - Manages selected filter
// - Provides filtered + sorted result list
//
// IMPORTANT:
// - Backend-ready structure
// - Sorting priority:
//   Accepted → Pending → Rejected
//
// TODO (Backend):
// - Fetch applications from API
// - Replace mock data
// - Map backend models
// ============================================================================

import 'package:get/get.dart';

class ApplicationsController extends GetxController {
  // =========================================================
  // 🔹 STATE
  // =========================================================

  /// All applications (mock data for now)
  final applications = <Map<String, dynamic>>[].obs;

  /// Search input
  final searchQuery = "".obs;

  /// Selected filter
  final selectedFilter = "All".obs;

  /// Filter options
  final filters = ["All", "Accepted", "Pending", "Rejected"];

  // =========================================================
  // 🔹 INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();
    loadMockData();

    // TODO (Backend)
    /*
    fetchApplications();
    */
  }

  // =========================================================
  // 🔹 MOCK DATA
  // =========================================================

  void loadMockData() {
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

    // ================= SEARCH =================
    if (searchQuery.value.isNotEmpty) {
      result = result.where((app) {
        final title = (app["title"] ?? "").toString().toLowerCase();
        return title.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // ================= FILTER =================
    if (selectedFilter.value != "All") {
      result = result.where((app) {
        return app["status"] == selectedFilter.value.toLowerCase();
      }).toList();
    }

    // ================= SORT =================
    result.sort((a, b) {
      return _getPriority(a["status"]).compareTo(_getPriority(b["status"]));
    });

    return result;
  }

  // =========================================================
  // 🔹 PRIORITY LOGIC
  // =========================================================

  int _getPriority(String status) {
    switch (status) {
      case "accepted":
        return 0;
      case "pending":
        return 1;
      case "rejected":
        return 2;
      default:
        return 3;
    }
  }

  // =========================================================
  // 🔹 TIME FORMAT HELPERS
  // =========================================================

  String formatTimeRange(String start, String end) {
    final startDt = DateTime.parse(start);
    final endDt = DateTime.parse(end);

    String format(DateTime dt) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

    return "${format(startDt)} - ${format(endDt)}";
  }

  String formatDate(String start) {
    final dt = DateTime.parse(start);

    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
  }


// =========================================================
// 🔹 TODO BACKEND METHODS
// =========================================================

/*
  Future<void> fetchApplications() async {
    // call API
    // map to model
  }
  */
}
