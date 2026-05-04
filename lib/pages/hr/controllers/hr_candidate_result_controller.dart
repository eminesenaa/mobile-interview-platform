// ===================== File: hr_candidate_result_controller.dart =====================
// Purpose:
// Controls HR Candidate Result Page
//
// IMPORTANT:
// - Uses mock data for now
// - Backend-ready structure
//
// TODO (Backend):
// - Fetch candidate interview result by ID
// - Fetch topic scores
// - Fetch detailed answers for review page
// - Send evaluation decision (accept/reject)
// ================================================================================

import 'package:get/get.dart';

import '../interviews/needs_review/hr_candidate_evaluation_page.dart';
import 'hr_needs_review_detail_controller.dart';

class HrCandidateResultController extends GetxController {
  final Map<String, dynamic>? candidate;

  HrCandidateResultController({this.candidate});

  // ===============================
  // BASE RESULT DATA
  // ===============================
  final score = 0.obs;
  final correct = 0.obs;
  final wrong = 0.obs;
  final unanswered = 0.obs;
  final candidateName = "".obs;

  final decision = RxnString(); // "accepted" | "rejected" | null

  // ===============================
  // TOPIC DATA
  // ===============================
  final topicPercentages = <String, int>{}.obs;

  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();

    if (candidate != null) {
      _initFromCandidate(candidate!);
    } else {
      loadMockData();
    }

    // ===============================
    // TODO (Backend)
    // ===============================
    /*
  fetchCandidateResult();
  */
  }

  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    score.value = 78;
    correct.value = 18;
    wrong.value = 6;
    unanswered.value = 2;
    candidateName.value = "John Doe";
    decision.value = null; // test için

    topicPercentages.assignAll({
      "SQL": 85,
      "Machine Learning": 70,
      "C": 60,
      "Data Structures": 75,
    });
  }

  void _initFromCandidate(Map<String, dynamic> candidate) {
    score.value = candidate["score"] ?? 0;

    /// 🔥 basit mock hesap (backend gelince değişir)
    correct.value = 18;
    wrong.value = 6;
    unanswered.value = 2;

    candidateName.value = candidate["name"] ?? "Candidate";

    decision.value = candidate["decision"];

    /// 🔥 topicleri direkt candidate’tan al
    final topics = candidate["topics"] as Map<String, int>?;

    if (topics != null) {
      topicPercentages.assignAll(topics);
    }
  }

  // ===============================
  // DERIVED DATA (UI)
  // ===============================

  /// Topic ratios for charts (0.0 - 1.0)
  Map<String, double> get topicRatios {
    final result = <String, double>{};

    for (final entry in topicPercentages.entries) {
      result[entry.key] = (entry.value / 100).clamp(0.0, 1.0);
    }

    return result;
  }

  // ===============================
  // REVIEW DATA (for answer page)
  // ===============================

  /// ExamReviewPage'e gönderilecek mock data
  Map<String, dynamic> get reviewExamData {
    return {
      "correct": correct.value,
      "wrong": wrong.value,
      "unanswered": unanswered.value,

      // TODO backend:
      // full question/answer list
    };
  }

  // ===============================
  // ACTIONS
  // ===============================

  void openReviewPage() {
    // TODO (Navigation)
    /*
    Get.toNamed('/candidate-review', arguments: reviewExamData);
    */
  }

  void openEvaluationPage() {
    Get.to(
      () => const HrCandidateEvaluationPage(),
      arguments: {
        ...?candidate,
        "interview": {
          "title": candidate?["interviewTitle"],
          "date": candidate?["interviewDate"],
        },
      },
    )?.then((result) {
      if (result != null && result["decision"] != null) {
        decision.value = result["decision"];

        /// 🔥 candidate içine de yaz (persist)
        candidate?["decision"] = result["decision"];

        /// 🔥 NeedsReview controller'ı bul
        final parent = Get.find<HrNeedsReviewDetailController>();

        /// 🔥 listede güncelle
        final index = parent.candidates.indexWhere(
              (c) => c["name"] == candidate?["name"],
        );

        if (index != -1) {
          parent.candidates[index]["decision"] = result["decision"];
          parent.candidates.refresh(); // 🔥 UI refresh
        }
      }
    });
  }

// ===============================
// TODO BACKEND METHODS
// ===============================
/*
  Future<void> fetchCandidateResult() async {}

  Future<void> fetchTopicScores() async {}

  Future<void> fetchAnswers() async {}

  Future<void> sendEvaluation({
    required bool accepted,
    required String message,
  }) async {}
  */
}
