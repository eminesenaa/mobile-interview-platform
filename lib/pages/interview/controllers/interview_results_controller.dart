// ===================== File: interview_results_controller.dart =====================
// Purpose:
// Controls Interview Results (View All page)
//
// Responsibilities:
// - Hold all interview widgets
// - Manage search & filter state
// - Provide grouped & sorted data
//
// IMPORTANT:
// - Uses mock data for now
// - Fully backend-ready structure
//
// TODO (Backend):
// - Fetch interview widgets from API / Firestore
// - Support pagination
// - Add real-time updates (optional)
// - Replace mock filtering with server-side filtering
// - Replace Map structure with full relational models (Interview + JobPosting)
// ================================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// All interview widgets (mock data)
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
    _listenToResults();
  }

  void _listenToResults() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('ai_interview_results')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .listen((snap) async {
      final List<Map<String, dynamic>> updatedResults = [];

      for (var doc in snap.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Try to fetch related job posting info if missing
        if (data['company'] == null || data['company'] == "Company" || data['startTime'] == null) {
          final String? interviewId = data['interviewId'];
          if (interviewId != null && interviewId.isNotEmpty) {
            final interviewSnap = await FirebaseFirestore.instance
                .collection('interviews')
                .doc(interviewId)
                .get();

            if (interviewSnap.exists) {
              final iData = interviewSnap.data();
              data['startTime'] = iData?['startTime'];
              data['endTime'] = iData?['endTime'];
              
              final String? jobPostingId = iData?['jobPostingId'] ?? data['jobPostingId'];
              if (jobPostingId != null && jobPostingId.isNotEmpty) {
                final postingSnap = await FirebaseFirestore.instance
                    .collection('job_postings')
                    .doc(jobPostingId)
                    .get();

                if (postingSnap.exists) {
                  final pData = postingSnap.data();
                  data['company'] = pData?['company'] ?? data['company'] ?? "Company";
                  data['location'] = pData?['location'] ?? data['location'] ?? "";
                  data['title'] = pData?['title'] ?? data['title'] ?? "Interview";
                }
              }
            }
          }

          // Fallback to applications if still missing
          if (data['company'] == null) {
            final applicationSnap = await FirebaseFirestore.instance
                .collection('applications')
                .where('candidateId', isEqualTo: user.uid)
                .where('jobPostingId', isEqualTo: data['jobPostingId'])
                .limit(1)
                .get();

            if (applicationSnap.docs.isNotEmpty) {
              final appData = applicationSnap.docs.first.data();
              data['title'] = appData['jobTitle'] ?? data['title'] ?? "Unknown Position";
              data['company'] = appData['company'] ?? "Company";
              data['location'] = appData['location'] ?? "";
              if (data['startTime'] == null) {
                data['startTime'] = appData['appliedAt'];
              }
            }
          }
        }

        // Convert Firestore data to InterviewResult model if needed, 
        // or just keep it as a map if the UI expects specific fields.
        // For now, let's keep the structure the UI expects.
        if (data['result'] == null) {
          try {
            data['result'] = InterviewResult.fromJson(data);
          } catch (e) {
            print("Error parsing interview result in results controller: $e");
          }
        }

        updatedResults.add(data);
      }
      results.value = updatedResults;
    });
  }

  InterviewDecisionStatus _parseDecision(dynamic decision) {
    if (decision == null) return InterviewDecisionStatus.pending;
    final d = decision.toString().toLowerCase();
    if (d == "accepted") return InterviewDecisionStatus.accepted;
    if (d == "rejected") return InterviewDecisionStatus.rejected;
    return InterviewDecisionStatus.pending;
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
    final InterviewResult result = item["result"] ?? InterviewResult.fromJson(item);

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

  /// Returns filtered + searched + sorted widgets
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

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Formats time range from ISO strings
  String formatTimeRange(dynamic start, dynamic end) {
    try {
      final startDt = _parseDateTime(start);
      final endDt = _parseDateTime(end);
      if (startDt == null || endDt == null) return "";

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
  String formatDate(dynamic start) {
    try {
      final dt = _parseDateTime(start);
      if (dt == null) return "";
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
  /// Uses real AI evaluation data when available,
  /// falls back to mock data otherwise.
  ///
  /// TODO (Backend):
  /// Once all interviews flow through AI evaluation,
  /// remove the mock fallback.
  Map<String, double> getTopicRatios(InterviewResult result) {
    // 🔥 Use real AI data if available
    if (result.aiResult != null) {
      final tp = result.aiResult!.topicPercentage;
      if (tp.isNotEmpty) {
        return tp.map((key, value) => MapEntry(key, value / 100.0));
      }
    }

    // 🔥 MOCK DATA fallback (until backend is connected)
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
    final InterviewResult result = item["result"] ?? InterviewResult.fromJson(item);

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
