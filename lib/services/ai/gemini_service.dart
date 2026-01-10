// lib/services/ai/gemini_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'ai_config.dart';
import 'openai_service.dart' show PromptType, GradeResult, GradeResultMapper;

class GeminiService {
  final String _modelName;
  final String _apiKey;

  GeminiService._internal(this._modelName, this._apiKey);

  factory GeminiService({
    String? model,
    String? apiKey,
  }) {
    final resolvedModel = model ?? 'gemini-1.5-flash'; // Güncel stabil model
    final resolvedKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    return GeminiService._internal(resolvedModel, resolvedKey);
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
      const systemRole = "You are an expert Computer Science Interviewer";

      // OpenAI'daki render mantığının aynısı
      var userContent = _renderTemplate(template, {
        "Question Text": qMeta["Question Text"] ?? "",
        "Question Format": qMeta["Question Format"] ?? "",
        "AI Prompt Helper": qMeta["AI Prompt Helper"] ?? "",
        "candidate_answer_or_choice": candidateAnswer,
      });

      // MCQ için özel alanlar (OpenAI ile birebir eşleme)
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

      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system("$systemRole\nOutput ONLY JSON."),
      );

      final resp = await model.generateContent(
        [Content.text(userContent)],
        generationConfig: GenerationConfig(
          temperature: 0,
          responseMimeType: 'application/json',
        ),
      ).timeout(timeout);

      final text = resp.text ?? '';
      if (text.isEmpty) return GradeResult.fromSafeFallback("Empty response");

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) return GradeResult.fromSafeFallback(text);

      // Mapper kullanımı
      switch (promptType) {
        case PromptType.interview:
          return GradeResultMapper.fromInterview(parsed);
        case PromptType.detailedTraining:
          return GradeResultMapper.fromDetailedTraining(parsed);
        default:
          return GradeResultMapper.fromTraining(parsed);
      }
    } catch (e) {
      _handleQuotaError(e);
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

      // OpenAI'dan kopyalanan dinamik bölüm temizleme mantığı
      if (!hasMCQ) tmpl = _removeSection(tmpl, 'MCQ EVALUATION');
      if (!hasFillBlanks) {
        tmpl = _removeSection(tmpl, 'FILL-IN-THE-BLANK (N = 1)');
        tmpl = _removeSection(tmpl, 'FILL-IN-THE-BLANK (N > 1)');
      }
      if (!hasShortAnswer) tmpl = _removeSection(tmpl, 'SHORT ANSWER EVALUATION');
      if (!hasCodeWriting) tmpl = _removeSection(tmpl, 'CODING EVALUATION');
      if (!hasBehavioral) tmpl = _removeSection(tmpl, 'BEHAVIORAL (STAR) EVALUATION');

      final userContent = tmpl.replaceFirst('{{BATCH_PAYLOAD_JSON}}', jsonEncode(payload));

      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system("Output ONLY a raw JSON array."),
      );

      final resp = await model.generateContent(
        [Content.text(userContent)],
        generationConfig: GenerationConfig(
          temperature: 0.2,
          responseMimeType: 'application/json',
        ),
      ).timeout(timeout);

      final text = resp.text ?? '';
      final parsed = jsonDecode(text);
      if (parsed is! List) throw Exception("Batch result is not a JSON array.");

      return (parsed as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _handleQuotaError(e);
      rethrow;
    }
  }

  // -------------------- YARDIMCI METOTLAR --------------------

  // OpenAI ile aynı Regex mantığı
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

  void _handleQuotaError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains("resource_exhausted") || msg.contains("quota")) {
      AiConfig.GEMINIoutOfTokenFlag = true;
    }
  }
}