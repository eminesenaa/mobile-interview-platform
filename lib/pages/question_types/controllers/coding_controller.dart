// ===================== File: lib/pages/question_types/controllers/coding_controller.dart =====================
// Purpose: Coding tipi sorular için hafif GetX controller.
//          - İlk ekranda sadece problem metni var; editor ayrı ekranda olacak.
//          - Runner'a payload & valid sinyali üretir.
// ===========================================================================================================

import 'package:get/get.dart';
import 'package:interview_project/models/question.dart';

typedef CodingAnswerChanged = void Function(Map<String, dynamic> payload, bool valid);

class CodingController extends GetxController {
  final Question question;
  final CodingAnswerChanged? onChanged;

  // Editor geldikten sonra doldurulacak:
  final RxString code = ''.obs;            // kullanıcının yazdığı kod
  final RxString language = 'dart'.obs;    // ileride soru/ayar ile güncellenebilir
  String? template;                        // ileride kullanırsak

  CodingController({
    required this.question,
    this.onChanged,
    this.template,
  });

  bool get isValid {
    // İlk sayfada kullanıcı kod yazmadığı için submit kapalı kalsın (false).
    // Editor geldikten sonra: code.trim().isNotEmpty yapacağız.
    return code.value.trim().isNotEmpty;
  }

  Map<String, dynamic> get payload => {
    'type': 'coding',
    'questionId': question.id,
    'lang': language.value,
    'code': code.value,
  };

  void notify() {
    onChanged?.call(payload, isValid);
  }

  @override
  void onInit() {
    super.onInit();
    // Başlangıçta valid=false bilgisini Runner'a gönder.
    notify();
  }

  // --- Bunlar editor geldiğinde kullanılacak yardımcılar ---
  void setCode(String v) {
    code.value = v;
    notify();
  }

  void setLanguage(String v) {
    language.value = v;
    notify();
  }

  void applyTemplate(String v) {
    template = v;
    code.value = v;
    notify();
  }
}
