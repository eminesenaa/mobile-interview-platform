// ===================== File: interview_results_controller.dart =====================
// Purpose:
// Controls Interview Results (View All page)
//
// Responsibilities:
// - Hold all interview results
// - Manage search & filter state
// - Provide grouped & sorted data
//
// IMPORTANT:
// - Uses mock data for now
// - Fully backend-ready structure
//
// TODO (Backend):
// - Fetch interview results from API / Firestore
// - Support pagination
// - Add real-time updates (optional)
// - Replace mock filtering with server-side filtering
// - Replace Map structure with full relational models (Interview + JobPosting)
// ================================================================================

import 'package:get/get.dart';

// 🔥 MODEL IMPORT
import '../../../models/exam.dart';
import '../../../models/interview_result.dart';
import '../../../models/question.dart';
import '../../exam/controllers/create_exam_controller.dart';

class InterviewResultsController extends GetxController {
  // ===============================
  // SEARCH & FILTER STATE
  // ===============================

  /// Current search query
  final searchQuery = "".obs;

  /// Selected filter (All / Accepted / Pending / Rejected)
  final selectedFilter = "All".obs;

  /// Available filters
  final filters = [
    "All",
    "Accepted",
    "Pending",
    "Rejected",
  ];

  // ===============================
  // DATA SOURCE (MOCK)
  // ===============================

  /// All interview results (mock data)
  ///
  /// IMPORTANT:
  /// - UI needs extra fields (title, company, location, time)
  /// - So we wrap InterviewResult inside a Map for now
  ///
  /// TODO (Backend):
  /// Replace this with:
  /// List<InterviewResult> + separate Interview & JobPosting data
  final results = <Map<String, dynamic>>[].obs;

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();

    // =======================================================
    // 🔥 MOCK DATA INIT
    // =======================================================
    // TODO (Backend):
    // results.value = await api.fetchInterviewResults();

    results.value = [
      {
        // ================= UI FIELDS =================
        "title": "Frontend Developer",
        "company": "AppNova",
        "location": "San Francisco",
        "startTime": "2026-05-14T10:00:00",
        "endTime": "2026-05-14T11:00:00",

        // ================= MODEL =================
        "result": InterviewResult(
          id: "1",
          interviewId: "int_1",
          candidateId: "user_1",
          score: 95,
          correctCount: 9,
          wrongCount: 1,
          unansweredCount: 0,
          decision: InterviewDecisionStatus.accepted,
          hrMessage: "Excellent performance! You stood out among candidates.",
          isSubmitted: true,
          isReviewed: true,
          submittedAt: DateTime.now().subtract(const Duration(days: 2)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      },
      {
        "title": "Backend Engineer",
        "company": "Cloudify",
        "location": "Berlin",
        "startTime": "2026-05-10T14:00:00",
        "endTime": "2026-05-10T15:00:00",
        "result": InterviewResult(
          id: "2",
          interviewId: "int_2",
          candidateId: "user_1",
          score: 62,
          correctCount: 6,
          wrongCount: 4,
          unansweredCount: 0,
          decision: InterviewDecisionStatus.rejected,
          hrMessage:
              "You showed potential, but did not meet the required threshold.",
          isSubmitted: true,
          isReviewed: true,
          submittedAt: DateTime.now().subtract(const Duration(days: 4)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      },
      {
        "title": "Product Designer",
        "company": "CreativeWorks",
        "location": "Amsterdam",
        "startTime": "2026-05-18T09:00:00",
        "endTime": "2026-05-18T10:00:00",
        "result": InterviewResult(
          id: "3",
          interviewId: "int_3",
          candidateId: "user_1",
          decision: InterviewDecisionStatus.pending,
          isSubmitted: true,
          isReviewed: false,
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      },
    ];
  }

  // ===============================
  // ACTIONS
  // ===============================

  /// Update search query
  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  /// Update selected filter
  void setFilter(String value) {
    selectedFilter.value = value;
  }

  // ===============================
  // HELPER: STATUS
  // ===============================

  /// Converts enum → string for UI usage
  String getStatus(Map<String, dynamic> item) {
    final InterviewResult result = item["result"];

    switch (result.decision) {
      case InterviewDecisionStatus.accepted:
        return "accepted";
      case InterviewDecisionStatus.rejected:
        return "rejected";
      case InterviewDecisionStatus.pending:
      default:
        return "pending";
    }
  }

  // ===============================
  // FILTERED DATA
  // ===============================

  /// Returns filtered + searched + sorted results
  List<Map<String, dynamic>> get filteredResults {
    List<Map<String, dynamic>> list = results;

    // ================= SEARCH =================
    if (searchQuery.value.isNotEmpty) {
      list = list.where((r) {
        final title = r["title"].toString().toLowerCase();
        return title.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // ================= FILTER =================
    if (selectedFilter.value != "All") {
      list = list.where((r) {
        return getStatus(r) == selectedFilter.value.toLowerCase();
      }).toList();
    }

    // ================= SORT =================
    // Accepted → Pending → Rejected
    list.sort((a, b) {
      const order = {
        "accepted": 0,
        "pending": 1,
        "rejected": 2,
      };

      return order[getStatus(a)]!.compareTo(order[getStatus(b)]!);
    });

    return list;
  }

  // ===============================
  // FORMAT HELPERS
  // ===============================

  /// Formats time range from ISO strings
  String formatTimeRange(String start, String end) {
    try {
      final startDt = DateTime.parse(start);
      final endDt = DateTime.parse(end);

      String format(DateTime dt) {
        final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
        final period = dt.hour >= 12 ? "PM" : "AM";
        final minute = dt.minute.toString().padLeft(2, '0');

        return "$hour:$minute $period";
      }

      return "${format(startDt)} – ${format(endDt)}";
    } catch (e) {
      return "";
    }
  }

  /// Formats date from ISO string
  String formatDate(String start) {
    try {
      final dt = DateTime.parse(start);
      return "${_month(dt.month)} ${dt.day}, ${dt.year}";
    } catch (e) {
      return "";
    }
  }

  String _month(int m) {
    const months = [
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
    return months[m - 1];
  }

  // ===============================
  // MOCK TOPIC RATIOS
  // ===============================
  /// Returns topic ratios for given result
  ///
  /// TODO (Backend):
  /// Replace with:
  /// result.aiResult.topicRatios
  Map<String, double> getTopicRatios(InterviewResult result) {
    // 🔥 MOCK DATA (şimdilik sabit)
    return {
      "react": 0.94,
      "typescript": 0.91,
      "css": 0.88,
    };
  }

  // ===============================
  // INTERVIEW → EXAM (REVIEW)
  // ===============================

  /// Builds an Exam object from interview result
  ///
  /// IMPORTANT:
  /// - Used for navigating to ExamReviewPage
  ///
  /// TODO (Backend):
  /// - Fetch real interview exam by interviewId
  /// - Include questions, answers, aiFeedback, stats
  Future<Exam> buildInterviewReviewExam(Map<String, dynamic> item) async {
    final InterviewResult result = item["result"];

    // =======================================================
    // 🔥 MOCK QUESTIONS (TEMPORARY)
    // =======================================================
    // TODO (Backend):
    // Replace with:
    // final questions = await api.getInterviewQuestions(result.interviewId);

    final questions = await _getMockQuestions();

    // =======================================================
    // 🔥 BUILD EXAM
    // =======================================================
    return Exam(
      id: "interview_${result.id}",
      title: item["title"] ?? "Interview",
      duration: const Duration(minutes: 10),

      questions: questions,

      // 🔥 VERY IMPORTANT FOR REVIEW PAGE
      answers: {},
      // TODO: backend will provide user answers
      aiFeedback: {},
      // TODO: backend will provide explanations
      stats: {
        "correct": result.correctCount ?? 0,
        "wrong": result.wrongCount ?? 0,
        "unanswered": result.unansweredCount ?? 0,
      },

      createdAt: DateTime.now(),
    );
  }

  // ===============================
  // MOCK QUESTION PROVIDER
  // ===============================

  Future<List<Question>> _getMockQuestions() async {
    // TODO (Backend):
    // Remove this and use real API

    try {
      // 🔥 Eğer senin projede zaten soru çekme varsa onu kullan
      final createExamController = Get.put(CreateExamController());
      return await createExamController.generateExamQuestions();
    } catch (e) {
      return [];
    }
  }
}
