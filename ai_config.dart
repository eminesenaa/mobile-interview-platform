// lib/services/ai/ai_config.dart
import 'ai_service.dart';
import 'openai_service.dart' show PromptType;

class AiConfig {
  // true => Gemini, false => OpenAI
  static const bool useGemini = true;

  // Varsayılan prompt tipi
  static const PromptType defaultPromptType = PromptType.training;

  static LlmProvider get provider =>
      useGemini ? LlmProvider.gemini : LlmProvider.openai;
}
