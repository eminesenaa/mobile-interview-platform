// ===================== File: hr_candidate_result_controller.dart =====================
// Purpose:
// Controls HR Candidate Result Page using real interview data.
// ================================================================================

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../interviews/needs_review/hr_candidate_evaluation_page.dart';
import 'hr_needs_review_detail_controller.dart';

class HrCandidateResultController extends GetxController {
  final _db = FirebaseFirestore.instance;
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
  final decision = RxnString(); 

  // ===============================
  // TOPIC DATA
  // ===============================
  final topicPercentages = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();

    if (candidate != null) {
      _initFromCandidate(candidate!);
      _listenToResultUpdates();
    }
  }

  void _initFromCandidate(Map<String, dynamic> data) {
    score.value = (data["score"] ?? 0).toInt();
    
    // In a real scenario, these counts would come from the detailed answer list
    // For now, we use the values passed from the list or defaults
    correct.value = (data["correct"] ?? 0).toInt();
    wrong.value = (data["wrong"] ?? 0).toInt();
    unanswered.value = (data["unanswered"] ?? 0).toInt();

    candidateName.value = data["name"] ?? "Candidate";
    decision.value = data["decision"];

    final topics = data["topics"] as Map<String, dynamic>?;
    if (topics != null) {
      topicPercentages.assignAll(topics.map((key, value) => MapEntry(key, (value as num).toInt())));
    }
  }

  void _listenToResultUpdates() {
    final resultId = candidate?["resultId"];
    if (resultId == null) return;

    _db.collection('ai_interview_results').doc(resultId).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data()!;
        decision.value = data['decision'];
        
        // Update local candidate map to keep it in sync
        candidate?['decision'] = data['decision'];
      }
    });
  }

  Map<String, double> get topicRatios {
    final result = <String, double>{};
    for (final entry in topicPercentages.entries) {
      result[entry.key] = (entry.value / 100).clamp(0.0, 1.0);
    }
    return result;
  }

  Map<String, dynamic> get reviewExamData {
    return {
      "correct": correct.value,
      "wrong": wrong.value,
      "unanswered": unanswered.value,
      "questions": candidate?["questions"] ?? [],
    };
  }

  void openEvaluationPage() {
    Get.to(
      () => const HrCandidateEvaluationPage(),
      arguments: {
        ...?candidate,
        "interview": candidate?["interview"],
      },
    )?.then((result) {
      if (result != null && result["decision"] != null) {
        _updateDecision(result["decision"], result["message"] ?? "");
      }
    });
  }

  Future<void> _updateDecision(String newDecision, String message) async {
    final resultId = candidate?["resultId"];
    if (resultId == null) return;

    try {
      await _db.collection('ai_interview_results').doc(resultId).update({
        "decision": newDecision,
        "hrComment": message,
        "reviewedAt": FieldValue.serverTimestamp(),
      });
      
      decision.value = newDecision;
      candidate?["decision"] = newDecision;

      // Notify parent controller if it exists
      try {
        final parent = Get.find<HrNeedsReviewDetailController>();
        final index = parent.candidates.indexWhere((c) => c["resultId"] == resultId);
        if (index != -1) {
          parent.candidates[index]["decision"] = newDecision;
          parent.candidates.refresh();
        }
      } catch (_) {
        // Parent not found, ignore
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update decision: $e");
    }
  }
}
