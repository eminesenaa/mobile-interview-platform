import 'package:flutter/services.dart' show rootBundle;

Future<String> loadPrompt() async {
  return await rootBundle.loadString('assets/prompts/PromptEnglishFinal.txt');
}
