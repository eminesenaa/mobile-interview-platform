import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

class ReviewCodingEditorPage extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewCodingEditorPage({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------
    // REVIEW CONTROLLER → kaydedilmiş kodu al
    // ---------------------------------------------------
    final reviewCtrl = Get.find<ExamReviewController>(tag: examId);

    String codeText = '';
    final answer = reviewCtrl.answers[question.id];

    if (answer is Map && answer['code'] is String) {
      codeText = answer['code'];
    } else if (answer is String) {
      codeText = answer;
    }

    // fallback → template
    if (codeText.trim().isEmpty) {
      codeText = question.codeTemplate ?? '';
    }

    final codeController = CodeController(
      text: codeText,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightTheme = isDark ? atomOneDarkTheme : githubTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,

      // ===================================================
      // APP BAR
      // ===================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.lg,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Code',
              style: AppTextStyles.headline.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              tooltip: 'Back to Review',
              icon: PhosphorIcon(
                PhosphorIcons.code(PhosphorIconsStyle.bold),
                size: 22,
              ),
              onPressed: Get.back,
            ),
          ],
        ),
      ),

      // ===================================================
      // BODY
      // ===================================================
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.border,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: CodeTheme(
              data: CodeThemeData(styles: highlightTheme),
              child: CodeField(
                controller: codeController,
                expands: true,
                readOnly: true,
                // 🔒 REVIEW MODE
                minLines: null,
                maxLines: null,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.4,
                ),
                lineNumberStyle: LineNumberStyle(
                  width: 42,
                  textAlign: TextAlign.right,
                  textStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
