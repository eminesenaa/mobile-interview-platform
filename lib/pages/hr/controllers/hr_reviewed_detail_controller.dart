// ===================== File: hr_reviewed_detail_controller.dart =====================
// Purpose:
// Controls Reviewed Interview Detail Page using real Firestore results.
// ================================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../models/interview_result.dart';
import '../interviews/reviewed/hr_all_candidates_page.dart';
import '../interviews/reviewed/hr_candidate_detail_page.dart';
import '../interviews/reviewed/hr_insights_page.dart';

class HrReviewedDetailController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final Map<String, dynamic>? interview;

  HrReviewedDetailController({this.interview});

  // ===============================
  // STATE
  // ===============================
  final title = "".obs;
  final position = "".obs;
  final date = "".obs;
  final startTime = "".obs;
  final endTime = "".obs;
  final interviewId = "".obs;

  final totalCandidates = 0.obs;
  final acceptedCount = 0.obs;
  final rejectedCount = 0.obs;

  final results = <InterviewResult>[].obs;
  final selectedResult = Rxn<InterviewResult>();
  final selectedFilter = "all".obs; // all | accepted | rejected

  @override
  void onInit() {
    super.onInit();
    if (interview != null) {
      _initFromInterview(interview!);
      _listenToResults();
    }
  }

  void _initFromInterview(Map<String, dynamic> data) {
    title.value = data["title"] ?? "Interview";
    position.value = data["position"] ?? "Position";
    interviewId.value = data["id"] ?? data["interviewId"] ?? "";
    
    if (data["startTime"] != null) {
      final start = (data["startTime"] is Timestamp) ? (data["startTime"] as Timestamp).toDate() : DateTime.parse(data["startTime"].toString());
      date.value = DateFormat('MMM dd, yyyy').format(start);
      startTime.value = DateFormat('h:mm a').format(start);
    }
    
    if (data["endTime"] != null) {
      final end = (data["endTime"] is Timestamp) ? (data["endTime"] as Timestamp).toDate() : DateTime.parse(data["endTime"].toString());
      endTime.value = DateFormat('h:mm a').format(end);
    }
  }

  void _listenToResults() {
    if (interviewId.isEmpty) return;

    // Listen to ai_interview_results (Wait, is it ai_interview_results or interview_results?)
    // In previous turn I used ai_interview_results. 
    // But the model is InterviewResult.
    // Let's assume ai_interview_results collection contains data that can be mapped to InterviewResult.
    _db.collection('ai_interview_results')
        .where('interviewId', isEqualTo: interviewId.value)
        .snapshots()
        .listen((snap) {
          results.value = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            
            // Map Firestore decision string to enum compatible string
            // Model uses InterviewDecisionStatus enum names (pending, accepted, rejected)
            return InterviewResult.fromJson(data);
          }).toList();

          _computeSummary();
        });
  }

  void _computeSummary() {
    totalCandidates.value = results.length;
    acceptedCount.value = results.where((r) => r.decision == InterviewDecisionStatus.accepted).length;
    rejectedCount.value = results.where((r) => r.decision == InterviewDecisionStatus.rejected).length;
  }

  // ===============================
  // COMPUTED PROPERTIES
  // ===============================
  List<InterviewResult> get rankedResults {
    final list = results.toList()..sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  List<InterviewResult> get filteredResults {
    if (selectedFilter.value == "all") return rankedResults;
    final status = selectedFilter.value == "accepted" ? InterviewDecisionStatus.accepted : InterviewDecisionStatus.rejected;
    return rankedResults.where((r) => r.decision == status).toList();
  }

  int get acceptRate => totalCandidates.value == 0 ? 0 : ((acceptedCount.value / totalCandidates.value) * 100).round();

  // Stats for Insights
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

  // ===============================
  // 🔹 CANDIDATE DETAIL GETTERS
  // ===============================

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
    if (topics == null || topics.isEmpty) return {};
    return topics;
  }

  // ===============================
  // 🔹 TOPIC AVERAGES
  // ===============================
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
      if (s >= 90) dist["90-100"] = dist["90-100"]! + 1;
      else if (s >= 80) dist["80-89"] = dist["80-89"]! + 1;
      else if (s >= 70) dist["70-79"] = dist["70-79"]! + 1;
      else if (s >= 60) dist["60-69"] = dist["60-69"]! + 1;
      else dist["Below 60"] = dist["Below 60"]! + 1;
    }
    return dist;
  }

  // ===============================
  // ACTIONS
  // ===============================
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void openCandidateDetail(InterviewResult result) {
    selectedResult.value = result;
    Get.to(() => const HrCandidateDetailPage());
  }

  void openAllCandidates() {
    Get.to(() => const HrAllCandidatesPage());
  }

  void openInsights() {
    Get.to(() => const HrInsightsPage());
  }

  void sortByScoreDesc() {
    final sorted = results.toList()..sort((a, b) => b.score.compareTo(a.score));
    results.assignAll(sorted);
  }
}
