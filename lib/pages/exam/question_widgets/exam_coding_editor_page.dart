import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import '../../../models/exam.dart';
import '../../../models/question.dart';
import '../controllers/exam_coding_controller.dart';
import '../controllers/exam_controller.dart';
import '../widgets/timer_badge.dart';
import '../../../constants/colors.dart';

class ExamCodingEditorPage extends StatelessWidget {
  final Question question;

  const ExamCodingEditorPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamCodingController>(tag: question.id);

    // 🧩 examId her yerden erişilebilsin diye burada tanımlıyoruz
    final args = Get.arguments;
    String? examId;
    if (args is Map<String, dynamic>) {
      examId = args['examId'];
    } else if (args is Exam) {
      examId = args.id;
    }

    // Tema algılama
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styles = isDark ? atomOneDarkTheme : githubTheme;

    // Template + kullanıcı kodunu birleştir
    final template = question.codeTemplate ?? '';
    if (c.code.value.isEmpty && template.isNotEmpty) {
      // Eğer ilk defa açılıyorsa, template'i controller'a yaz

      if (examId != null) {
        c.updateCode(template, examId, question.id);
      }
    }

    // CodeField controller
    final codeController = CodeController(
      text: c.code.value,
      language: null, // örneğin C++ dersi için dil desteği eklenebilir
    );

    // Kod değişimlerini dinle
    codeController.addListener(() {
      if (examId != null) {
        c.updateCode(codeController.text, examId!, question.id);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 16,
        title: Obx(() {
          // ExamController'ı al
          final args = Get.arguments;
          String? examId;
          if (args is Map<String, dynamic>) {
            examId = args['examId'];
          } else if (args is Exam) {
            examId = args.id;
          }
          final examCtrl = Get.find<ExamController>(tag: examId);
          final secondsLeft = examCtrl.state.value.secondsLeft;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol: soru başlığı
              Expanded(
                child: Text(
                  question.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Sağ: önce timer, sonra code icon
              Row(
                children: [
                  TimerBadge(secondsLeft: secondsLeft),
                  IconButton(
                    tooltip: "Back to Question",
                    icon: const Icon(Icons.code),
                    color: Colors.white,
                    onPressed: Get.back,
                  ),
                ],
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CodeTheme(
                data: CodeThemeData(styles: styles),
                child: CodeField(
                  controller: codeController,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  lineNumberStyle: const LineNumberStyle(
                    width: 40,
                    textAlign: TextAlign.right,
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
