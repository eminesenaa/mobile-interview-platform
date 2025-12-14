import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/ai_exam_result.dart';
import 'package:interview_project/pages/exam/services/exam_xp_service.dart';

class ExamSolveService {
  static final _db = FirebaseFirestore.instance;

  /// Exam bittikten sonra:
  /// 1) XP hesaplanır (ExamXpService)
  /// 2) Kullanıcının totalXp’sine eklenir
  /// 3) Exam sonucu users/{uid}/exam_results altına kaydedilir
  static Future<void> saveExamResult({
    required Exam exam,
    required AiExamResult? aiResult,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRef = _db.collection('users').doc(uid);
      final resultRef =
          userRef.collection('exam_results').doc(exam.id);

      // =============== XP HESAPLA ===============
      int earnedXp = 0;

      if (aiResult != null) {
        earnedXp = ExamXpService.computeExamXp(
          exam: exam,
          aiResult: aiResult,
        );
      }

      // =============== KULLANICIYA XP EKLE ===============
      if (earnedXp > 0) {
        await userRef.update({
          'totalXp': FieldValue.increment(earnedXp),
        });
      }

      // =============== EXAM SONUCUNU FIRESTORE’A KAYDET ===============
      await resultRef.set({
        'examId': exam.id,
        'title': exam.title,
        'createdAt': exam.createdAt,
        'completedAt': FieldValue.serverTimestamp(),
        'earnedXp': earnedXp,
        'answers': exam.answers ?? {},
        'stats': exam.stats ?? {},

        // AI varsa kaydedelim
        if (aiResult != null) 'ai': {
          'totalScore': aiResult.totalScore,
          'correct': aiResult.correctCount,
          'wrong': aiResult.wrongCount,
          'unanswered': aiResult.unansweredCount,
          'topicPercentage': aiResult.topicPercentage,
          'evaluations': aiResult.questionEvaluations
              .map((e) => e.toJson())
              .toList(),
        }
      });

      print("🔥 ExamSolveService: exam saved with $earnedXp XP");

    } catch (e, st) {
      print("❌ ExamSolveService error: $e\n$st");
    }
  }
}
