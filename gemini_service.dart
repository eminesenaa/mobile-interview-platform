// lib/services/ai/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'openai_service.dart' show PromptType, GradeResult;

class GeminiService {
  final String _modelName;
  final String _apiKey;
  late final GenerativeModel _baseModel;

  GeminiService._internal(this._modelName, this._apiKey) {
    _baseModel = GenerativeModel(model: _modelName, apiKey: _apiKey);
  }

  // DEV: anahtar sabit (ileride dart-define/proxy'ye geçebilirsin)
  factory GeminiService({String model = 'gemini-1.5-flash-latest'}) {
    const apiKey = 'AIzaSyDB88KxJm_3vuZApx7e4ueXTV2iTYSB4gM'; // senin key
    return GeminiService._internal(model, apiKey);
  }

  // >>> SADECE TrainingAnalysis kullan
  Future<String> _loadPromptTemplate(PromptType type) async {
    return await rootBundle.loadString('assets/prompts/TrainingAnalysis.txt');
  }

  String _renderTemplate(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{{$k}}', v));
    return out;
  }

  /// DÜZ METİN döner; JSON parse edilmez.
  Future<GradeResult> gradeWithTemplate({
    required String category,
    required Map<String, String> qMeta,
    required String candidateAnswer,
    required PromptType promptType,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final template = await _loadPromptTemplate(promptType);

    // İstersen bu satırı da prompt dosyasına taşıyabilirsin
    final systemRole = _buildSystemRole(category);

    final modelWithSystem = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.text(
        '$systemRole\n'
        'Return concise, helpful feedback in PLAIN TEXT.\n'
        'Do NOT use markdown code fences and do NOT return JSON unless explicitly asked in the prompt.',
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

    // Düz metin isteğini vurguluyoruz
    final prompt = '$userContent\n\nPlease return PLAIN TEXT feedback only.';

    final resp = await modelWithSystem.generateContent(
      [Content.text(prompt)],
      safetySettings: const [],
      generationConfig: GenerationConfig(
        temperature: 0,
        // responseMimeType belirtmiyoruz → düz metin
      ),
    ).timeout(timeout);

    final text = (resp.text ?? '').trim();

    // UI’in çalışması için GradeResult’a sarıyoruz (correct=true: “Yanlış” uyarısı çıkmasın)
    return GradeResult(
      correct: true,
      expected: '',
      reason: text.isEmpty ? 'No feedback produced.' : text,
    );
  }

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
