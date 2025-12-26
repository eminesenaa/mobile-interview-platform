// lib/services/ai/llama_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'ai_config.dart';
import 'openai_service.dart' show PromptType, GradeResult, GradeResultMapper;

class LlamaService {
  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const _defaultModel = 'llama-3.1-70b-versatile';

  final String _apiKey;
  final String _model;

  LlamaService._internal(this._apiKey, this._model);

  factory LlamaService({
    String? apiKey,
    String? model,
  }) {
    final resolvedKey = apiKey ?? dotenv.env['GROQ_API_KEY'];
    final resolvedModel = model ?? _defaultModel;

    if (resolvedKey == null || resolvedKey.isEmpty) {
      throw Exception('GROQ_API_KEY is missing');
    }

    return LlamaService._internal(resolvedKey, resolvedModel);
  }

  // -------------------- Prompt yükleme --------------------
  static Future<String> _loadPromptTemplate(PromptType type) async {
    switch (type) {
      case PromptType.training:
        return await rootBundle.loadString('assets/prompts/TrainingAnalysis.txt');
      case PromptType.interview:
        return await rootBundle.loadString('assets/prompts/InterviewAnalysis.txt');
      case PromptType.detailedTraining:
        return await rootBundle
            .loadString('assets/prompts/TrainingDetailedAnalysis.txt');
      case PromptType.mcq:
        return await rootBundle
            .loadString('assets/prompts/MultipleChoiceQuestionTraining.txt');
      case PromptType.fillBlanks:
        return await rootBundle
            .loadString('assets/prompts/FillInTheBlanksTraining.txt');
      case PromptType.shortAnswer:
        return await rootBundle
            .loadString('assets/prompts/ShortAnswerTraining.txt');
      case PromptType.codeWriting:
        return await rootBundle
            .loadString('assets/prompts/CodeWritingTraining.txt');
    }
  }

  String _renderTemplate(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{{$k}}', v));
    return out;
  }

  // -------------------- TEK SORU --------------------
  Future<GradeResult> gradeWithTemplate({
    required String category,
    required Map<String, String> qMeta,
    required String candidateAnswer,
    required PromptType promptType,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final template = await _loadPromptTemplate(promptType);

      final systemRole =
          "You are an expert Computer Science Interwiever. "
          "Return ONLY a valid JSON object. No extra text.";

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
          {"role": "user", "content": userContent},
        ],
      };

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
        _handleGroqError(res);
        throw Exception('Groq error ${res.statusCode}: ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final content =
      decoded['choices']?[0]?['message']?['content'];

      if (content == null) {
        throw Exception('Groq returned empty content');
      }

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) {
        throw Exception('LLaMA result is not a JSON object');
      }

      switch (promptType) {
        case PromptType.training:
          return GradeResultMapper.fromTraining(parsed);
        case PromptType.interview:
          return GradeResultMapper.fromInterview(parsed);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(parsed);
        case PromptType.mcq:
        case PromptType.fillBlanks:
        case PromptType.shortAnswer:
        case PromptType.codeWriting:
          return GradeResultMapper.fromTraining(parsed);
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('rate') || msg.contains('quota')) {
        AiConfig.LLAMAoutOfTokenFlag = true;
      }

      return GradeResult(
        correct: false,
        expected: '',
        reason: 'LLaMA JSON error: $e',
        score: 0.0,
      );
    }
  }

  // -------------------- BATCH --------------------
  Future<List<Map<String, dynamic>>> gradeBatch({
    required String batchId,
    required List<Map<String, dynamic>> items,
    Duration timeout = const Duration(seconds: 60),
  }) async {
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

    final tmpl =
    await rootBundle.loadString('assets/prompts/ExamBatchEvaluation.txt');
    final userContent =
    tmpl.replaceFirst('{{BATCH_PAYLOAD_JSON}}', jsonEncode(payload));

    final body = {
      "model": _model,
      "temperature": 0.2,
      "messages": [
        {
          "role": "system",
          "content": "Output ONLY a raw JSON array."
        },
        {
          "role": "user",
          "content": userContent
        }
      ],
    };

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
      _handleGroqError(res);
      throw Exception('Groq batch error ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    final content =
    decoded['choices']?[0]?['message']?['content'];

    final parsed = jsonDecode(content);
    if (parsed is! List) {
      throw Exception('Batch result is not a JSON array');
    }

    return (parsed as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // -------------------- Error helper --------------------
  void _handleGroqError(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      final error = decoded['error']?.toString().toLowerCase() ?? '';
      if (error.contains('rate') || error.contains('quota')) {
        AiConfig.LLAMAoutOfTokenFlag = true;
      }
    } catch (_) {}
  }
}
