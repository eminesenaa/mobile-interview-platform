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

  // -------------------- Prompt Yükleme --------------------
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
        return await rootBundle
            .loadString('assets/prompts/MultipleChoiceQuestionTraining.yml');
      case PromptType.fillBlanks:
        return await rootBundle
            .loadString('assets/prompts/FillInTheBlanksTraining.yml');
      case PromptType.shortAnswer:
        return await rootBundle
            .loadString('assets/prompts/ShortAnswerTraining.yml');
      case PromptType.codeWriting:
        return await rootBundle
            .loadString('assets/prompts/CodeWritingTraining.yml');
      case PromptType.interviewQuestion:
        return await rootBundle
            .loadString('assets/prompts/InterviewQuestionEvaluation.yml');
      case PromptType.interviewFinalDecision:
        return await rootBundle
            .loadString('assets/prompts/InterviewFinalDecision.yml');
    }
  }

  String _renderTemplate(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{{$k}}', v));
    return out;
  }

  // -------------------- TEK SORU DEĞERLENDİRME --------------------
  Future<GradeResult> gradeWithTemplate({
    required Map<String, String> qMeta,
    required String candidateAnswer,
    required PromptType promptType,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final template = await _loadPromptTemplate(promptType);
      const systemPrompt =
          "You are an expert Computer Science Interviewer.\nOutput ONLY JSON.";

      var userContent = _renderTemplate(template, {
        "Question Text": qMeta["Question Text"] ?? "",
        "Question Format": qMeta["Question Format"] ?? "",
        "AI Prompt Helper": qMeta["AI Prompt Helper"] ?? "",
        "Tags": qMeta["Tags"] ?? "",
        "Code Template": qMeta["Code Template"] ?? "",
        "candidate_answer_or_choice": candidateAnswer,
      });

      // MCQ özel alanları
      if (promptType == PromptType.mcq) {
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
        "max_tokens": 1024,
        "temperature": 0,
        "system": systemPrompt,
        "messages": [
          {"role": "user", "content": userContent}
        ]
      };

      final res = await _post(body, timeout);
      final text = _extractTextFromResponse(res);

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>)
        return GradeResult.fromSafeFallback(text);

      switch (promptType) {
        case PromptType.interview:
          return GradeResultMapper.fromInterview(parsed);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(parsed);
        default:
          return GradeResultMapper.fromTraining(parsed);
      }
    } catch (e) {
      _handleAnthropicError(e);
      return GradeResult.fromSafeFallback(e.toString());
    }
  }

  // -------------------- BATCH (SINAV) DEĞERLENDİRME --------------------
  Future<List<Map<String, dynamic>>> gradeBatch({
    required String batchId,
    required List<Map<String, dynamic>> items,
    required bool hasMCQ,
    required bool hasFillBlanks,
    required bool hasShortAnswer,
    required bool hasCodeWriting,
    required bool hasBehavioral,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    try {
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

      var tmpl =
          await rootBundle.loadString('assets/prompts/ExamBatchEvaluation.yml');

      // Dinamik Bölüm Temizleme
      if (!hasMCQ) tmpl = _removeSection(tmpl, 'MCQ EVALUATION');
      if (!hasFillBlanks) {
        tmpl = _removeSection(tmpl, 'FILL-IN-THE-BLANK (N = 1)');
        tmpl = _removeSection(tmpl, 'FILL-IN-THE-BLANK (N > 1)');
      }
      if (!hasShortAnswer)
        tmpl = _removeSection(tmpl, 'SHORT ANSWER EVALUATION');
      if (!hasCodeWriting) tmpl = _removeSection(tmpl, 'CODING EVALUATION');
      if (!hasBehavioral)
        tmpl = _removeSection(tmpl, 'BEHAVIORAL (STAR) EVALUATION');

      final userContent =
          tmpl.replaceFirst('{{BATCH_PAYLOAD_JSON}}', jsonEncode(payload));

      final body = {
        "model": _model,
        "max_tokens": 4096, // Batch için daha yüksek token limiti
        "temperature": 0.2,
        "system": "Output ONLY a raw JSON array. No preamble.",
        "messages": [
          {"role": "user", "content": userContent}
        ]
      };

      final res = await _post(body, timeout);
      final text = _extractTextFromResponse(res);

      final parsed = jsonDecode(text);
      if (parsed is! List) throw Exception('Batch result is not a JSON array');

      return (parsed as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _handleAnthropicError(e);
      rethrow;
    }
  }

  // -------------------- YARDIMCI METOTLAR --------------------

  Future<http.Response> _post(
      Map<String, dynamic> body, Duration timeout) async {
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
      _handleStatusError(res);
      throw Exception('Anthropic error ${res.statusCode}: ${res.body}');
    }
    return res;
  }

  String _extractTextFromResponse(http.Response res) {
    final decoded = jsonDecode(res.body);
    final contentList = decoded['content'] as List?;
    final text = contentList?.firstWhere(
      (e) => e['type'] == 'text',
      orElse: () => null,
    )?['text'];

    if (text == null || text.toString().isEmpty) {
      throw Exception('Anthropic returned empty content');
    }
    return text.toString().trim();
  }

  static String _removeSection(String prompt, String sectionTitle) {
    final pattern = RegExp(
      r'^---\s*' +
          RegExp.escape(sectionTitle) +
          r'\s*\n' +
          r'([\s\S]*?)' +
          r'(?=^---\s|\Z)',
      multiLine: true,
    );
    return prompt.replaceAll(pattern, '');
  }

  void _handleStatusError(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      final errorType =
          decoded['error']?['type']?.toString().toLowerCase() ?? '';
      if (errorType.contains('rate_limit') ||
          errorType.contains('overloaded')) {
        AiConfig.ANTHROPICoutOfTokenFlag = true;
      }
    } catch (_) {}
  }

  void _handleAnthropicError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('quota') ||
        msg.contains('rate_limit') ||
        msg.contains('429')) {
      AiConfig.ANTHROPICoutOfTokenFlag = true;
    }
  }

  // ===============================================================
  // 🔥 INTERVIEW GRADING — Stage 1: Single Question Evaluation
  // ===============================================================

  Future<Map<String, dynamic>> gradeInterviewQuestion({
    required Map<String, String> qMeta,
    required String candidateAnswer,
    required String category,
    required String questionTypeName,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    try {
      var tmpl = await rootBundle
          .loadString('assets/prompts/InterviewQuestionEvaluation.yml');

      tmpl = _stripInterviewSections(tmpl, questionTypeName);

      tmpl = _renderTemplate(tmpl, {
        ...qMeta,
        'Category': category,
        'candidate_answer_or_choice': candidateAnswer,
      });

      final body = {
        "model": _model,
        "max_tokens": 2048,
        "temperature": 0.1,
        "system": "Output ONLY raw JSON.",
        "messages": [
          {"role": "user", "content": tmpl}
        ]
      };

      final res = await _post(body, timeout);
      final text = _extractTextFromResponse(res);

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("Interview question result is not a JSON object.");
      }
      return parsed;
    } catch (e) {
      _handleAnthropicError(e);
      rethrow;
    }
  }

  // ===============================================================
  // 🔥 INTERVIEW GRADING — Stage 2: Final Decision
  // ===============================================================

  Future<Map<String, dynamic>> gradeInterviewFinal({
    required List<Map<String, dynamic>> evaluationsJson,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      var tmpl = await rootBundle
          .loadString('assets/prompts/InterviewFinalDecision.yml');

      tmpl = tmpl.replaceFirst(
        '{{EVALUATIONS_JSON}}',
        jsonEncode(evaluationsJson),
      );

      final body = {
        "model": _model,
        "max_tokens": 2048,
        "temperature": 0.2,
        "system": "Output ONLY raw JSON.",
        "messages": [
          {"role": "user", "content": tmpl}
        ]
      };

      final res = await _post(body, timeout);
      final text = _extractTextFromResponse(res);

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("Interview final result is not a JSON object.");
      }
      return parsed;
    } catch (e) {
      _handleAnthropicError(e);
      rethrow;
    }
  }

  // ===============================================================
  // 🔥 HR MESSAGE GENERATION
  // ===============================================================

  Future<Map<String, dynamic>> generateHrMessage({
    required String decision,
    required String candidateName,
    required String position,
    required Map<String, dynamic> evaluationJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      var tmpl = await rootBundle
          .loadString('assets/prompts/InterviewHrMessage.yml');

      tmpl = tmpl
          .replaceFirst('{{DECISION}}', decision)
          .replaceFirst('{{CANDIDATE_NAME}}', candidateName)
          .replaceFirst('{{POSITION}}', position)
          .replaceFirst('{{EVALUATION_JSON}}', jsonEncode(evaluationJson));

      final body = {
        "model": _model,
        "max_tokens": 1024,
        "temperature": 0.7,
        "system": "Output ONLY raw JSON.",
        "messages": [
          {"role": "user", "content": tmpl}
        ]
      };

      final res = await _post(body, timeout);
      final text = _extractTextFromResponse(res);

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("HR message result is not a JSON object.");
      }
      return parsed;
    } catch (e) {
      _handleAnthropicError(e);
      rethrow;
    }
  }

  // ===============================================================
  // 🔥 INTERVIEW SECTION STRIPPING
  // ===============================================================

  static String _stripInterviewSections(String tmpl, String questionTypeName) {
    const allSections = [
      'MCQ EVALUATION',
      'FILL-IN-THE-BLANK (N = 1)',
      'FILL-IN-THE-BLANK (N > 1)',
      'SHORT ANSWER EVALUATION',
      'CODING EVALUATION',
      'BEHAVIORAL (STAR) EVALUATION',
    ];

    final Set<String> keepSections;
    switch (questionTypeName.toLowerCase()) {
      case 'mcq':
        keepSections = {'MCQ EVALUATION'};
        break;
      case 'fillblank':
      case 'fillBlanks':
        keepSections = {
          'FILL-IN-THE-BLANK (N = 1)',
          'FILL-IN-THE-BLANK (N > 1)',
        };
        break;
      case 'shortanswer':
      case 'short_answer':
        keepSections = {'SHORT ANSWER EVALUATION'};
        break;
      case 'coding':
      case 'debugging':
        keepSections = {'CODING EVALUATION'};
        break;
      default:
        keepSections = {'BEHAVIORAL (STAR) EVALUATION'};
    }

    for (final section in allSections) {
      if (!keepSections.contains(section)) {
        tmpl = _removeSection(tmpl, section);
      }
    }

    return tmpl;
  }
}
