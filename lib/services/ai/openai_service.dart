// lib/services/openai_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
//import '../../models/question.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_config.dart';

enum PromptType {
  mcq,
  fillBlanks,
  shortAnswer,
  codeWriting,
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

  GradeResult(
      {required this.correct,
      required this.expected,
      required this.reason,
      required this.score});

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
    print(json['explaination']);
    return GradeResult(
      correct: json['correct'] ?? false,
      expected: json['expected']?.toString() ?? "",
      reason: json['explanation']?.toString() ?? "",
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
      correct: decision == "advance" ||
          correctness >= 0.8, // çünkü bu prompt [0,1] scale
      expected: "overall_score=${json['overall_score']}, decision=$decision",
      reason: strengths.isNotEmpty ? strengths : weaknesses,
      score: (json['overall_score'] is num)
          ? (json['overall_score'] as num).toDouble()
          : 0.0,
    );

  }
}

class OpenAIService {

  static final _apiKey = dotenv.env['OPENAI_API_KEY'];
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4.1';
  static const _examModel = 'gpt-4.1';

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
      case PromptType.mcq:
        print("MCQ Promptu Kullanılacak");
        return await rootBundle
            .loadString('assets/prompts/MultipleChoiceQuestionTraining.txt');
      case PromptType.fillBlanks:
        print("Fill in the blanks Promptu Kullanılacak");
        return await rootBundle
            .loadString('assets/prompts/FillInTheBlanksTraining.txt');
      case PromptType.shortAnswer:
        print("Short Answer Promptu Kullanılacak");
        return await rootBundle
            .loadString('assets/prompts/ShortAnswerTraining.txt');
      case PromptType.codeWriting:
        print("Code Writing Promptu Kullanılacak");
        return await rootBundle
            .loadString('assets/prompts/CodeWritingTraining.txt');
    }
  }

  static String _renderTemplate(String template, Map<String, String> vars) {
    //Doldurur

    var out = template;
    vars.forEach((k, v) {
      out = out.replaceAll('{{$k}}', v);
    });
    return out;
  }

  static Future<GradeResult> gradeWithTemplate(

      {
      required Map<String, String> qMeta,
      required String candidateAnswer,
      Duration timeout = const Duration(seconds: 60),
      required PromptType promptType}

    ) async {

    final template = await _loadPromptTemplate(promptType);
    const systemRole = "You are an expert Computer Science Interwiever";

    var userContent = _renderTemplate(template, {
      "Question Text": qMeta["Question Text"] ?? "",
      "Question Format": qMeta["Question Format"] ?? "",
      "AI Prompt Helper": qMeta["AI Prompt Helper"] ?? "",
      "candidate_answer_or_choice": candidateAnswer,
    });

    if(promptType == PromptType.mcq){
      userContent = _renderTemplate(template, {
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
    }

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

    print("GPT'ye gönderilen body:");
    debugPrint(body.toString(), wrapWidth: 10000);

    final resp = await _post(body, timeout: timeout);

    print(resp.body);

    return _extractGradeResult(resp, promptType);
  }

  static Future<List<Map<String, dynamic>>> gradeBatch({
    required String batchId,
    required List<Map<String, dynamic>>
        items, // { index, meta, user_answer, topic }
    Duration timeout = const Duration(seconds: 60),
  }) async {
    // 1) Batch payload
    final payload = {
      "batch_id": batchId,
      "questions": items,
      "output_schema": {
        "type": "array",
        "items": {
          "index": "int",
          "correct": "boolean",
          "expected": "string",
          "reason": "string",
          "score": "number"
        }
      }
    };

    // 2) Prompt dosyasını oku ve payload'ı göm
    final tmpl =
        await rootBundle.loadString('assets/prompts/ExamBatchEvaluation.txt');
    final userContent =
        tmpl.replaceFirst('{{BATCH_PAYLOAD_JSON}}', jsonEncode(payload));

    // 3) Chat çağrısı — JSON ARRAY istediğimiz için response_format kullanmıyoruz
    final body = {
      "model": _examModel,
      "temperature": 0.2,
      "messages": [
        {"role": "system", "content": "Output ONLY a raw JSON array."},
        {"role": "user", "content": userContent},
      ],
    };

    final res = await _post(body, timeout: timeout);

    // 4) Parse: content bir JSON array olmalı
    final outer = jsonDecode(res.body);
    final content = outer['choices']?[0]?['message']?['content'];
    if (content == null)
      throw Exception("OpenAI returned empty content for batch.");

    final parsed = jsonDecode(content);
    if (parsed is! List) throw Exception("Batch result is not a JSON array.");

    return (parsed as List).cast<Map<String, dynamic>>();
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

    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final decoded = jsonDecode(res.body);

        final err = decoded["error"];
        final type = err?["type"]?.toString();
        final code = err?["code"]?.toString();

        // ❗ TOKEN BİTTİ / QUOTA BİTTİ DURUMU
        if (type == "insufficient_quota" || code == "insufficient_quota") {
          AiConfig.OPENAIoutOfTokenFlag = true;
        }
      } catch (_) {
        // JSON parse edilemezse bir şey yapma
      }

      throw Exception('OpenAI error ${res.statusCode}: ${res.body}');
    }

    return res;
  }

  /// JSON mode’a uygun, savunmacı ayrıştırma + debug
  static GradeResult _extractGradeResult(http.Response res, PromptType type) {
    final raw = res.body;
    //print(raw);
    try {
      final outer = jsonDecode(raw);
      final content = outer['choices']?[0]?['message']?['content'];
      if (content == null) return GradeResult.fromSafeFallback(raw);

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>){
        return GradeResult.fromSafeFallback(content);
      }

      switch (type) {
        case PromptType.training:
          return GradeResultMapper.fromTraining(parsed);
        case PromptType.interview:
          return GradeResultMapper.fromInterview(parsed);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(parsed);
        case PromptType.mcq:
          return GradeResultMapper.fromTraining(parsed);
        case PromptType.fillBlanks:
          return GradeResultMapper.fromTraining(parsed);
        case PromptType.shortAnswer:
          return GradeResultMapper.fromTraining(parsed);
        case PromptType.codeWriting:
          return GradeResultMapper.fromTraining(parsed);
      }
    } catch (_) {
      return GradeResult.fromSafeFallback(raw);
    }
  }
}
