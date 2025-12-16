import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/ai_exam_result.dart';
import 'package:interview_project/models/ai_question_evaluation.dart';
import 'package:interview_project/pages/question_types/services/xp_service.dart';

class ExamXpService {
  /// ===========================
  ///  XP Hesaplama (Var olan fonksiyon)
  /// ===========================
  static int computeExamXp({
    required Exam exam,
    required AiExamResult aiResult,
  }) {
    int totalXp = 0;

    for (final q in exam.questions) {
      final qIndex = exam.questions.indexOf(q);

      final eval = aiResult.questionEvaluations.firstWhere(
        (e) => e.index == qIndex,
        orElse: () => AiExamQuestionEvaluation(
          generalIndex: q.id,
          index: qIndex,
          verdict: 'unanswered',
        ),
      );

      final score = _verdictToScore(eval.verdict);

      final xp = XpService.computeXp(
        baseXp: q.xp,
        score: score,
      );

      totalXp += xp;
    }

    return totalXp;
  }

  static int _verdictToScore(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'correct':
        return 5;
      case 'wrong':
      case 'unanswered':
      default:
        return 0;
    }
  }

  /// ===========================
  /// 🔥 Firestore’a Exam Sonucu Yazma (EKLENEN METOT)
  /// ===========================
  static Future<void> saveExamResult({
    required Exam exam,
    required AiExamResult aiResult,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final totalXp = computeExamXp(exam: exam, aiResult: aiResult);

      final userRef = FirebaseFirestore.instance.collection("users").doc(uid);

      // 🔹 Kullanıcı XP’sini arttır
      await userRef.update({
        "totalXp": FieldValue.increment(totalXp),
      });

      // 🔹 Exam sonuç kaydı
      await userRef.collection("exam_results").doc(exam.id).set({
        "examId": exam.id,
        "title": exam.title,
        "totalXp": totalXp,
        "correct": aiResult.correctCount,
        "wrong": aiResult.wrongCount,
        "unanswered": aiResult.unansweredCount,
        "takenAt": FieldValue.serverTimestamp(),
      });

      print("🔥 Exam XP saved successfully. (XP=$totalXp)");
    } catch (e, st) {
      print("❌ ExamXpService.saveExamResult error: $e\n$st");
    }
  }
}
