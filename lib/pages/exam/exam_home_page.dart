import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/pages/exam/exam_page.dart';
import 'package:interview_project/pages/exam/create_exam_sheet.dart';
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';
import 'package:interview_project/pages/exam/services/exam_factory.dart';
import '../../constants/colors.dart';

class ExamHomePage extends StatelessWidget {
  const ExamHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AiDurationServiceStub();
    final factory = ExamFactoryFirebase(ai);

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Exam'))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 LEFT: Random Exam
                _TapArea(
                  title: 'RANDOM EXAM',
                  onTap: () async {
                    try {
                      final Exam exam = await factory.fromRandom(count: 10);
                      Get.to(() => const ExamPage(), arguments: exam);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                ),
                // 🔹 Divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 220,
                  color: AppColors.textSecondary,
                ),
                // 🔹 RIGHT: Create Exam
                _TapArea(
                  title: 'CREATE YOUR\nEXAM',
                  onTap: () => Get.to(() => const CreateExamSheet()),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: scheme.surface,
    );
  }
}

class _TapArea extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final TextAlign textAlign;
  const _TapArea({
    required this.title,
    required this.onTap,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: Text(
          title,
          textAlign: textAlign,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
