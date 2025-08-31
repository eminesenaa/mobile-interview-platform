// lib/services/ai/ai_service.dart
import '../../models/question.dart';

// OpenAI & Gemini servisleri
import 'openai_service.dart' show OpenAIService, PromptType;
import 'gemini_service.dart';

/// Hangi LLM sağlayıcısını kullanacağımız
enum LlmProvider { openai, gemini }

class AiService {
  /// Varsayılan sağlayıcı (OpenAI) ve varsayılan prompt tipi (training)
  final LlmProvider provider;
  final PromptType defaultPromptType;

  AiService({
    this.provider = LlmProvider.openai,
    this.defaultPromptType = PromptType.training,
  });

  /// Her tip soru için tek giriş noktası.
  /// - MCQ: userAnswer = seçilen index (int) veya text
  /// - ShortAnswer/FillBlank: userAnswer = String
  ///
  /// [promptTypeOverride] gönderirsen defaultPromptType yerine o kullanılır.
  Future<AiEvaluateResult> evaluate({
    required Question question,
    required dynamic userAnswer,
    PromptType? promptTypeOverride,
  }) async {
    final meta = _toMeta(question);
    final candidate = _candidateFromAnswer(question, userAnswer);
    final category = _mapTopicToCategory(question.topic);

    final promptType = promptTypeOverride ?? defaultPromptType;

    if (provider == LlmProvider.openai) {
      final result = await OpenAIService.gradeWithTemplate(
        promptType: promptType,
        category: category,
        qMeta: meta,
        candidateAnswer: candidate,
      );
      return AiEvaluateResult(
        finalAnswer: result.expected,
        explanation: result.reason,
        score: null,
        correct: result.correct,
      );
    } else {
      final gemini = GeminiService(); // key'i gemini_service.dart içinde sabit
      final result = await gemini.gradeWithTemplate(
        promptType: promptType,
        category: category,
        qMeta: meta,
        candidateAnswer: candidate,
      );
      return AiEvaluateResult(
        finalAnswer: result.expected,
        explanation: result.reason,
        score: null,
        correct: result.correct,
      );
    }
  }

  // ---------- helpers ----------

  /// Şablonların beklediği meta alanlarını doldurur.
  /// (Boşsa "" bırakırız ki template replaceAll hata vermesin.)
  Map<String, String> _toMeta(Question q) {
    final meta = <String, String>{
      // Temel alanlar
      "Question Title": q.title ?? "",
      // Ayrı bir 'text' alanın yoksa title'ı hem Title hem Text olarak kullan
      "Question Text": q.title ?? "",
      "Question Format": (q.type?.name ?? '').toUpperCase(),
      "Question Content Type": q.type?.name ?? "",
      "Difficulty Level (1–5)": _difficultyFromQuestion(q),
      "Source Reference": _sourceFromQuestion(q),

      // Etiketler & yardımcı açıklama
      "Tags": (q.tags?.join(', ') ?? ''),
      "AI Prompt Helper": q.description ?? '',

      // MCQ seçenekleri (varsa doldurulacak)
      "Option A": "",
      "Option B": "",
      "Option C": "",
      "Option D": "",

      // Doğru şık alanın modelde yoksa boş bırak
      "Correct Option": "",
    };

    // MCQ opsiyonlarını yerleştir (varsa)
    final opts = q.options ?? const [];
    if (opts.isNotEmpty) {
      if (opts.length > 0) meta["Option A"] = opts[0];
      if (opts.length > 1) meta["Option B"] = opts[1];
      if (opts.length > 2) meta["Option C"] = opts[2];
      if (opts.length > 3) meta["Option D"] = opts[3];
    }

    // NOT: Question modelinde correctOptionIndex yoksa hiçbir şey yapmıyoruz.
    return meta;
  }

  /// UI tarafı index verirse "A/B/C/D" harfine çevirir; text ise direkt döndürür.
  String _candidateFromAnswer(Question q, dynamic ans) {
    if (ans is int && (q.options?.isNotEmpty ?? false)) {
      final idx = ans.clamp(0, q.options!.length - 1).toInt(); // <- .toInt()
      final letter = String.fromCharCode(65 + idx); // 65='A'
      return '$letter';
    }
    return ans?.toString() ?? '';
  }

  /// Topic → kategori eşlemesi (OpenAI & Gemini system role karşılığı)
  String _mapTopicToCategory(String? topic) {
    final t = (topic ?? '').toLowerCase();

    if (t.contains('algorithm')) return 'algorithm';
    if (t.contains('data structure') || t.contains('structure') || t == 'data')
      return 'data structure';
    if (t.contains('git')) return 'git';
    if (t.contains('oop')) return 'oop';
    if (t.contains('sql')) return 'sql';
    if (t.contains('behavioral') || t.contains('hr'))
      return 'behavioral hr questions';
    if (t.contains('ml') || t.contains('machine learning')) return 'ml basics';
    if (t.contains('network')) return 'network';
    if (t.contains('java')) return 'java';
    if (t.contains('c/c++') || t.contains('c++') || t == 'c') return 'c/c++';
    if (t.contains('python')) return 'python';
    if (t.contains('data science')) return 'data science';

    // default
    return 'algorithm';
  }

  /// Zorluk bilgisi modelde yoksa boş bırakılır.
  String _difficultyFromQuestion(Question q) {
    // Eğer question içinde difficulty alanın varsa burayı ona göre düzenle.
    // Örn: return (q.difficulty?.toString() ?? '');
    return '';
  }

  /// Kaynak linki/modelde yoksa boş bırakılır.
  String _sourceFromQuestion(Question q) {
    // Eğer question içinde source/reference alanın varsa burayı ona göre düzenle.
    return '';
  }
}

class AiEvaluateResult {
  final String finalAnswer;
  final String explanation;
  final int? score; // 1..5 (opsiyonel)
  final bool correct; // model kararına göre

  AiEvaluateResult({
    required this.finalAnswer,
    required this.explanation,
    required this.correct,
    this.score,
  });
}
