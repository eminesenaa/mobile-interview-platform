import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/exam.dart';
import '../../../models/question.dart';
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
    score.value = (data["score"] ?? data["totalScore"] ?? 0).toInt();
    
    final aiResult = data["aiResult"];
    if (aiResult is Map) {
      correct.value = (aiResult["correctCount"] ?? 0).toInt();
      wrong.value = (aiResult["wrongCount"] ?? 0).toInt();
      unanswered.value = (aiResult["unansweredCount"] ?? 0).toInt();
    } else {
      correct.value = (data["correct"] ?? data["correctCount"] ?? 0).toInt();
      wrong.value = (data["wrong"] ?? data["wrongCount"] ?? 0).toInt();
      unanswered.value = (data["unanswered"] ?? data["unansweredCount"] ?? 0).toInt();
    }

    candidateName.value = data["name"] ?? "Candidate";
    decision.value = data["decision"];

    final topics = data["topics"];
    if (topics is Map) {
      topicPercentages.assignAll(topics.map((key, value) => MapEntry(key.toString(), (value as num).toInt())));
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

  Exam get reviewExam {
    final interviewData = candidate?["interview"] as Map<String, dynamic>? ?? {};
    final List<dynamic> rawQuestions = interviewData["questions"] as List<dynamic>? ?? [];
    
    final List<Question> questionsList = [];
    for (int i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i] as Map<String, dynamic>;
      final rawId = q['id']?.toString() ?? '';
      final id = rawId.isNotEmpty ? rawId : 'q_$i';
      questionsList.add(Question.fromFirestore(q, id));
    }

    final Map<String, dynamic> answersMap = {};
    final rawAnswers = candidate?["answers"];
    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        answersMap[key.toString()] = value;
      });
    }

    // Populate feedback and stats lists
    final Map<String, String> feedbackMap = {};
    final List<String> correctIds = [];
    final List<String> wrongIds = [];
    
    final aiResult = candidate?['aiResult'];
    if (aiResult is Map) {
      final qResults = aiResult['questionResults'] as List?;
      if (qResults != null) {
        for (final qr in qResults) {
          if (qr is Map) {
            final qid = qr['questionId']?.toString();
            if (qid != null) {
              final qDecision = qr['decision']?.toString() ?? '';
              final qScore = qr['overall_score']?.toString() ?? '0';
              final strengths = List<String>.from(qr['strengths'] ?? []);
              final weaknesses = List<String>.from(qr['weaknesses'] ?? []);
              final redFlags = List<String>.from(qr['red_flags'] ?? []);
              
              final coaching = qr['coaching_tips'];
              String personal = '';
              if (coaching is Map) {
                personal = coaching['personalized_feedback']?.toString() ?? '';
              }

              final buffer = StringBuffer();
              buffer.writeln("Decision: ${qDecision.toUpperCase()} (Score: $qScore/5)\n");
              if (personal.isNotEmpty) {
                buffer.writeln("$personal\n");
              }
              if (strengths.isNotEmpty) {
                buffer.writeln("Strengths:");
                for (final s in strengths) {
                  buffer.writeln("• $s");
                }
                buffer.writeln();
              }
              if (weaknesses.isNotEmpty) {
                buffer.writeln("Weaknesses:");
                for (final w in weaknesses) {
                  buffer.writeln("• $w");
                }
                buffer.writeln();
              }
              if (redFlags.isNotEmpty) {
                buffer.writeln("Red Flags:");
                for (final rf in redFlags) {
                  buffer.writeln("⚠️ $rf");
                }
              }
              feedbackMap[qid] = buffer.toString().trim();

              if (qDecision == 'advance') {
                correctIds.add(qid);
              } else if (qDecision == 'reject') {
                wrongIds.add(qid);
              }
            }
          }
        }
      }
    }

    return Exam(
      id: candidate?["resultId"] ?? "review_exam",
      title: candidate?["interviewTitle"] ?? "Candidate Review",
      duration: Duration(minutes: questionsList.length),
      questions: questionsList,
      createdAt: DateTime.now(),
      answers: answersMap,
      aiFeedback: feedbackMap,
      stats: {
        'correct': correct.value,
        'wrong': wrong.value,
        'unanswered': unanswered.value,
        'correctIds': correctIds,
        'wrongIds': wrongIds,
      },
      isInterview: true,
    );
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
