// lib/pages/exam/controllers/exam_coding_controller.dart

import 'package:get/get.dart';

class ExamCodingController extends GetxController {
  /// Kullanıcının yazdığı kodu tutar
  final RxString code = ''.obs;

  /// Editör açık mı (submit butonunu bloklamak için)
  final RxBool isEditorOpen = false.obs;

  /// Kod güncelleme
  void updateCode(String newCode) {
    code.value = newCode;
  }

  /// Kod temizleme
  void clearCode() {
    code.value = '';
  }

  /// Kod alma (submit sırasında)
  String getCode() => code.value;
}
