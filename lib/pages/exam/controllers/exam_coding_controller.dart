// lib/pages/exam/controllers/exam_coding_controller.dart

import 'package:get/get.dart';

import 'exam_controller.dart';

class ExamCodingController extends GetxController {
  /// Kullanıcının yazdığı kodu tutar
  final RxString code = ''.obs;

  /// Editör açık mı (submit butonunu bloklamak için)
  final RxBool isEditorOpen = false.obs;

  /// Kod güncelleme
  // void updateCode(String newCode) {
  //   code.value = newCode;
  // }

  /// Kod temizleme
  void clearCode() {
    code.value = '';
  }

  /// Kod alma (submit sırasında)
  String getCode() => code.value;

  /// ✅ Yeni: Kod değiştiğinde ExamController’a da kaydet
  void updateCode(String newCode, String examId, String questionId) {
    code.value = newCode;

    // Eğer sınav kontrolcüsü aktifse, oraya da kaydet
    if (Get.isRegistered<ExamController>(tag: examId)) {
      final examController = Get.find<ExamController>(tag: examId);
      examController.saveAnswer(questionId, newCode);
    }
  }

  /// ✅ Kod kaydını dışarıdan tetiklemek için basit helper
  void syncWithExam(String examId, String questionId) {
    if (Get.isRegistered<ExamController>(tag: examId)) {
      final examController = Get.find<ExamController>(tag: examId);
      final existing = examController.answers[questionId];
      if (existing is String && existing.isNotEmpty) {
        code.value = existing;
      }
    }
  }

}
