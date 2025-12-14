// ===================== File: lib/pages/exam/controllers/exam_result_controller.dart =====================
// Purpose: ExamResultPage için verileri yönetir.
//          Exam, AiExamResult ve XP hesaplamalarını UI'a hazırlar.
// ========================================================================================================

import 'package:get/get.dart';
import '../../../models/exam.dart';
import '../../../models/ai_exam_result.dart';
import '../services/exam_xp_service.dart';

class ExamResultController extends GetxController {
  // ===============================
  // 🔹 Observable değerler (UI Binding)
  // ===============================
  final RxInt score = 0.obs;
  final RxInt correct = 0.obs;
  final RxInt wrong = 0.obs;
  final RxInt unanswered = 0.obs;

  final RxInt earnedXp = 0.obs; // 🔥 YENİ EKLENDİ

  final RxMap<String, int> topicPercentages = <String, int>{}.obs;

  Exam? exam;
  AiExamResult? aiResult;

  // ===============================
  // 🔹 Controller initialization
  // ===============================
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    exam = args['exam'] as Exam?;
    aiResult = args['aiResult'] as AiExamResult?;

    // ===============================
    // 1) AI sonuçlarını yükle
    // ===============================
    score.value = aiResult?.totalScore.round() ?? 0;
    correct.value = aiResult?.correctCount ?? 0;
    wrong.value = aiResult?.wrongCount ?? 0;
    unanswered.value = aiResult?.unansweredCount ?? 0;

    // Topic yüzdeleri
    if (aiResult?.topicPercentage.isNotEmpty ?? false) {
      topicPercentages.assignAll(aiResult!.topicPercentage);
    }

    // ===============================
    // 2) XP Hesaplama (AI varsa)
    // ===============================
    if (aiResult != null && exam != null) {
      earnedXp.value = ExamXpService.computeExamXp(
        exam: exam!,
        aiResult: aiResult!,
      );
    }

    // ===============================
    // 3) Fallback kuralları (AI yoksa)
    // ===============================
    final totalQ = exam?.questions.length ?? 0;
    final answeredQ = exam?.answers?.length ?? 0;
    final localUnans = (totalQ - answeredQ).clamp(0, totalQ);

    if (aiResult == null) {
      correct.value = 0;
      wrong.value = answeredQ;
      unanswered.value = localUnans;
      score.value = 0;
      earnedXp.value = 0; // XP olmadığı için
      topicPercentages.clear();
    } else {
      final aiSum = correct.value + wrong.value + unanswered.value;
      if (aiSum == 0 && (answeredQ > 0 || totalQ > 0)) {
        wrong.value = (answeredQ - correct.value).clamp(0, totalQ);
        unanswered.value = localUnans;
      } else {
        if (wrong.value == 0 && answeredQ > 0) {
          final computedWrong = answeredQ - correct.value;
          if (computedWrong >= 0) wrong.value = computedWrong;
        }
        if (totalQ > 0) {
          final computedUnans = totalQ - (correct.value + wrong.value);
          if (computedUnans >= 0) unanswered.value = computedUnans;
        }
      }
    }
  }

  // ===============================
  // 🔹 Yardımcı fonksiyonlar
  // ===============================

  int getTopicPercentage(String topic) {
    return topicPercentages[topic] ?? 0;
  }

  List<String> get topics => topicPercentages.keys.toList();

  bool get hasAiResult => aiResult != null;

  int get averagePercentage {
    if (topicPercentages.isEmpty) return 0;
    final total = topicPercentages.values.reduce((a, b) => a + b);
    return (total / topicPercentages.length).round();
  }

  Map<String, double> get topicRatios {
    final result = <String, double>{};
    for (final entry in topicPercentages.entries) {
      result[entry.key] = (entry.value / 100).clamp(0.0, 1.0);
    }
    return result;
  }
}
