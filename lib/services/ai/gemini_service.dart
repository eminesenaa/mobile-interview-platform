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
      if (parsed is! Map<String, dynamic>)
        return GradeResult.fromSafeFallback(text);

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

      var tmpl =
          await rootBundle.loadString('assets/prompts/ExamBatchEvaluation.yml');

      // OpenAI'dan kopyalanan dinamik bölüm temizleme mantığı
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

      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system("Output ONLY raw JSON."),
      );

      final resp = await model.generateContent(
        [Content.text(tmpl)],
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      ).timeout(timeout);

      final text = resp.text ?? '';
      if (text.isEmpty) throw Exception("Gemini returned empty response");

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("Interview question result is not a JSON object.");
      }
      return parsed;
    } catch (e) {
      _handleQuotaError(e);
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

      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system("Output ONLY raw JSON."),
      );

      final resp = await model.generateContent(
        [Content.text(tmpl)],
        generationConfig: GenerationConfig(
          temperature: 0.2,
          responseMimeType: 'application/json',
        ),
      ).timeout(timeout);

      final text = resp.text ?? '';
      if (text.isEmpty) throw Exception("Gemini returned empty response");

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("Interview final result is not a JSON object.");
      }
      return parsed;
    } catch (e) {
      _handleQuotaError(e);
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

      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system("Output ONLY raw JSON."),
      );

      final resp = await model.generateContent(
        [Content.text(tmpl)],
        generationConfig: GenerationConfig(
          temperature: 0.7,
          responseMimeType: 'application/json',
        ),
      ).timeout(timeout);

      final text = resp.text ?? '';
      if (text.isEmpty) throw Exception("Gemini returned empty response");

      final parsed = jsonDecode(text);
      if (parsed is! Map<String, dynamic>) {
        throw Exception("HR message result is not a JSON object.");
      }
      return parsed;
    } catch (e) {
      _handleQuotaError(e);
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

