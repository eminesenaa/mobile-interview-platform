// lib/services/openai_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../../models/question.dart';

enum PromptType {
  training,
  interview,
  detailedTraining
}

/// Basit sonuç modeli
class GradeResult {
  final bool correct;
  final String expected;
  final String reason;
  final double score;

  GradeResult({
    required this.correct,
    required this.expected,
    required this.reason,
    required this.score
  });

  static GradeResult fromSafeFallback(String rawText) {
    // JSON gelmediyse ama yine de UI çökmemesi için anlamlı bir fallback
    return GradeResult(
      correct: false,
      expected: "",
      reason:
          "Model returned non-JSON content: ${rawText.substring(0, rawText.length > 200 ? 200 : rawText.length)}",
      score: 0.0,
    );
    // Dilersen burayı daha akıllı hale getirip içinden bazı ipuçlarını çekebilirsin.
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
      correct: decision == "advance" || correctness >= 0.8, // çünkü bu prompt [0,1] scale
      expected: "overall_score=${json['overall_score']}, decision=$decision",
      reason: strengths.isNotEmpty ? strengths : weaknesses,
      score: (json['overall_score'] is num)
          ? (json['overall_score'] as num).toDouble()
          : 0.0,
    );
  }

}


class OpenAIService {
  static const _apiKey = "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";
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  static Future<String> _loadPromptTemplate(PromptType type) async {
    switch (type) {
      case PromptType.training:
        return await rootBundle.loadString('assets/prompts/TrainingAnalysis.txt');
      case PromptType.interview:
        return await rootBundle.loadString('assets/prompts/InterviewAnalysis.txt');
      case PromptType.detailedTraining:
        return await rootBundle.loadString('assets/prompts/TrainingDetailedAnalysis.txt');
    }
  }


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

  static Future<GradeResult> gradeWithTemplate({
    required String category,
    required Map<String, String> qMeta,
    required String candidateAnswer,
    Duration timeout = const Duration(seconds: 60),
    required PromptType promptType
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

  /// --- HTTP yardımcıları ---
  static Future<http.Response> _post(
    Map<String, dynamic> body, {
    required Duration timeout,
  }) async {
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

    // HTTP hata kodlarını erken yakala
    if (res.statusCode < 200 || res.statusCode >= 300) {
      // Burada res.body’yi UI’ye fırlatıyoruz ki ham hata görülsün
      throw Exception('OpenAI error ${res.statusCode}: ${res.body}');
    }
    return res;
  }

  /// JSON mode’a uygun, savunmacı ayrıştırma + debug
  static GradeResult _extractGradeResult(http.Response res, PromptType type) {
    final raw = res.body;
    try {
      final outer = jsonDecode(raw);
      final content = outer['choices']?[0]?['message']?['content'];
      if (content == null) return GradeResult.fromSafeFallback(raw);

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) return GradeResult.fromSafeFallback(content);

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

  static Future<int> findQuestionTime(Question q,
      {Duration timeout = const Duration(seconds: 30)}) async {
    // 1. promptu yükle
    final template =
    await rootBundle.loadString('assets/prompts/TimeFinding.txt');

    // 2. question stringini yerine koy
    final userContent = template.replaceAll("{{QUESTION}}", q.toString());

    // 3. GPT request body
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

    // 4. request at
    final resp = await _post(body, timeout: timeout);

    // 5. parse et
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
    } catch (e) {
      // fallback
      return 60; // default 1 dk
    }
  }

  static Future<List<int>> findQuestionsTimeBatch(
      List<Question> questions, {
        Duration timeout = const Duration(seconds: 60),
      }) async {
    // 1. prompt yükle
    final template =
    await rootBundle.loadString('assets/prompts/TimeFindingBatch.txt');

    // 2. questions stringini hazırla
    final buffer = StringBuffer();
    for (int i = 0; i < questions.length; i++) {
      buffer.writeln("[$i] ${questions[i].title}");
      if (questions[i].description != null) {
        buffer.writeln("    Desc: ${questions[i].description}");
      }
      if (questions[i].options != null && questions[i].options!.isNotEmpty) {
        for (int j = 0; j < questions[i].options!.length; j++) {
          buffer.writeln("    Option ${String.fromCharCode(65 + j)}: ${questions[i].options![j]}");
        }
      }
    }

    final userContent = template.replaceAll("{{QUESTIONS}}", buffer.toString());

    // 3. GPT request body
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

    // 4. request at
    final resp = await _post(body, timeout: timeout);

    // 5. parse et
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
        return 60; // fallback
      }).toList();

      // --- DEBUG PRINT ---
      for (int i = 0; i < secsList.length; i++) {
        print("Q[$i] (${questions[i].title}) icin tahmin: ${secsList[i]} saniye");
      }

      return secsList;
    } catch (e) {
      // fallback: hepsine 60 sn
      print("Batch time parsing failed: $e");
      return List.filled(questions.length, 60);
    }
  }

}
