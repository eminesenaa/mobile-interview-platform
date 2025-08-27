// lib/services/ai/ai_service.dart
import '../../models/question.dart';
import 'openai_service.dart';

class AiService {
  /// Her tip soru için tek giriş noktası.
  /// MCQ: userAnswer = seçilen index (int) veya text
  /// ShortAnswer/FillBlank: userAnswer = String
  Future<AiEvaluateResult> evaluate({
    required Question question,
    required dynamic userAnswer,
  }) async {
    // OpenAIService -> statik gradeWithTemplate kullanıyoruz
    final meta = _toMeta(question);
    final candidate = _candidateFromAnswer(question, userAnswer);
    final category = _mapTopicToCategory(question.topic);

    final result = await OpenAIService.gradeWithTemplate(
      category: category,
      qMeta: meta,
      candidateAnswer: candidate,
    );

    // Arkadaşının GradeResult modeli: correct / expected / reason
    return AiEvaluateResult(
      finalAnswer: result.expected,
      explanation: result.reason,
      // Şimdilik puan yok; AI ekibi ekleyince dolacak.
      score: null,
      correct: result.correct,
    );
  }

  // ---------- helpers ----------
  Map<String, String> _toMeta(Question q) {
    // Arkadaşının template’inde beklenen anahtar adları:
    // "Question Text", "Question Format", "Option A"..."Option D", "Correct Option", "Tags", "AI Prompt Helper"
    final meta = <String, String>{
      "Question Text": q.title,
      "Question Format": (q.type?.name ?? '').toUpperCase(),
      "Tags": (q.tags?.join(', ') ?? ''),
      "AI Prompt Helper": q.description ?? '',
    };

    // MCQ opsiyonlarını yerleştir (varsa)
    final opts = q.options ?? const [];
    if (opts.isNotEmpty) {
      if (opts.length > 0) meta["Option A"] = opts[0];
      if (opts.length > 1) meta["Option B"] = opts[1];
      if (opts.length > 2) meta["Option C"] = opts[2];
      if (opts.length > 3) meta["Option D"] = opts[3];
    }
    // Doğru şıkkı bilmiyorsak boş geç
    // meta["Correct Option"] = q.correctOptionIndex != null ? String.fromCharCode(65 + q.correctOptionIndex!) : "";

    return meta;
  }

  String _candidateFromAnswer(Question q, dynamic ans) {
    // MCQ'da index geldiyse A/B/C/D'ye çevir
    if (ans is int && (q.options?.isNotEmpty ?? false)) {
      final idx = ans.clamp(0, q.options!.length - 1);
      final letter = String.fromCharCode(65 + idx); // 65='A'
      return '$letter'; // "A" | "B" | ...
    }
    return ans?.toString() ?? '';
  }

  String _mapTopicToCategory(String? topic) {
    // Arkadaşının OpenAIService._buildSystemRole ile eşleşecek şekilde
    final t = (topic ?? '').toLowerCase();
    if (t.contains('algorithm')) return 'algorithm';
    if (t.contains('data')) return 'data structure';
    if (t.contains('git')) return 'git';
    if (t.contains('oop')) return 'oop';
    return 'algorithm';
  }
}

class AiEvaluateResult {
  final String finalAnswer;
  final String explanation;
  final int? score;   // 1..5 (opsiyonel)
  final bool correct; // arkadaşın servisinden geliyor
  AiEvaluateResult({
    required this.finalAnswer,
    required this.explanation,
    required this.correct,
    this.score,
  });
}
