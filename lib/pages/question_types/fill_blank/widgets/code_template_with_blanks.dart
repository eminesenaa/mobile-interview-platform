// lib/pages/question_types/fill_blank/widgets/code_template_with_blanks.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import 'blank_input_chip.dart';
import 'code_line_widget.dart';

/// =======================================================
///  UI WIDGET
/// =======================================================
///
/// Renders a code template with inline blanks (Fill in Blank).
///
/// - Code text is read-only
/// - `___` placeholders become editable inputs
/// - Line wrapping is preserved
/// - No horizontal scrolling
///
class CodeTemplateWithBlanksView extends StatelessWidget {
  final String codeTemplate;

  /// Reactive answers list from controller
  final RxList<String> answers;

  /// Callback when a blank input changes
  final void Function(int index, String value) onChanged;

  const CodeTemplateWithBlanksView({
    super.key,
    required this.codeTemplate,
    required this.answers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final parsedLines = CodeTemplateParser.parse(codeTemplate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parsedLines.map((lineParts) {
          return CodeLineWidget(
            parts: lineParts,
            answers: answers,
            onChanged: onChanged,
          );
        }).toList(),
      ),
    );
  }
}

/// =======================================================
///  PARSED CODE MODEL
/// =======================================================

/// Base type for a parsed code fragment
sealed class CodePart {}

/// Read-only code text
class CodeText extends CodePart {
  final String text;

  CodeText(this.text);
}

/// Blank placeholder (represents ___)
class CodeBlank extends CodePart {
  final int index;

  CodeBlank({required this.index});
}

/// =======================================================
///  CODE TEMPLATE PARSER
/// =======================================================
///
/// Converts raw code template text into structured [CodePart]s.
///
/// Example input:
///   class Service(___=RegistryMeta):
///
/// Output:
///   [
///     [
///       CodeText("class Service("),
///       CodeBlank(index: 0),
///       CodeText("=RegistryMeta):"),
///     ]
///   ]
///
class CodeTemplateParser {
  CodeTemplateParser._();

  /// Parses the given [codeTemplate] into lines of [CodePart].
  ///
  /// - Preserves line breaks
  /// - Replaces every `___` with a [CodeBlank]
  /// - Assigns deterministic indices to blanks
  static List<List<CodePart>> parse(String codeTemplate) {
    final List<List<CodePart>> result = [];

    int blankCounter = 0;

    // Normalize line endings
    final lines = codeTemplate.replaceAll('\r\n', '\n').split('\n');

    for (final line in lines) {
      final List<CodePart> parts = [];
      int cursor = 0;

      while (true) {
        final nextBlank = line.indexOf('___', cursor);

        // No more blanks in this line
        if (nextBlank == -1) {
          final remaining = line.substring(cursor);
          if (remaining.isNotEmpty) {
            parts.add(CodeText(remaining));
          }
          break;
        }

        // Text before blank
        if (nextBlank > cursor) {
          parts.add(CodeText(line.substring(cursor, nextBlank)));
        }

        // Blank itself
        parts.add(CodeBlank(index: blankCounter));
        blankCounter++;

        // Move cursor after ___
        cursor = nextBlank + 3;
      }

      result.add(parts);
    }

    return result;
  }
}
