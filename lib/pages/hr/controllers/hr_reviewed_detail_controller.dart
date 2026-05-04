// ===================== File: hr_reviewed_detail_controller.dart =====================
// Purpose:
// Controls Reviewed Interview Detail Page
//
// IMPORTANT:
// - Uses mock data for now
// - Backend-ready structure
//
// TODO (Backend):
// - Fetch reviewed interview detail by ID
// - Fetch summary stats (accepted/rejected/total)
// - Fetch candidate list with decisions
// - Fetch insights (avg score, topic stats)
// ================================================================================

import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../../../models/ai_exam_result.dart';
import '../../../models/interview_result.dart';
import '../../../models/streak.dart';
import '../../../models/user.dart';
import '../../../models/user_library.dart';
import '../interviews/reviewed/hr_all_candidates_page.dart';
import '../interviews/reviewed/hr_candidate_detail_page.dart';
import '../interviews/reviewed/hr_insights_page.dart';

class HrReviewedDetailController extends GetxController {
  final Map<String, dynamic>? interview;

  HrReviewedDetailController({this.interview});

  // ===============================
  // 🔹 INTERVIEW INFO
  // ===============================
  final title = "".obs;
  final position = "".obs;
  final date = "".obs;
  final startTime = "".obs;
  final endTime = "".obs;
  final interviewId = "".obs;

  // ===============================
  // 🔹 SUMMARY DATA
  // ===============================
  final totalCandidates = 0.obs;
  final acceptedCount = 0.obs;
  final rejectedCount = 0.obs;

  // ===============================
  // 🔹 CANDIDATES
  // ===============================
  // final candidates = <Map<String, dynamic>>[].obs;
  final results = <InterviewResult>[].obs;

  // ===============================
  // 🔹 SELECTED CANDIDATE (DETAIL)
  // ===============================
  // final selectedCandidate = Rxn<Map<String, dynamic>>();
  final selectedResult = Rxn<InterviewResult>();

  // ===============================
  // 🔹 FILTER STATE
  // ===============================
  final selectedFilter = "all".obs; // all | accepted | rejected

  // ===============================
  // 🔹 LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();

    if (interview != null) {
      _initFromInterview(interview!);
    } else {
      _loadMockData();
    }

    // _assignRanks();

    // ===============================
    // TODO (Backend)
    // ===============================
    /*
    fetchReviewedInterviewDetail();
    fetchSummaryStats();
    fetchCandidates();
    fetchInsights();
    */
  }

  String get selectedName => selectedResult.value?.displayName ?? "";

  String get selectedInitials => selectedResult.value?.initials ?? "";

  int get selectedScore => selectedResult.value?.score ?? 0;

  String get selectedDecision =>
      selectedResult.value?.decision.name ?? "pending";

  int get selectedRank {
    final current = selectedResult.value;
    if (current == null) return 0;

    final index = rankedResults.indexOf(current);
    return index == -1 ? 0 : index + 1;
  }

  String get selectedSubtitle {
    final pos = position.value;
    return pos.isEmpty ? "Candidate" : "$pos · Candidate";
  }

  String get selectedDecisionDate {
    final d = selectedResult.value?.reviewedAt;

    if (d == null) return "Recently";

    return DateFormat("MMM d, yyyy 'at' h:mm a").format(d);
  }

  String get selectedMessage {
    final msg = selectedResult.value?.hrMessage;

    if (msg == null || msg.trim().isEmpty) {
      return selectedDecision == "accepted"
          ? "Congratulations! You have successfully passed the interview."
          : "Thank you for your time. We will not proceed further.";
    }

    return msg;
  }

  Map<String, int> get selectedTopics {
    final topics = selectedResult.value?.aiResult?.topicPercentage;

    if (topics == null || topics.isEmpty) {
      return {
        "react": 75,
        "typescript": 70,
        "css": 80,
        "system_design": 65,
      };
    }

    return topics;
  }

  // ===============================
  // 🔹 INIT FROM ARGS
  // ===============================
  void _initFromInterview(Map<String, dynamic> interview) {
    // TODO (Backend):
    // Map interview widgets to InterviewResult model list

    title.value = interview["title"] ?? "Interview";
    position.value = interview["position"] ?? "Position";
    date.value = interview["date"] ?? "";

    /// 🔥 TIME FIX
    startTime.value = interview["time"] ?? "";
    endTime.value = interview["endTime"] ?? "";

    interviewId.value =
        interview["id"] ?? interview["interviewId"] ?? "INT-UNKNOWN";

    // TODO (Backend):
    // widgets = interviewResults.map((json) => InterviewResult.fromJson(json)).toList();
    if (results.isEmpty) {
      _loadMockData();
      return;
    }

    _computeSummary();
  }

  // ===============================
  // 🔹 MOCK DATA
  // ===============================
  void _loadMockData() {
    title.value = "Frontend Developer Interview";
    position.value = "Senior Frontend Engineer";
    date.value = "Apr 14, 2025";
    startTime.value = "1:30 PM";
    endTime.value = "2:30 PM";
    interviewId.value = "INT-2025-FE-0044";

    results.assignAll([
      InterviewResult(
        id: "1",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user1",
        candidate: User(
          id: "user1",
          name: "Ethan",
          surname: "Brooks",
          username: "ethan",
          email: "ethan@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 95,
        correctCount: 18,
        wrongCount: 2,
        unansweredCount: 0,
        aiResult: AiExamResult(
          totalScore: 95,
          correctCount: 18,
          wrongCount: 2,
          unansweredCount: 0,
          topicPercentage: {
            "react": 94,
            "typescript": 91,
            "css": 88,
            "system_design": 78,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.accepted,
        hrMessage:
            "Excellent performance. Strong understanding of frontend architecture.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "2",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user2",
        candidate: User(
          id: "user2",
          name: "Olivia",
          surname: "Carter",
          username: "olivia",
          email: "olivia@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 92,
        correctCount: 17,
        wrongCount: 3,
        unansweredCount: 0,
        aiResult: AiExamResult(
          totalScore: 92,
          correctCount: 17,
          wrongCount: 3,
          unansweredCount: 0,
          topicPercentage: {
            "react": 90,
            "typescript": 93,
            "css": 87,
            "system_design": 80,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.accepted,
        hrMessage: "Great performance. Very consistent across topics.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "3",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user3",
        candidate: User(
          id: "user3",
          name: "Liam",
          surname: "Turner",
          username: "liam",
          email: "liam@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 89,
        correctCount: 16,
        wrongCount: 4,
        unansweredCount: 0,
        aiResult: AiExamResult(
          totalScore: 89,
          correctCount: 16,
          wrongCount: 4,
          unansweredCount: 0,
          topicPercentage: {
            "react": 88,
            "typescript": 85,
            "css": 90,
            "system_design": 76,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.accepted,
        hrMessage: "Strong candidate with good fundamentals.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "4",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user4",
        candidate: User(
          id: "user4",
          name: "Sophia",
          surname: "Mitchell",
          username: "sophia",
          email: "sophia@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 87,
        correctCount: 15,
        wrongCount: 4,
        unansweredCount: 1,
        aiResult: AiExamResult(
          totalScore: 87,
          correctCount: 15,
          wrongCount: 4,
          unansweredCount: 1,
          topicPercentage: {
            "react": 85,
            "typescript": 84,
            "css": 88,
            "system_design": 79,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.accepted,
        hrMessage: "Very solid widgets overall.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "5",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user5",
        candidate: User(
          id: "user5",
          name: "Noah",
          surname: "Bennett",
          username: "noah",
          email: "noah@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 84,
        correctCount: 14,
        wrongCount: 5,
        unansweredCount: 1,
        aiResult: AiExamResult(
          totalScore: 84,
          correctCount: 14,
          wrongCount: 5,
          unansweredCount: 1,
          topicPercentage: {
            "react": 82,
            "typescript": 80,
            "css": 86,
            "system_design": 75,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.accepted,
        hrMessage: "Good performance with minor gaps.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "6",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user6",
        candidate: User(
          id: "user6",
          name: "Isabella",
          surname: "Reed",
          username: "isabella",
          email: "isabella@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 80,
        correctCount: 13,
        wrongCount: 5,
        unansweredCount: 2,
        aiResult: AiExamResult(
          totalScore: 80,
          correctCount: 13,
          wrongCount: 5,
          unansweredCount: 2,
          topicPercentage: {
            "react": 78,
            "typescript": 82,
            "css": 80,
            "system_design": 74,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.accepted,
        hrMessage: "Above average but needs polish.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "7",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user7",
        candidate: User(
          id: "user7",
          name: "Mason",
          surname: "Hayes",
          username: "mason",
          email: "mason@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 76,
        correctCount: 12,
        wrongCount: 6,
        unansweredCount: 2,
        aiResult: AiExamResult(
          totalScore: 76,
          correctCount: 12,
          wrongCount: 6,
          unansweredCount: 2,
          topicPercentage: {
            "react": 74,
            "typescript": 70,
            "css": 78,
            "system_design": 72,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.rejected,
        hrMessage: "Needs improvement in core topics.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "8",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user8",
        candidate: User(
          id: "user8",
          name: "Ava",
          surname: "Collins",
          username: "ava",
          email: "ava@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 73,
        correctCount: 11,
        wrongCount: 7,
        unansweredCount: 2,
        aiResult: AiExamResult(
          totalScore: 73,
          correctCount: 11,
          wrongCount: 7,
          unansweredCount: 2,
          topicPercentage: {
            "react": 70,
            "typescript": 72,
            "css": 75,
            "system_design": 68,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.rejected,
        hrMessage: "Below expectations.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "9",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user9",
        candidate: User(
          id: "user9",
          name: "Lucas",
          surname: "Ward",
          username: "lucas",
          email: "lucas@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 69,
        correctCount: 10,
        wrongCount: 8,
        unansweredCount: 2,
        aiResult: AiExamResult(
          totalScore: 69,
          correctCount: 10,
          wrongCount: 8,
          unansweredCount: 2,
          topicPercentage: {
            "react": 68,
            "typescript": 66,
            "css": 72,
            "system_design": 65,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.rejected,
        hrMessage: "Insufficient performance.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
      InterviewResult(
        id: "10",
        interviewId: "INT-2025-FE-0044",
        candidateId: "user10",
        candidate: User(
          id: "user10",
          name: "Emily",
          surname: "Foster",
          username: "emily",
          email: "emily@test.com",
          streak: Streak.empty(),
          librarySummary: UserLibrary.empty(),
        ),
        score: 65,
        correctCount: 9,
        wrongCount: 9,
        unansweredCount: 2,
        aiResult: AiExamResult(
          totalScore: 65,
          correctCount: 9,
          wrongCount: 9,
          unansweredCount: 2,
          topicPercentage: {
            "react": 65,
            "typescript": 60,
            "css": 70,
            "system_design": 60,
          },
          questionEvaluations: const [],
        ),
        decision: InterviewDecisionStatus.rejected,
        hrMessage: "Not a good fit.",
        isSubmitted: true,
        isReviewed: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now(),
      ),
    ]);

    _computeSummary();
  }

  // ===============================
  // 🔹 COMPUTED DATA
  // ===============================
  void _computeSummary() {
    totalCandidates.value = results.length;

    acceptedCount.value = results
        .where((r) => r.decision == InterviewDecisionStatus.accepted)
        .length;

    rejectedCount.value = results
        .where((r) => r.decision == InterviewDecisionStatus.rejected)
        .length;
  }

  List<InterviewResult> get rankedResults {
    final sorted = results.toList()..sort((a, b) => b.score.compareTo(a.score));

    return List.generate(sorted.length, (i) {
      return sorted[i];
    });
  }

  int get acceptRate {
    if (totalCandidates.value == 0) return 0;
    return ((acceptedCount.value / totalCandidates.value) * 100).round();
  }

  double get avgScore {
    if (results.isEmpty) return 0;

    final total = results.fold<int>(0, (sum, r) => sum + r.score);
    return total / results.length;
  }

  int get highestScore {
    if (results.isEmpty) return 0;
    return results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  int get lowestScore {
    if (results.isEmpty) return 0;
    return results.map((r) => r.score).reduce((a, b) => a < b ? a : b);
  }

  Map<String, int> get topicAverages {
    final Map<String, List<int>> temp = {};

    for (var r in results) {
      final topics = r.aiResult?.topicPercentage ?? {};

      for (var entry in topics.entries) {
        temp.putIfAbsent(entry.key, () => []);
        temp[entry.key]!.add(entry.value);
      }
    }

    final Map<String, int> averages = {};

    temp.forEach((key, values) {
      final sum = values.reduce((a, b) => a + b);
      averages[key] = (sum / values.length).round();
    });

    return averages;
  }

  Map<String, int> get scoreDistribution {
    final Map<String, int> dist = {
      "90-100": 0,
      "80-89": 0,
      "70-79": 0,
      "60-69": 0,
      "Below 60": 0,
    };

    for (var r in results) {
      final s = r.score;

      if (s >= 90) {
        dist["90-100"] = dist["90-100"]! + 1;
      } else if (s >= 80) {
        dist["80-89"] = dist["80-89"]! + 1;
      } else if (s >= 70) {
        dist["70-79"] = dist["70-79"]! + 1;
      } else if (s >= 60) {
        dist["60-69"] = dist["60-69"]! + 1;
      } else {
        dist["Below 60"] = dist["Below 60"]! + 1;
      }
    }

    return dist;
  }

  // ===============================
  // 🔹 FILTERED DATA
  // ===============================
  List<InterviewResult> get filteredResults {
    final list = rankedResults;

    if (selectedFilter.value == "accepted") {
      return list
          .where((r) => r.decision == InterviewDecisionStatus.accepted)
          .toList();
    } else if (selectedFilter.value == "rejected") {
      return list
          .where((r) => r.decision == InterviewDecisionStatus.rejected)
          .toList();
    }

    return list;
  }

  List<InterviewResult> get topResults {
    final list = filteredResults;

    final sorted = list.toList()..sort((a, b) => b.score.compareTo(a.score));

    return sorted.take(5).toList();
  }

  // ===============================
  // 🔹 ACTIONS
  // ===============================

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void openCandidateDetail(InterviewResult result) {
    selectedResult.value = result;
    Get.to(() => const HrCandidateDetailPage());
  }

  void openAllCandidates() {
    Get.to(
      () => const HrAllCandidatesPage(),
    );
  }

  void openInsights() {
    Get.to(() => const HrInsightsPage());
  }

  void sortByScoreDesc() {
    final sorted = results.toList()..sort((a, b) => b.score.compareTo(a.score));

    results.assignAll(sorted);
  }

// ===============================
// TODO BACKEND METHODS
// ===============================
/*
  Future<void> fetchReviewedInterviewDetail() async {}

  Future<void> fetchSummaryStats() async {}

  Future<void> fetchCandidates() async {}

  Future<void> fetchInsights() async {}
  */
}
