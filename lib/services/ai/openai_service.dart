// lib/services/ai/openai_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../../models/question.dart';

/// Uygulamada kullanacağın prompt türleri
enum PromptType { training, interview, detailedTraining }

/// Tek soruluk çıktı modeli
class GradeResult {
  final bool correct;
  final String expected;
  final String reason;
  final double score;

  GradeResult({
    required this.correct,
    required this.expected,
    required this.reason,
    required this.score,
  });

  static GradeResult fromSafeFallback(String rawText) {
    return GradeResult(
      correct: false,
      expected: "",
      reason: "Model returned non-JSON content: "
          "${rawText.substring(0, rawText.length > 200 ? 200 : rawText.length)}",
      score: 0.0,
    );
  }
}

class GradeResultMapper {
  static GradeResult fromTraining(Map<String, dynamic> json) {
    return GradeResult(
      correct: json['correct'] ?? false,
      expected: json['expected']?.toString() ?? "",
      reason: json['reason']?.toString() ?? "",
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : 0.0,
    );
  }

  static GradeResult fromInterview(Map<String, dynamic> json) {
    final subscores = json['subscores'] ?? {};
    final correctness = (subscores['correctness'] ?? 0) as num;
    final decision = json['decision']?.toString() ?? '';
    final strengths = (json['strengths'] as List?)?.join(', ') ?? '';
    final weaknesses = (json['weaknesses'] as List?)?.join(', ') ?? '';

    return GradeResult(
      correct: decision == "advance" || correctness >= 5,
      expected: "overall_score=${json['overall_score']}, decision=$decision",
      reason: strengths.isNotEmpty ? strengths : weaknesses,
      score: (json['overall_score'] is num)
          ? (json['overall_score'] as num).toDouble()
          : 0.0,
    );
  }

  static GradeResult fromDetailedTraining(Map<String, dynamic> json) {
    final subscores = json['subscores'] ?? {};
    final correctness = (subscores['correctness'] ?? 0) as num;
    final decision = json['decision']?.toString() ?? '';
    final strengths = (json['strengths'] as List?)?.join(', ') ?? '';
    final weaknesses = (json['weaknesses'] as List?)?.join(', ') ?? '';

    return GradeResult(
      correct: decision == "advance" || correctness >= 0.8,
      expected: "overall_score=${json['overall_score']}, decision=$decision",
      reason: strengths.isNotEmpty ? strengths : weaknesses,
      score: (json['overall_score'] is num)
          ? (json['overall_score'] as num).toDouble()
          : 0.0,
    );
  }
}

/// Batch (5'lik paket) öğesi
class BatchGradeItem {
  final String questionId;
  final bool correct;
  final String expected;
  final String reason;
  final double score;
  BatchGradeItem({
    required this.questionId,
    required this.correct,
    required this.expected,
    required this.reason,
    required this.score,
  });
}

class OpenAIService {
  // ------------------ API Key ------------------
  static const _apiKey =
      "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";
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  // -------------------- Tek soru --------------------
  static Future<GradeResult> gradeWithTemplate({
    required String category,
    required Map<String, String> qMeta,
    required String candidateAnswer,
    Duration timeout = const Duration(seconds: 60),
    required PromptType promptType,
  }) async {
    final template = await _loadPromptTemplate(promptType);
    final systemRole = _buildSystemRole(category);

    final userContent = _renderTemplate(template, {
      "Category": category,
      "Question Content Type": qMeta["Question Content Type"] ?? "",
      "Difficulty Level (1–5)": qMeta["Difficulty Level (1–5)"] ?? "",
      "Source Reference": qMeta["Source Reference"] ?? "",
      "Question Title": qMeta["Question Title"] ?? "",
      "Question Text": qMeta["Question Text"] ?? "",
      "Question Format": qMeta["Question Format"] ?? "",
      "Option A": qMeta["Option A"] ?? "",
      "Option B": qMeta["Option B"] ?? "",
      "Option C": qMeta["Option C"] ?? "",
      "Option D": qMeta["Option D"] ?? "",
      "Correct Option": qMeta["Correct Option"] ?? "",
      "Tags": qMeta["Tags"] ?? "",
      "AI Prompt Helper": qMeta["AI Prompt Helper"] ?? "",
      "candidate_answer_or_choice": candidateAnswer,
    });

    final body = {
      "model": _model,
      "temperature": 0,
      "response_format": {"type": "json_object"},
      "messages": [
        {"role": "system", "content": systemRole},
        {"role": "system", "content": "Output ONLY JSON."},
        {"role": "user", "content": userContent},
      ],
    };

    final resp = await _post(body, timeout: timeout);
    return _extractGradeResult(resp, promptType);
  }

  // -------------------- Batch (çoklu) --------------------
  static Future<List<BatchGradeItem>> gradeBatchWithTemplate({
    required List<Map<String, String>> qMetas,
    required List<String> candidateAnswers,
    Duration timeout = const Duration(seconds: 90),
    required PromptType promptType,
  }) async {
    assert(qMetas.length == candidateAnswers.length && qMetas.isNotEmpty);

    final template = await _loadPromptTemplateForBatch(promptType);

    final items = <Map<String, String>>[];
    for (int i = 0; i < qMetas.length; i++) {
      final m = Map<String, String>.from(qMetas[i]);
      m["candidate_answer_or_choice"] = candidateAnswers[i];

      for (final k in const [
        "Category",
        "Question Id",
        "Question Text",
        "Question Format",
        "Option A",
        "Option B",
        "Option C",
        "Option D",
        "Correct Option",
        "Tags",
        "AI Prompt Helper",
        "candidate_answer_or_choice",
      ]) {
        m[k] = m[k] ?? "";
      }
      items.add(m);
    }

    final userContent =
        template.replaceFirst("{{ITEMS_JSON}}", jsonEncode(items));

    final body = {
      "model": _model,
      "temperature": 0,
      "response_format": {"type": "json_object"},
      "messages": [
        {
          "role": "system",
          "content": "You are a senior technical interviewer. Output ONLY JSON."
        },
        {"role": "user", "content": userContent},
      ],
    };

    final resp = await _post(body, timeout: timeout);
    return _extractBatchResult(resp);
  }

  // -------------------- Soru zamanı (tek) --------------------
  static Future<int> findQuestionTime(Question q,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final template =
        await rootBundle.loadString('assets/prompts/TimeFinding.txt');

    final userContent = template.replaceAll("{{QUESTION}}", q.toString());

    final body = {
      "model": 'gpt-4o',
      "temperature": 0,
      "response_format": {"type": "json_object"},
      "messages": [
        {"role": "system", "content": "You are a helpful exam time estimator."},
        {"role": "system", "content": "Output ONLY valid JSON."},
        {"role": "user", "content": userContent},
      ],
    };

    final resp = await _post(body, timeout: timeout);
    final raw = resp.body;
    try {
      final outer = jsonDecode(raw);
      final content = outer['choices']?[0]?['message']?['content'];
      if (content == null) throw Exception("No content");

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("Not a JSON object: $content");
      }

      final sec = parsed['estimated_seconds'];
      if (sec is int) return sec;
      if (sec is num) return sec.toInt();

      throw Exception("Invalid estimated_seconds: $sec");
    } catch (_) {
      return 60; // fallback 1dk
    }
  }

  // -------------------- Soru zamanı (çoklu batch) --------------------
  static Future<List<int>> findQuestionsTimeBatch(
    List<Question> questions, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final template =
        await rootBundle.loadString('assets/prompts/TimeFindingBatch.txt');

    final buffer = StringBuffer();
    for (int i = 0; i < questions.length; i++) {
      buffer.writeln("[$i] ${questions[i].title}");
      if (questions[i].description != null) {
        buffer.writeln("    Desc: ${questions[i].description}");
      }
      if (questions[i].options != null && questions[i].options!.isNotEmpty) {
        for (int j = 0; j < questions[i].options!.length; j++) {
          buffer.writeln(
              "    Option ${String.fromCharCode(65 + j)}: ${questions[i].options![j]}");
        }
      }
    }

    final userContent = template.replaceAll("{{QUESTIONS}}", buffer.toString());

    final body = {
      "model": _model,
      "temperature": 0,
      "response_format": {"type": "json_object"},
      "messages": [
        {"role": "system", "content": "You are a helpful exam time estimator."},
        {"role": "system", "content": "Output ONLY valid JSON."},
        {"role": "user", "content": userContent},
      ],
    };

    final resp = await _post(body, timeout: timeout);
    final raw = resp.body;
    try {
      final outer = jsonDecode(raw);
      final content = outer['choices']?[0]?['message']?['content'];
      if (content == null) throw Exception("No content");

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) throw Exception("Not a JSON object");

      final results = parsed['results'] as List?;
      if (results == null) throw Exception("No results");

      final secsList = results.map<int>((e) {
        final sec = e['estimated_seconds'];
        if (sec is int) return sec;
        if (sec is num) return sec.toInt();
        return 60;
      }).toList();

      return secsList;
    } catch (_) {
      return List.filled(questions.length, 60);
    }
  }

  // -------------------- Prompt dosyaları --------------------
  static Future<String> _loadPromptTemplate(PromptType type) async {
    switch (type) {
      case PromptType.training:
        return await rootBundle
            .loadString('assets/prompts/TrainingAnalysis.txt');
      case PromptType.interview:
        return await rootBundle
            .loadString('assets/prompts/InterviewAnalysis.txt');
      case PromptType.detailedTraining:
        return await rootBundle
            .loadString('assets/prompts/TrainingDetailedAnalysis.txt');
    }
  }

  static Future<String> _loadPromptTemplateForBatch(PromptType type) async {
    return await rootBundle
        .loadString('assets/prompts/TrainingAnalysisBatch.txt');
  }

  // -------------------- Yardımcılar --------------------
  static String _renderTemplate(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) {
      out = out.replaceAll('{{$k}}', v);
    });
    return out;
  }

  static String _buildSystemRole(String category) {
    switch (category.toLowerCase()) {
      case 'algorithm':
        return 'You are an algorithm expert.';
      case 'data structure':
        return 'You are a data structures expert.';
      case 'git':
        return 'You are a Git/version control expert.';
      case 'oop':
        return 'You are an OOP expert.';
      case 'sql':
        return 'You are an SQL/query optimization expert.';
      case 'behavioral hr questions':
        return 'You are a senior HR interviewer evaluating with the STAR technique.';
      case 'ml basics':
        return 'You are a machine learning fundamentals expert.';
      case 'network':
        return 'You are a computer networking expert.';
      case 'java':
        return 'You are a senior Java software engineer.';
      case 'c/c++':
        return 'You are a senior C/C++ systems programming expert.';
      case 'python':
        return 'You are a senior Python software engineer.';
      case 'data science':
        return 'You are a senior Data Science expert.';
      default:
        return 'You are a senior technical interviewer.';
    }
  }

  static Future<http.Response> _post(
    Map<String, dynamic> body, {
    required Duration timeout,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is empty.');
    }

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_apiKey",
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('OpenAI error ${res.statusCode}: ${res.body}');
    }
    return res;
  }

  static GradeResult _extractGradeResult(http.Response res, PromptType type) {
    final raw = res.body;
    try {
      final outer = jsonDecode(raw);
      final content = outer['choices']?[0]?['message']?['content'];
      if (content == null) return GradeResult.fromSafeFallback(raw);

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) {
        return GradeResult.fromSafeFallback(content);
      }

      switch (type) {
        case PromptType.training:
          return GradeResultMapper.fromTraining(parsed);
        case PromptType.interview:
          return GradeResultMapper.fromInterview(parsed);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(parsed);
      }
    } catch (_) {
      return GradeResult.fromSafeFallback(raw);
    }
  }

  static List<BatchGradeItem> _extractBatchResult(http.Response res) {
    final raw = res.body;
    try {
      final outer = jsonDecode(raw);
      final content = outer['choices']?[0]?['message']?['content'];
      if (content == null) return [];

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) return [];

      final list = parsed['items'] as List<dynamic>? ?? const [];
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return BatchGradeItem(
          questionId: m['question_id']?.toString() ?? "",
          correct: m['correct'] ?? false,
          expected: m['expected']?.toString() ?? "",
          reason: m['reason']?.toString() ?? "",
          score: (m['score'] is num) ? (m['score'] as num).toDouble() : 0.0,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

