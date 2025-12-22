import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../runner/controller/question_runner_controller.dart';
import '../controllers/coding_controller.dart';

class CodingEditorPage extends StatelessWidget {
  final Question question;

  const CodingEditorPage({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.find<CodingController>(tag: question.id);

    return WillPopScope(
      onWillPop: () async {
        // Editor kapanırken runner state temizliği
        final rc = Get.find<QuestionRunnerController>();
        rc.closeEditor();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Coding Editor',
            style: AppTextStyles.headline,
          ),
          actions: [
            IconButton(
              tooltip: 'Return to question',
              icon: PhosphorIcon(
                PhosphorIcons.code(PhosphorIconsStyle.regular),
                size: 26,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                final rc = Get.find<QuestionRunnerController>();
                rc.closeEditor();
                Get.back();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDark =
                    Theme.of(context).brightness == Brightness.dark;

                final highlightTheme =
                isDark ? atomOneDarkTheme : githubTheme;

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(AppRadius.lg),
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
                    data: CodeThemeData(
                      styles: highlightTheme,
                    ),
                    child: CodeField(
                      controller: controller.codeController,
                      expands: true,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
