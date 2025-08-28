// lib/services/openai_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

/// Basit sonuç modeli
class GradeResult {
  final bool correct;
  final String expected;
  final String reason;

  GradeResult({
    required this.correct,
    required this.expected,
    required this.reason,
  });

  factory GradeResult.fromMap(Map<String, dynamic> m) {
    // Küçük Şema
    if (m.containsKey('correct')) {
      return GradeResult(
        correct: m['correct'] == true,
        expected: (m['expected'] ?? '').toString(),
        reason: (m['reason'] ?? '').toString(),
      );
    }

    // Detaylı Şema
    if (m.containsKey('subscores') || m.containsKey('decision')) {
      final subscores = m['subscores'] as Map<String, dynamic>? ?? {};
      final correctnessScore = subscores['correctness'] ?? 0;
      final decision = (m['decision'] ?? '').toString();

      final strengths = (m['strengths'] is List)
          ? (m['strengths'] as List).join(", ")
          : "";
      final weaknesses = (m['weaknesses'] is List)
          ? (m['weaknesses'] as List).join(", ")
          : "";

      return GradeResult(
        correct: (decision.toLowerCase() == "advance") || (correctnessScore == 5),
        expected: "Based on scoring (correctness=$correctnessScore, decision=$decision)",
        reason: "Strengths: $strengths; Weaknesses: $weaknesses",
      );
    }

    // Fallback
    return GradeResult(
      correct: false,
      expected: "",
      reason: "Unrecognized schema: $m",
    );
  }


  static GradeResult fromSafeFallback(String rawText) {
    // JSON gelmediyse ama yine de UI çökmemesi için anlamlı bir fallback
    return GradeResult(
      correct: false,
      expected: "",
      reason:
          "Model returned non-JSON content: ${rawText.substring(0, rawText.length > 200 ? 200 : rawText.length)}",
    );
    // Dilersen burayı daha akıllı hale getirip içinden bazı ipuçlarını çekebilirsin.
  }
}

class OpenAIService {
  static const _apiKey = "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";
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  static Future<String> _loadPromptTemplate() async {
    return await rootBundle.loadString('assets/prompts/PromptEnglishFinal.txt');
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

  /// Basit kullanım (JSON mode + debug)
  static Future<GradeResult> gradeSimple({
    required String question,
    required String userAnswer,
    Duration timeout = const Duration(seconds: 45),
  }) async {

    final body = {
      "model": _model,
      "temperature": 0,
      "response_format": {"type": "json_object"}, // JSON mode
      "messages": [
        {
          "role": "system",
          "content":
              "You are a strict grader for short CS questions. "
              "Return ONLY a single JSON object with fields: correct(boolean), expected(string), reason(string).",
        },
        {
          "role": "user",
          "content":
              "Question: $question\nUser answer: $userAnswer\n"
              "Evaluate strictly. If the answer matches the key idea, correct=true.\n"
              "Output only JSON.",
        },
      ],
    };

    final resp = await _post(body, timeout: timeout);
    return _extractGradeResult(resp);
  }

  /// PromptEnglishFinal.txt ile gelişmiş kullanım (JSON mode + debug)
  static Future<GradeResult> gradeWithTemplate({
    required String category,
    required Map<String, String> qMeta,
    required String candidateAnswer,
    Duration timeout = const Duration(seconds: 60),
  }) async {

    final template = await _loadPromptTemplate();
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
      "response_format": {"type": "json_object"}, // JSON mode
      "messages": [
        {"role": "system", "content": systemRole},
        {
          "role": "system",
          "content":
              "Output ONLY raw JSON with keys: correct(boolean), expected(string), reason(string). No extra text, no code fences.",
        },
        {"role": "user", "content": userContent},
      ],
    };

    final resp = await _post(body, timeout: timeout);
    return _extractGradeResult(resp);
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
  static GradeResult _extractGradeResult(http.Response res) {
    final raw = res.body;
    //Nasıl bir cevap geldi printi:
    //print(raw);
    Map<String, dynamic> data;

    try {
      data = jsonDecode(raw);
    } catch (e) {
      // Sunucu başka bir şey dönderdiyse
      return GradeResult.fromSafeFallback(raw);
    }

    // choices güvenliği
    final choices = data['choices'];
    if (choices == null || choices is! List || choices.isEmpty) {
      return GradeResult.fromSafeFallback(raw);
    }
    final message = choices[0]?['message'];
    final content = message?['content'];
    if (content == null || content is! String || content.trim().isEmpty) {
      return GradeResult.fromSafeFallback(raw);
    }

    final text = content.trim();

    // JSON mode aktif; doğrudan JSON bekliyoruz
    try {
      final parsed = jsonDecode(text);
      if (parsed is Map<String, dynamic>) {

        /*
        doğru parse'landı mı diye kontrol etme printleri
        print(GradeResult.fromMap(parsed).correct);
        print(GradeResult.fromMap(parsed).expected);
        print(GradeResult.fromMap(parsed).reason);
        */

        return GradeResult.fromMap(parsed);
      } else {
        // bazı durumlarda model yine de açıklama basarsa:
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}');
        if (start != -1 && end != -1) {
          return GradeResult.fromMap(
            jsonDecode(text.substring(start, end + 1)),
          );
        }
        return GradeResult.fromSafeFallback(text);
      }
    } catch (_) {
      // { … } aralığı fallback
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1) {
        try {
          return GradeResult.fromMap(
            jsonDecode(text.substring(start, end + 1)),
          );
        } catch (e) {
          return GradeResult.fromSafeFallback(text);
        }
      }
      return GradeResult.fromSafeFallback(text);
    }
  }
}
