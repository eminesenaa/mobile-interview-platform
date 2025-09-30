import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../utils/code_template_sanitizer.dart';
import '../../../utils/language_mapper.dart';
import '../../runner/controller/question_runner_controller.dart';

class CodingController extends GetxController {
  final Question question;

  late CodeController codeController;

  /// Kullanıcının güncel yazdığı kod
  final RxString currentCode = ''.obs;

  final RxBool hasEdited = false.obs; // <— yeni
  late final String _initialCode; // <— yeni

  CodingController(this.question);

  @override
  void onInit() {
    super.onInit();

    // Başlangıç kodu (soruda codeTemplate varsa onu al, yoksa boş string)
    final starterRaw = question.codeTemplate ?? '';
    final starter = CodeTemplateSanitizer.sanitize(starterRaw);
    _initialCode = starter;

    // topic alanı dili temsil ediyor: C, Java, Python...
    final language = _mapTopicToLanguage(question.topic);

    codeController = CodeController(
      text: starter,
      language: mapTopicToMode(question.topic),
    );
    // ilk set:
    currentCode.value = codeController.text;
    hasEdited.value = (codeController.text != _initialCode);

    // + Her değişimde hem local state’i hem runner.canSubmit’i güncelle
    codeController.addListener(() {
      final text = codeController.text;
      currentCode.value = text;
      hasEdited.value = (text != _initialCode);
      if (Get.isRegistered<QuestionRunnerController>()) {
        Get.find<QuestionRunnerController>().setCanSubmit(hasEdited.value);
      }
    });

    // Kod değiştikçe güncelle
    codeController.addListener(() {
      currentCode.value = codeController.text;
      hasEdited.value = (codeController.text != _initialCode); // <— yeni
    });

    currentCode.value = starter;
  }

  /// Kullanıcının yazdığı kodu döndür
  String getCode() => currentCode.value;

  bool get edited => hasEdited.value; // <— opsiyonel getter

  /// Kod güncelle
  void setCode(String code) {
    codeController.text = code;
    currentCode.value = code;
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  /// topic -> flutter_code_editor dili eşleme
  String _mapTopicToLanguage(String? topic) {
    if (topic == null) return 'plaintext';
    switch (topic.toLowerCase()) {
      case 'java':
        return 'java';
      case 'c':
      case 'c / c++':
      case 'c++':
        return 'cpp';
      case 'python':
        return 'python';
      case 'dart':
        return 'dart';
      default:
        return 'plaintext';
    }
  }
}
