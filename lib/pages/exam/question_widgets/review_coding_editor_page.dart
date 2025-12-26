import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/exam.dart';
import '../../../models/question.dart';
import '../controllers/exam_controller.dart';
import '../controllers/exam_review_controller.dart';
import '../review/exam_review_page.dart';

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
    // 🧩 exam controller’dan senkronize kodu çekelim
    String codeText = '';
    if (Get.isRegistered<ExamReviewController>(tag: examId)) {
      final reviewCtrl = Get.find<ExamReviewController>(tag: examId);
      final answer = reviewCtrl.answers[question.id];
      if (answer is Map && answer.containsKey('code')) {
        codeText = answer['code'] ?? '';
      } else if (answer is String) {
        codeText = answer;
      }
    }

    final codeController = CodeController(
      text: codeText.isNotEmpty ? codeText : (question.codeTemplate ?? ''),
      language: null,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
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
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            // Sağ: toggle ikonu
            IconButton(
              tooltip: "Back to Review",
              icon: const Icon(Icons.code, color: Colors.white),
              onPressed: () {
                // ✅ Güvenli dönüş: önceki review sayfasını replace etmeden dön
                final args = Get.arguments;
                Exam? exam;

                if (args is Map<String, dynamic> && args['exam'] != null) {
                  exam = args['exam'];
                } else if (args is Exam) {
                  exam = args;
                }

                if (exam != null) {
                  // stack’teki Review sayfasına direkt dön
                  Get.until((route) => Get.currentRoute == '/ExamReviewPage');
                  Get.back(result: exam);
                } else {
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Text(
                  codeController.text,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
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
