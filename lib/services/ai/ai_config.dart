// lib/services/ai/ai_config.dart
import 'ai_service.dart';
import 'openai_service.dart' show PromptType;

enum AiProvider {
  openai,
  gemini,
  //anthropic
}

class AiConfig {
  /// Hangi provider kullanılacak? Default: OpenAI
  static const AiProvider provider = AiProvider.openai;

  /// Varsayılan prompt tipi
  static const PromptType defaultPromptType = PromptType.training;

  static AiProvider chooseModel({String? questionType}) {

    //print(questionType);

    if (questionType == null) return AiProvider.openai; // default

    switch (questionType.toLowerCase()) {
      case 'mcq':
        return AiProvider.gemini;
      default:
        return AiProvider.openai;
    }
  }

}

