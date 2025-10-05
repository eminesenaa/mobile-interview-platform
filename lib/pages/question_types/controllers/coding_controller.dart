// lib/pages/question_types/controllers/coding_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import '../../../utils/code_template_sanitizer.dart';
import '../../../utils/language_mapper.dart';
import '../../runner/controller/question_runner_controller.dart';

// 🔥 Streak importları
import '../../../models/streak.dart';
import '../../../controllers/auth_controller.dart';

class CodingController extends GetxController {
  final Question question;

  late CodeController codeController;
  final RxString currentCode = ''.obs;
  final RxBool hasEdited = false.obs;
  late final String _initialCode;

  final AiService _ai = Get.find<AiService>();
  final isEvaluating = false.obs;
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);
  final aiFeedback = ''.obs;
  final earnedXp = 0.obs;

  CodingController(this.question);

  @override
  void onInit() {
    super.onInit();

    final starterRaw = question.codeTemplate ?? '';
    final starter = CodeTemplateSanitizer.sanitize(starterRaw);
    _initialCode = starter;

    final language = _mapTopicToLanguage(question.topic);

    codeController = CodeController(
      text: starter,
      language: mapTopicToMode(question.topic),
    );

    currentCode.value = codeController.text;
    hasEdited.value = (codeController.text != _initialCode);

    codeController.addListener(() {
      final text = codeController.text;
      currentCode.value = text;
      hasEdited.value = (text != _initialCode);

      if (Get.isRegistered<QuestionRunnerController>()) {
        Get.find<QuestionRunnerController>().setCanSubmit(hasEdited.value);
      }
    });

    currentCode.value = starter;
  }

  String getCode() => currentCode.value;
  bool get edited => hasEdited.value;

  void setCode(String code) {
    codeController.text = code;
    currentCode.value = code;
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

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

  Future<void> evaluateWithAi() async {
    final code = currentCode.value.trim();
    if (code.isEmpty) {
      Get.snackbar('Empty code', 'Please write some code before sending.');
      return;
    }

    isEvaluating.value = true;
    try {
      final res = await _ai.evaluate(question: question, userAnswer: code);
      aiMeta.value = res;

      // 🔹 XP hesaplama
      final baseXp = question.xp;
      final normalized = (res.score ?? 0) / 5.0;
      final xp = (normalized * baseXp).round();
      earnedXp.value = xp;

      final verdict = res.correct ? "✅ Correct." : "❌ Incorrect.";
      final explain = res.explanation.isNotEmpty ? "\n${res.explanation}" : "";
      aiFeedback.value = "$verdict$explain\n\n⭐ You earned: $xp XP";

      // 🔹 Firestore’a kaydet
      await _saveResultToFirestore(res, xp);
    } catch (e, st) {
      print("❌ AI error (coding): $e\n$st");
      Get.snackbar("AI error", e.toString());
    } finally {
      isEvaluating.value = false;
    }
  }

  // 🔹 Firestore XP + Streak kaydı
  Future<void> _saveResultToFirestore(
      AiEvaluateResult res, int earnedXp) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final solvedRef = userRef.collection('solved').doc(question.id);
      final snap = await solvedRef.get();

      final newScore = (res.score ?? 0).toDouble();

      if (snap.exists) {
        final data = snap.data() ?? {};
        final prevScore = (data['score'] as num?)?.toDouble() ?? 0.0;
        final prevXp = (data['xpEarned'] as num?)?.toInt() ?? 0;

        if (newScore > prevScore) {
          final xpDiff = earnedXp - prevXp;
          if (xpDiff > 0) {
            await userRef.update({'totalXp': FieldValue.increment(xpDiff)});
          }

          await solvedRef.update({
            'score': newScore,
            'xpEarned': earnedXp,
            'lastAttempt': FieldValue.serverTimestamp(),
          });
        } else {
          await solvedRef.update({
            'lastAttempt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await userRef.update({'totalXp': FieldValue.increment(earnedXp)});

        await solvedRef.set({
          'status': 'solved',
          'score': newScore,
          'xpEarned': earnedXp,
          'solvedAt': FieldValue.serverTimestamp(),
        });
      }

      // 🔥 STREAK GÜNCELLE 🔥
      try {
        final auth = Get.find<AuthController>();
        final currentUser = auth.user;
        final uidToUse =
            currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;

        if (uidToUse != null) {
          await Streak.updateStreak(uidToUse);
          print("🔥 [Coding] Streak updated successfully for user=$uidToUse");
        } else {
          print("⚠️ [Coding] Streak update skipped (no uid)");
        }
      } catch (e, st) {
        print("❌ [Coding] Streak update error: $e\n$st");
      }
    } catch (e, st) {
      print("❌ Firestore save error (coding): $e\n$st");
    }
  }
}
