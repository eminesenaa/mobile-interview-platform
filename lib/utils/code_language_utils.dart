// lib/utils/code_language_utils.dart

class CodeLanguageUtils {
  CodeLanguageUtils._();

  /// flutter_highlight / highlight.js tarafından desteklenen diller
  static const Set<String> _supportedLanguages = {
    'sql',
    'python',
    'dart',
    'javascript',
    'java',
    'cpp',
    'c',
    'go',
    'rust',
    'kotlin',
    'swift',
  };

  /// Sadece question.topic üzerinden dili belirler
  static String resolveLanguageFromTopic(String topic) {
    final key = topic.trim().toLowerCase();

    if (_supportedLanguages.contains(key)) {
      return key;
    }

    // Güvenli fallback
    return 'plaintext';
  }
}
