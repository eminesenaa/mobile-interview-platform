// lib/pages/question_types/fill_blank/widgets/code_line_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import 'blank_input_chip.dart';
import 'code_template_with_blanks.dart';

/// =======================================================
///  CODE LINE WIDGET (SYNTAX HIGHLIGHTED, CLEAN BACKGROUND)
/// =======================================================
///
/// - Renders ONE line of code
/// - Syntax highlighted (Python)
/// - Inline editable blanks
/// - No horizontal scroll
/// - Preserves indentation
/// - ❌ No white background (theme root overridden)
///
class CodeLineWidget extends StatelessWidget {
  final List<CodePart> parts;
  final RxList<String> answers;
  final void Function(int index, String value) onChanged;

  const CodeLineWidget({
    super.key,
    required this.parts,
    required this.answers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.start,
        children: parts.map(_buildPart).toList(),
      ),
    );
  }

  /// Builds either syntax-highlighted code or blank input
  Widget _buildPart(CodePart part) {
    if (part is CodeText) {
      return HighlightView(
        part.text,
        language: 'python',
        theme: _transparentGithubTheme(), // 🔑 önemli nokta
        padding: EdgeInsets.zero,
        textStyle: _codeTextStyle,
      );
    }

    if (part is CodeBlank) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: BlankInputChip(
          value: answers[part.index],
          onChanged: (v) => onChanged(part.index, v),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Removes background color coming from githubTheme['root']
  Map<String, TextStyle> _transparentGithubTheme() {
    return githubTheme.map((key, value) {
      if (key == 'root') {
        return MapEntry(
          key,
          value.copyWith(backgroundColor: Colors.transparent),
        );
      }
      return MapEntry(key, value);
    });
  }

  /// Shared monospace text style
  static final TextStyle _codeTextStyle = AppTextStyles.bodySmall.copyWith(
    fontFamily: 'monospace',
    height: 1.45,
    color: AppColors.textPrimary,
  );
}
