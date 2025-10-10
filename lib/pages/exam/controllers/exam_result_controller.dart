// ===================== File: lib/pages/exam/controllers/exam_result_controller.dart =====================
// Purpose: ExamResultPage için verileri yönetir.
//          Exam ve AiExamResult modellerinden gelen verileri UI'a hazırlar.
// ========================================================================================================

import 'package:get/get.dart';
import '../../../models/exam.dart';
import '../../../models/ai_exam_result.dart';

class ExamResultController extends GetxController {
  // ===============================
  // 🔹 Observable değerler (UI Binding)
  // ===============================
  final RxInt score = 0.obs;
  final RxInt correct = 0.obs;
  final RxInt wrong = 0.obs;
  final RxInt unanswered = 0.obs;

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

    // ✅ 1) AI varsa değerleri kullan
    score.value = aiResult?.totalScore.round() ?? 0;
    correct.value = aiResult?.correctCount ?? 0;
    wrong.value = aiResult?.wrongCount ?? 0;
    unanswered.value = aiResult?.unansweredCount ?? 0;

    if (aiResult?.topicPercentage.isNotEmpty ?? false) {
      topicPercentages.assignAll(aiResult!.topicPercentage);
    }

// ✅ 2) Lokalde yanıtlanan soru sayısını hesapla (AI gelmese bile)
    final totalQ = exam?.questions.length ?? 0;
    final answeredQ = exam?.answers?.length ?? 0;
    final localUnans = (totalQ - answeredQ).clamp(0, totalQ);

// ✅ 3) Fallback kuralları
    if (aiResult == null) {
      // AI yoksa: correct=0, wrong=answered, unanswered=total-answered
      correct.value = 0;
      wrong.value = answeredQ;
      unanswered.value = localUnans;
      score.value = 0;
      if (topicPercentages.isNotEmpty) topicPercentages.clear();
    } else {
      // AI var ama toplamlar tutarsız/0 ise, lokalden türet
      final aiSum = correct.value + wrong.value + unanswered.value;
      if (aiSum == 0 && (answeredQ > 0 || totalQ > 0)) {
        wrong.value = (answeredQ - correct.value).clamp(0, totalQ);
        unanswered.value = localUnans;
      } else {
        // wrong yoksa answered-correct'ten türet
        if (wrong.value == 0 && answeredQ > 0) {
          final computedWrong = answeredQ - correct.value;
          if (computedWrong >= 0) wrong.value = computedWrong;
        }
        // unanswered yoksa total - (correct+wrong) olarak tamamla
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

  /// Konu bazlı başarı yüzdesini döndürür (örneğin "Java" -> 80)
  int getTopicPercentage(String topic) {
    return topicPercentages[topic] ?? 0;
  }

  /// Tüm topic isimlerini döndürür
  List<String> get topics => topicPercentages.keys.toList();

  /// AI sonucu var mı?
  bool get hasAiResult => aiResult != null;

  /// Ortalama başarı yüzdesi (isteğe bağlı)
  int get averagePercentage {
    if (topicPercentages.isEmpty) return 0;
    final total = topicPercentages.values.reduce((a, b) => a + b);
    return (total / topicPercentages.length).round();
  }

  /// ✅ TopicCharts widget'ı için uygun double oran döndürür
  /// (örnek: {"Java": 0.8, "Data Structures": 0.65})
  Map<String, double> get topicRatios {
    final result = <String, double>{};
    for (final entry in topicPercentages.entries) {
      result[entry.key] = (entry.value / 100).clamp(0.0, 1.0);
    }
    return result;
  }

}
