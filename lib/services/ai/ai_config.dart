// lib/services/ai/ai_config.dart
import 'ai_service.dart';
import 'openai_service.dart' show PromptType;

enum AiProvider {
  openai,
  gemini,
  anthropic
}

class AiConfig {
  /// Hangi provider kullanılacak? Default: OpenAI
  static const AiProvider provider = AiProvider.openai;
  static bool OPENAIoutOfTokenFlag = false;
  static bool GEMINIoutOfTokenFlag = false;
  static bool ANTHROPICoutOfTokenFlag = false;

  /// Varsayılan prompt tipi
  static const PromptType defaultPromptType = PromptType.training;

  static AiProvider chooseModel({String? questionType}) {

    if(OPENAIoutOfTokenFlag || GEMINIoutOfTokenFlag || ANTHROPICoutOfTokenFlag){
      // !!! BİRİNİN TOKENI BİTTİ !!!

      if(OPENAIoutOfTokenFlag == false) {
        // Eğer openai tokenı bitmediyse openai kullan
        return AiProvider.openai;
      } else {
        // Eğer openai tokenı bitmişse gemini kullan
        return AiProvider.gemini;
      }

    }

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

