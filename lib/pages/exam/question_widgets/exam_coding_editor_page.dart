// lib/pages/exam/question_widgets/exam_coding_editor_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/exam_coding_controller.dart';
import '../controllers/exam_controller.dart';
import '../take/widgets/timer_badge.dart';

class ExamCodingEditorPage extends StatefulWidget {
  final Question question;
  final String examId;

  const ExamCodingEditorPage({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  State<ExamCodingEditorPage> createState() => _ExamCodingEditorPageState();
}

class _ExamCodingEditorPageState extends State<ExamCodingEditorPage> {
  late final ExamController examCtrl;
  late final ExamCodingController codingCtrl;
  late final CodeController codeController;

  @override
  void initState() {
    super.initState();

    // 🔑 CodingController mutlaka burada register edilir
    // Get.lazyPut<ExamCodingController>(
    //       () => ExamCodingController(),
    //   tag: widget.question.id,
    //   fenix: true,
    // );

    examCtrl = Get.find<ExamController>(tag: widget.examId);
    codingCtrl = Get.find<ExamCodingController>(tag: widget.question.id);

    // 🔥 CLEAR SİNYALİNİ DİNLE
    ever<int>(examCtrl.clearTick, (_) {
      codingCtrl.clearCode();
      codeController.text = '';
    });

    // 🔥 DAHA ÖNCE YAZILMIŞ KOD VAR MI?
    final saved = examCtrl.answers[widget.question.id];
    if (saved is String && saved.isNotEmpty) {
      codingCtrl.code.value = saved;
    } else {
      codingCtrl.code.value = widget.question.codeTemplate ?? '';
    }


    // 🔹 İlk açılışta:
    // - önceki kod varsa O
    // - yoksa template

    // 🔹 CodeController SADECE BİR KEZ
    codeController = CodeController(
      text: codingCtrl.code.value,
    );

    // 🔄 Yazdıkça iki controller senkron
    codeController.addListener(() {
      final text = codeController.text;
      codingCtrl.code.value = text;
      examCtrl.saveAnswer(widget.question.id, text);
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightTheme = isDark ? atomOneDarkTheme : githubTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 16,
        automaticallyImplyLeading: false,

        // 🔥 Timer SADECE Obx içinde
        title: Obx(() {
          final secondsLeft = examCtrl.state.value.secondsLeft;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Coding Editor',
                style: AppTextStyles.headline,
              ),
              Row(
                children: [
                  TimerBadge(secondsLeft: secondsLeft),
                  IconButton(
                    tooltip: 'Back to Question',
                    icon: PhosphorIcon(
                      PhosphorIcons.code(PhosphorIconsStyle.regular),
                      size: 22,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
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
