// lib/services/ai/anthropic_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'ai_config.dart';
import 'openai_service.dart' show PromptType, GradeResult, GradeResultMapper;

class AnthropicService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _defaultModel = 'claude-3-5-sonnet-20240620';

  final String _apiKey;
  final String _model;

  AnthropicService._internal(this._apiKey, this._model);

  factory AnthropicService({
    String? apiKey,
    String? model,
  }) {
    final resolvedKey = apiKey ?? dotenv.env['ANTHROPIC_API_KEY'];
    final resolvedModel = model ?? _defaultModel;

    if (resolvedKey == null || resolvedKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY is missing');
    }

    return AnthropicService._internal(resolvedKey, resolvedModel);
  }

  // -------------------- Prompt yükleme (diğerleriyle aynı) --------------------
  static Future<String> _loadPromptTemplate(PromptType type) async {
    switch (type) {
      case PromptType.training:
        return await rootBundle.loadString('assets/prompts/TrainingAnalysis.txt');
      case PromptType.interview:
        return await rootBundle.loadString('assets/prompts/InterviewAnalysis.txt');
      case PromptType.detailedTraining:
        return await rootBundle.loadString('assets/prompts/TrainingDetailedAnalysis.txt');
      case PromptType.mcq:
        return await rootBundle.loadString('assets/prompts/MultipleChoiceQuestionTraining.txt');
      case PromptType.fillBlanks:
        return await rootBundle.loadString('assets/prompts/FillInTheBlanksTraining.txt');
      case PromptType.shortAnswer:
        return await rootBundle.loadString('assets/prompts/ShortAnswerTraining.txt');
      case PromptType.codeWriting:
        return await rootBundle.loadString('assets/prompts/CodeWritingTraining.txt');
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

      const systemPrompt =
          "You are an expert Computer Science Interwiever.\n"
          "Return ONLY a valid JSON object. No explanations, no markdown.";

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
        "max_tokens": 800,
        "temperature": 0,
        "system": systemPrompt,
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": userContent}
            ]
          }
        ]
      };

      final res = await http
          .post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _apiKey,
          "anthropic-version": "2023-06-01",
        },
        body: jsonEncode(body),
      )
          .timeout(timeout);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _handleAnthropicError(res);
        throw Exception('Anthropic error ${res.statusCode}: ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final contentList = decoded['content'] as List?;
      final text = contentList?.firstWhere(
            (e) => e['type'] == 'text',
        orElse: () => null,
      )?['text'];

      if (text == null || text.toString().isEmpty) {
        throw Exception('Anthropic returned empty content');
      }

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception('Anthropic result is not a JSON object');
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
      if (msg.contains('quota') || msg.contains('rate')) {
        AiConfig.ANTHROPICoutOfTokenFlag = true;
      }

      return GradeResult(
        correct: false,
        expected: '',
        reason: 'Anthropic JSON error: $e',
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
      "max_tokens": 1200,
      "temperature": 0.2,
      "system": "Output ONLY a raw JSON array.",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": userContent}
          ]
        }
      ]
    };

    final res = await http
        .post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: jsonEncode(body),
    )
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      _handleAnthropicError(res);
      throw Exception('Anthropic batch error ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    final text = decoded['content']?[0]?['text'];

    final parsed = jsonDecode(text);
    if (parsed is! List) {
      throw Exception('Anthropic batch result is not a JSON array');
    }

    return (parsed as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // -------------------- Error helper --------------------
  void _handleAnthropicError(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      final error = decoded['error']?.toString().toLowerCase() ?? '';
      if (error.contains('rate') || error.contains('quota')) {
        AiConfig.ANTHROPICoutOfTokenFlag = true;
      }
    } catch (_) {}
  }
}
