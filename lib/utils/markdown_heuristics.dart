// lib/utils/markdown_heuristics.dart
/// ``` fenced code var mı?
bool containsFencedCode(String s) => s.contains('```');

/// İlk fenced block içinden dil etiketini al (```c, ```cpp, ...).
String? extractFenceLanguage(String s) {
  final i = s.indexOf('```');
  if (i < 0) return null;
  final end = s.indexOf('\n', i);
  if (end < 0) return null;
  final fence = s.substring(i + 3, end).trim(); // örn: "c"
  return fence.isEmpty ? null : fence;
}

/// Fence yoksa kabaca "kod gibi mi?" tahmini.
bool isLikelyCodeSnippet(String s) {
  final t = s.trim();
  if (t.isEmpty) return false;
  // kod anahtarları ve semboller
  final k = RegExp(r'[;{}()=<>]|#include|printf|scanf|System\.out|public\s+static|class\s+\w+|int\s+\w+|return\b');
  return k.hasMatch(t);
}

/// Basit dil tahmini (fence yoksa).
String? guessLanguageFromText(String s) {
  final t = s.toLowerCase();
  if (t.contains('#include') || t.contains('std::') || t.contains('cout')) return 'cpp';
  if (t.contains('printf(') || t.contains('scanf(')) return 'c';
  if (t.contains('system.out.println') || t.contains('public static void main')) return 'java';
  if (t.contains('print(') || t.contains('def ')) return 'python';
  if (t.contains('void main()') || t.contains('import \'package:flutter')) return 'dart';
  return null;
}

/// Geçici eşleme (ör. highlight paketinde C yoksa).
String? mapUnsupportedLang(String? lang) {
  if (lang == null) return null;
  if (lang == 'c') return 'cpp'; // geçici fallback
  return lang;
}

/// Tek satırlı kodu biraz okunur kıl (opsiyonel).
String smartBreaks(String code) {
  if (code.contains('\n')) return code;
  return code
      .replaceAll('; ', ';\n')
      .replaceAll(';', ';\n')
      .replaceAll('{', '{\n')
      .replaceAll('} ', '\n}\n')
      .replaceAll('}', '\n}')
      .replaceAll(RegExp(r'\breturn\b'), '\nreturn');
}
