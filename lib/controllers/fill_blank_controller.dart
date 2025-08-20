import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/question.dart';

class FillBlankController extends GetxController {
  FillBlankController(this.question);

  final Question question;

  // --- Parsed metin (tek boşluk: ***)
  final left = ''.obs;
  final right = ''.obs;

  // --- Kullanıcı seçimi / seçenekler
  final filled = RxnString();
  final choices = <String>[].obs;

  // --- Durum bayrakları
  final attemptedWrongOnce = false.obs;
  final showAnswer = false.obs;
  final isCorrect = false.obs;

  // --- UI yardımcıları
  final bottomSheetOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _parseSingleBlank();
    _buildChoices();
  }

  void _parseSingleBlank() {
    final text = (question.description?.isNotEmpty ?? false)
        ? question.description!
        : question.title;

    const token = '***';
    final i = text.indexOf(token);

    if (i == -1) {
      left.value = text;
      right.value = '';
    } else {
      left.value = text.substring(0, i);
      right.value = text.substring(i + token.length);
    }
  }

  void _buildChoices() {
    final base = (question.options != null && question.options!.isNotEmpty)
        ? question.options!
        : [question.correctAnswer ?? ''];
    final list = base.map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
      ..shuffle();
    choices.assignAll(list);
  }

  void place(String word) {
    // Varsa mevcut kelimeyi choices’a iade et
    final current = filled.value;
    if (current != null && current.trim().isNotEmpty) {
      choices.add(current);
    }

    // Seçilen kelimeyi choices’tan çıkar
    final idx = choices.indexWhere((c) => _norm(c) == _norm(word));
    if (idx != -1) choices.removeAt(idx);

    filled.value = word;
  }

  void reset() {
    final current = filled.value;
    if (current != null && current.trim().isNotEmpty) {
      choices.add(current);
    }
    // temizle
    filled.value = null;
    attemptedWrongOnce.value = false;
    showAnswer.value = false;
    isCorrect.value = false;

    // tekrarları sadeleştir
    choices.assignAll(choices.toSet().toList());
  }

  void check() {
    final user = filled.value;
    if (user == null || user.trim().isEmpty) {
      Get.snackbar('Eksik', 'Boşluğu doldur lütfen.',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      return;
    }

    final correct = question.correctAnswer ?? '';
    final ok = _norm(user) == _norm(correct);

    if (ok) {
      isCorrect.value = true;

      // (opsiyonel) solved/statü güncellemesi:
      // try { Get.find<QuestionController>().updateStatus(question.id, Status.solved); } catch (_) {}

      Get.snackbar('Tebrikler 🎉', 'Doğru cevap!',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } else {
      if (!attemptedWrongOnce.value) {
        attemptedWrongOnce.value = true;

        // İlk yanlışta input’u temizle ve seçimi geri havuza koy
        final cur = filled.value;
        if (cur != null && cur.trim().isNotEmpty) choices.add(cur);
        filled.value = null;

        Get.snackbar('Tekrar dene ✍️', 'Ufak bir yazım hatası/yanlış seçim olabilir.',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Yanlış', 'İstersen "Show answer" ile doğru cevabı görebilirsin.',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      }
    }
  }

  Future<void> pickFromBottomSheet() async {
    if (choices.isEmpty || bottomSheetOpen.value) return;
    bottomSheetOpen.value = true;
    final picked = await showModalBottomSheet<String>(
      context: Get.context!,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: choices
              .map((w) => ListTile(
            title: Text(w),
            onTap: () => Navigator.pop(Get.context!, w),
          ))
              .toList(),
        ),
      ),
    );
    bottomSheetOpen.value = false;

    if (picked != null) place(picked);
  }

  String _norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
