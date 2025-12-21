import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import '../../../../constants/constants.dart';
import '../../../theme/code_highlight_theme.dart';

class ReadOnlyCodeBlock extends StatelessWidget {
  final String code;

  /// highlight.js language key
  /// examples: 'sql', 'python', 'dart', 'javascript'
  final String language;

  const ReadOnlyCodeBlock({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: HighlightView(
        code,
        language: language,
        theme: CodeHighlightTheme.theme,
        padding: EdgeInsets.zero,

        // 🔴 ÖNEMLİ: soft wrap aktif
        textStyle: AppTextStyles.bodySmall.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
          height: 1.55,
        ),
      ),
    );
  }
}
