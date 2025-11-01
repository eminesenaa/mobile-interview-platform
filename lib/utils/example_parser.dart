// ===================== File: lib/utils/example_parser.dart =====================
// Input/Output/Explanation metinlerini güvenilir şekilde parçalara ayırır.
// ------------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

@immutable
class ParsedExample {
  final String input;
  final String output;
  final String? explanation;

  const ParsedExample({
    required this.input,
    required this.output,
    this.explanation,
  });
}

class ExampleParser {
  // Etiketlerin başlangıçlarını bulmak için (case-insensitive) regex
  static final _marker = RegExp(
    r'(input|output|explanation|note)\s*:',
    caseSensitive: false,
  );

  static final _cleanupPrefix = RegExp(
    r'^(input|output|explanation|note)\s*:',
    caseSensitive: false,
  );


  /// Düz metni "Input / Output / (optional) Explanation" olarak ayrıştırır.
  static ParsedExample parse(String raw) {
    if (raw.trim().isEmpty) {
      return const ParsedExample(input: '', output: '', explanation: null);
    }

    // Satır sonlarını normalize et
    final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (kDebugMode) debugPrint('[EX_PARSE] RAW:\n$text');

    String input = '';
    String output = '';
    String? explanation;

    // 1) Etiketli senaryo: marker’lar arasında dilimle
    final matches = _marker.allMatches(text).toList();
    if (kDebugMode) debugPrint('[EX_PARSE] FOUND markers: ${matches.length}');

    if (matches.isNotEmpty) {
      for (var i = 0; i < matches.length; i++) {
        final m = matches[i];
        final label = m.group(1)!.toLowerCase(); // input/output/explanation/note
        final valueStart = m.end; // ":" sonrası
        final valueEnd = (i + 1 < matches.length) ? matches[i + 1].start : text.length;
        final value = text.substring(valueStart, valueEnd).trim();

        if (kDebugMode) debugPrint('[EX_PARSE] TOK -> $label: "$value"');

        switch (label) {
          case 'input':
            input = value;
            break;
          case 'output':
            output = value;
            break;
          case 'explanation':
          case 'note':
            explanation = value;
            break;
        }
      }
    }

    // 2) Etiketsiz senaryo: 1. satır input, 2. satır output, 3+ explanation
    if (input.isEmpty && output.isEmpty) {
      final lines = text.split('\n');
      if (lines.isNotEmpty) {
        input = lines[0].replaceFirst(_cleanupPrefix, '').trim();
      }
      if (lines.length > 1) {
        output = lines[1].replaceFirst(_cleanupPrefix, '').trim();
      }
      if (lines.length > 2) {
        final rest = lines.sublist(2).join('\n').trim();
        explanation = rest.isEmpty ? null : rest;
      }
    }

    final result = ParsedExample(
      input: input,
      output: output,
      explanation: (explanation?.isEmpty ?? true) ? null : explanation,
    );

    if (kDebugMode) {
      debugPrint(
        '[EX_PARSE] RESULT -> input="$input" | output="$output" | expl="${result.explanation}"',
      );
    }
    return result;
  }
}
