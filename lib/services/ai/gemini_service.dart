// lib/services/ai/gemini_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';

// OpenAI tarafındaki tip ve mapper'ları kullanıyoruz → %100 alan uyumu
import 'openai_service.dart' show PromptType, GradeResult, GradeResultMapper;

class GeminiService {
  final String _modelName;
  final String _apiKey;

  GeminiService._internal(this._modelName, this._apiKey);

  /// Önerilen kullanım:
  /// flutter run --dart-define=GEMINI_API_KEY=xxx
  factory GeminiService({
    String? model,
    String? apiKey,
  }) {
    final resolvedModel = model ?? 'gemini-1.5-flash-latest';
    final resolvedKey =
        apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (resolvedKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is not set. '
        'Pass it via --dart-define=GEMINI_API_KEY=YOUR_KEY or provide apiKey parameter.',
      );
    }
    return GeminiService._internal(resolvedModel, resolvedKey);
  }

  // -------------------- Prompt yükleme (OpenAI ile aynı dosyalar) --------------------
  Future<String> _loadPromptTemplate(PromptType type) async {
    switch (type) {
      case PromptType.training:
        return await rootBundle.loadString('assets/prompts/TrainingAnalysis.txt');
      case PromptType.interview:
        return await rootBundle.loadString('assets/prompts/InterviewAnalysis.txt');
      case PromptType.detailedTraining:
        return await rootBundle.loadString('assets/prompts/TrainingDetailedAnalysis.txt');
    }
  }

  String _renderTemplate(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{{$k}}', v));
    return out;
  }

  // -------------------- TEK SORU: OpenAI ile %100 aynı JSON şeması --------------------
  Future<GradeResult> gradeWithTemplate({
    required String category,
    required Map<String, String> qMeta,
    required String candidateAnswer,
    required PromptType promptType,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final template = await _loadPromptTemplate(promptType);
      final systemRole = _buildSystemRole(category);

      // JSON NESNESİ zorla (OpenAI json_object’e denk)
      final modelWithSystem = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.text(
          '$systemRole\n'
          'Return ONLY JSON object. No extra text, no code fences.',
        ),
      );

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

      final resp = await modelWithSystem
          .generateContent(
            [Content.text(userContent)],
            safetySettings: const [],
            generationConfig: const GenerationConfig(
              temperature: 0,
              responseMimeType: 'application/json', // JSON obje bekliyoruz
            ),
          )
          .timeout(timeout);

      final text = (resp.text ?? '').trim();
      final parsed = jsonDecode(text);
      if (parsed is! Map) {
        throw Exception('Gemini single-question result is not a JSON object.');
      }

      final obj = Map<String, dynamic>.from(parsed as Map);

      // OpenAI ile aynı mapper → GradeResult alanları birebir
      switch (promptType) {
        case PromptType.training:
          return GradeResultMapper.fromTraining(obj);
        case PromptType.interview:
          return GradeResultMapper.fromInterview(obj);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(obj);
      }
    } catch (e) {
      return GradeResult(
        correct: false,
        expected: '',
        reason: 'Gemini JSON error: $e',
        score: 0.0,
      );
    }
  }

  // -------------------- 5’li BATCH: OpenAI ile %100 aynı JSON array şeması --------------------
  Future<List<Map<String, dynamic>>> gradeBatch({
    required String batchId,
    required List<Map<String, dynamic>> items, // { index, meta, user_answer, topic }
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

    // 2) Exam prompt’u + payload
    final tmpl = await rootBundle.loadString('assets/prompts/ExamBatchEvaluation.txt');
    final userContent = tmpl.replaceFirst('{{BATCH_PAYLOAD_JSON}}', jsonEncode(payload));

    // 3) JSON ARRAY’i zorla
    final modelWithSystem = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.text('Output ONLY a raw JSON array.'),
    );

    final resp = await modelWithSystem
        .generateContent(
          [Content.text(userContent)],
          safetySettings: const [],
          generationConfig: const GenerationConfig(
            temperature: 0.2,
            responseMimeType: 'application/json',
          ),
        )
        .timeout(timeout);

    final text = (resp.text ?? '').trim();
    if (text.isEmpty) {
      throw Exception('Gemini returned empty content for batch.');
    }

    final parsed = jsonDecode(text);
    if (parsed is! List) {
      throw Exception('Batch result is not a JSON array.');
    }

    return (parsed as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // -------------------- System rolü --------------------
  String _buildSystemRole(String category) {
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
}
