// ===================== File: hr_interviews_controller.dart =====================
// Purpose:
// Controls data for HR Interviews page
//
// Responsibilities:
// - Holds interview list
// - Groups interviews by status
// - Sorts by date/time
// - Prepares UI-ready sections
//
// IMPORTANT:
// - Currently uses mock data
// - Fully ready for backend integration
//
// TODO (Backend):
// - Replace mock list with Firestore/API data
// - Add interviewId, candidate list, scores
// - Add review status from backend
// ==============================================================================

import 'package:get/get.dart';

import '../hr_needs_review_detail_page.dart';
import '../hr_ongoing_interview_detail_page.dart';
import '../hr_reviewed_detail_page.dart';
import '../hr_upcoming_interview_detail_page.dart';
import 'hr_needs_review_detail_controller.dart';

class HRInterviewsController extends GetxController {
  // ===============================
  // RAW INTERVIEW LIST
  // ===============================
  /// All interviews (flat list)
  final interviews = <Map<String, dynamic>>[].obs;

  // ===============================
  // GROUPED DATA (UI READY)
  // ===============================
  final todayInterviews = <Map<String, dynamic>>[].obs;
  final needsReviewInterviews = <Map<String, dynamic>>[].obs;
  final reviewedInterviews = <Map<String, dynamic>>[].obs;

  // ===============================
  // STATS
  // ===============================
  final totalCount = 0.obs;
  final ongoingCount = 0.obs;
  final completedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    loadMockData();
    processInterviews();
  }

  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    interviews.value = [
      {
        "id": "INT-2026-XXX-001",
        "title": "Product Designer Interview",
        "position": "Senior Product Designer",
        "date": "2026-04-17",
        "time": "10:00 AM",
        "endTime": "11:00 AM",
        "candidateCount": 6,
        "status": "ongoing", // upcoming | ongoing | completed
        "reviewStatus": "pending", // pending | reviewed
      },
      {
        "id": "INT-2026-XXX-002",
        "title": "Frontend Developer Interview",
        "position": "Senior Frontend Engineer",
        "date": "2026-04-17",
        "time": "2:00 PM",
        "endTime": "3:30 PM",
        "candidateCount": 8,
        "status": "upcoming",
        "reviewStatus": "pending",
      },
      {
        "id": "INT-2026-XXX-003",
        "title": "Data Science Technical Round",
        "position": "ML Engineer",
        "date": "2026-04-17",
        "time": "4:00 PM",
        "endTime": "5:00 PM",
        "candidateCount": 5,
        "status": "upcoming",
        "reviewStatus": "pending",
      },
      {
        "id": "INT-2026-XXX-004",
        "title": "Backend Engineering – Round 2",
        "position": "Backend Engineer (Node.js)",
        "date": "2026-04-15",
        "time": "1:00 PM",
        "endTime": "2:00 PM",
        "candidateCount": 4,
        "status": "completed",
        "reviewStatus": "pending", // ❗ needs review
      },
      {
        "id": "INT-2026-XXX-005",
        "title": "iOS Developer Interview",
        "position": "iOS Engineer – Swift",
        "date": "2026-04-14",
        "time": "11:00 AM",
        "endTime": "12:00 PM",
        "candidateCount": 3,
        "status": "completed",
        "reviewStatus": "reviewed", // ✅ fully done
      },
    ];
  }

  // ===============================
  // PROCESS DATA FOR UI
  // ===============================
  void processInterviews() {
    final today = "2026-04-17"; // mock today

    // Clear old
    todayInterviews.clear();
    needsReviewInterviews.clear();
    reviewedInterviews.clear();

    for (final interview in interviews) {
      final status = interview["status"];
      final reviewStatus = interview["reviewStatus"];
      final date = interview["date"];

      // ===========================
      // TODAY (upcoming + ongoing)
      // ===========================
      if (date == today && (status == "upcoming" || status == "ongoing")) {
        todayInterviews.add(interview);
      }

      // ===========================
      // NEEDS REVIEW
      // ===========================
      if (status == "completed" && reviewStatus == "pending") {
        needsReviewInterviews.add(interview);
      }

      // ===========================
      // REVIEWED
      // ===========================
      if (status == "completed" && reviewStatus == "reviewed") {
        reviewedInterviews.add(interview);
      }
    }

    // ===============================
    // SORT BY TIME
    // ===============================
    todayInterviews
        .sort((a, b) => _parseTime(a["time"]).compareTo(_parseTime(b["time"])));
    needsReviewInterviews.sort((a, b) => b["date"].compareTo(a["date"]));
    reviewedInterviews.sort((a, b) => b["date"].compareTo(a["date"]));

    // ===============================
    // STATS CALCULATION
    // ===============================
    totalCount.value = interviews.length;
    ongoingCount.value =
        interviews.where((i) => i["status"] == "ongoing").length;
    completedCount.value =
        interviews.where((i) => i["status"] == "completed").length;
  }

  // ===============================
  // BACKEND FETCH (FUTURE)
  // ===============================
  /// Fetch interviews from backend
  ///  IMPORTANT (Time Format):
  /// - Backend MUST return startTime & endTime as DateTime
  /// - UI will format to AM/PM using TimeOfDay.format()
  /// - DO NOT send time as plain string
  ///
  /// Example:
  /// {
  ///   startTime: Timestamp,
  ///   endTime: Timestamp
  /// }
  ///
  /// TODO:
  /// - Replace mock data
  /// - Fetch from Firestore / API
  /// - Include:
  ///   - interviewId
  ///   - candidate list
  ///   - scores
  ///   - timestamps
  Future<void> fetchInterviewsFromBackend() async {
    /*
    final data = await api.getInterviews();

    interviews.value = data;

    processInterviews();
    */
  }

  // ===============================
  // ACTIONS
  // ===============================

  /// Called when clicking "See All"
  void openSeeAll(String section) {
    // TODO: Navigate to filtered page
    Get.snackbar("TODO", "Open $section full list");
  }

  /// Called when clicking interview card
  void openInterviewDetail(Map<String, dynamic> interview) {
    final status = interview["status"];
    final reviewStatus = interview["reviewStatus"];

    // ===============================
    // ONGOING
    // ===============================
    if (status == "ongoing") {
      Get.to(() => HROngoingInterviewDetailPage(
            interview: interview,
          ));
      return;
    }

    // ===============================
    // UPCOMING
    // ===============================
    if (status == "upcoming") {
      Get.to(() => HRUpcomingInterviewDetailPage(
            interview: interview,
          ));
      return;
    }

    // ===============================
    // NEEDS REVIEW
    // ===============================
    if (status == "completed" && reviewStatus == "pending") {
      Get.to(
        () => HrNeedsReviewDetailPage(
          interview: interview,
        ),
        binding: BindingsBuilder(() {
          Get.put(HrNeedsReviewDetailController(
            interview: interview,
          ));
        }),
      );
      return;
    }

    // ===============================
    // REVIEWED
    // ===============================
    if (status == "completed" && reviewStatus == "reviewed") {
      Get.to(() => HrReviewedDetailPage(
        interview: {
          ...interview,

          /// 🔥 CANDIDATES EKLE
          "candidates": interview["candidates"] ?? [],
        },
      ));
      return;
    }
  }

  // ===============================
  // TIME PARSER (AM/PM → DateTime)
  // ===============================
  DateTime _parseTime(String time) {
    final parts = time.split(" ");
    final hm = parts[0].split(":");
    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPm = parts[1] == "PM";

    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    return DateTime(0, 0, 0, hour, minute);
  }
}
