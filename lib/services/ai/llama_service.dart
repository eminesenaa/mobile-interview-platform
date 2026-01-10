// lib/services/ai/llama_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'ai_config.dart';
import 'openai_service.dart' show PromptType, GradeResult, GradeResultMapper;

class LlamaService {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
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

  // -------------------- Prompt Yükleme --------------------
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

  // -------------------- TEK SORU DEĞERLENDİRME --------------------
  Future<GradeResult> gradeWithTemplate({
    required Map<String, String> qMeta,
    required String candidateAnswer,
    required PromptType promptType,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final template = await _loadPromptTemplate(promptType);
      const systemRole = "You are an expert Computer Science Interviewer. Return ONLY a valid JSON object.";

      var userContent = _renderTemplate(template, {
        "Question Text": qMeta["Question Text"] ?? "",
        "Question Format": qMeta["Question Format"] ?? "",
        "AI Prompt Helper": qMeta["AI Prompt Helper"] ?? "",
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
        "temperature": 0,
        "response_format": {"type": "json_object"},
        "messages": [
          {"role": "system", "content": systemRole},
          {"role": "user", "content": userContent},
        ],
      };

      final res = await _post(body, timeout);
      final decoded = jsonDecode(res.body);
      final content = decoded['choices']?[0]?['message']?['content'];

      if (content == null) return GradeResult.fromSafeFallback("Empty response content");

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) return GradeResult.fromSafeFallback(content);

      switch (promptType) {
        case PromptType.interview:
          return GradeResultMapper.fromInterview(parsed);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(parsed);
        default:
          return GradeResultMapper.fromTraining(parsed);
      }
    } catch (e) {
      _handleException(e);
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
    Duration timeout = const Duration(seconds: 60),
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

      var tmpl = await rootBundle.loadString('assets/prompts/ExamBatchEvaluation.txt');

      // Dinamik Bölüm Temizleme
      if (!hasMCQ) tmpl = _removeSection(tmpl, 'MCQ EVALUATION');
      if (!hasFillBlanks) {
        tmpl = _removeSection(tmpl, 'FILL-IN-THE-BLANK (N = 1)');
        tmpl = _removeSection(tmpl, 'FILL-IN-THE-BLANK (N > 1)');
      }
      if (!hasShortAnswer) tmpl = _removeSection(tmpl, 'SHORT ANSWER EVALUATION');
      if (!hasCodeWriting) tmpl = _removeSection(tmpl, 'CODING EVALUATION');
      if (!hasBehavioral) tmpl = _removeSection(tmpl, 'BEHAVIORAL (STAR) EVALUATION');

      final userContent = tmpl.replaceFirst('{{BATCH_PAYLOAD_JSON}}', jsonEncode(payload));

      final body = {
        "model": _model,
        "temperature": 0.2,
        "messages": [
          {"role": "system", "content": "Output ONLY a raw JSON array."},
          {"role": "user", "content": userContent},
        ],
      };

      final res = await _post(body, timeout);
      final decoded = jsonDecode(res.body);
      final content = decoded['choices']?[0]?['message']?['content'];

      final parsed = jsonDecode(content);
      if (parsed is! List) throw Exception('Batch result is not a JSON array');

      return (parsed as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // -------------------- YARDIMCI METOTLAR --------------------

  Future<http.Response> _post(Map<String, dynamic> body, Duration timeout) async {
    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode(body),
    ).timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      _handleHttpError(res);
      throw Exception('Groq error ${res.statusCode}: ${res.body}');
    }
    return res;
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

  void _handleHttpError(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      final errorMsg = decoded['error']?['message']?.toString().toLowerCase() ?? '';
      final errorType = decoded['error']?['type']?.toString().toLowerCase() ?? '';

      if (errorMsg.contains('rate') || errorType.contains('rate') || res.statusCode == 429) {
        AiConfig.LLAMAoutOfTokenFlag = true;
      }
    } catch (_) {}
  }

  void _handleException(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('rate') || msg.contains('quota') || msg.contains('429')) {
      AiConfig.LLAMAoutOfTokenFlag = true;
    }
  }
}