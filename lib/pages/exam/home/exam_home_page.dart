import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/models/exam.dart';
import 'package:interview_project/pages/exam/exam_page.dart';
import 'package:interview_project/pages/exam/create/create_exam_sheet.dart';
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';
import 'package:interview_project/pages/exam/services/exam_factory.dart';

import '../../../constants/constants.dart';
import 'widgets/exam_option_card.dart';

class ExamHomePage extends StatelessWidget {
  const ExamHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AiDurationServiceStub();
    final factory = ExamFactoryFirebase(ai);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Exam',
          style: AppTextStyles.headline,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: ExamOptionCard(
                  icon: PhosphorIcons.shuffle(PhosphorIconsStyle.regular),
                  title: 'Random Exam',
                  description:
                      'Start instantly with a randomly generated exam based on your overall level.',
                  onTap: () async {
                    try {
                      final Exam exam = await factory.fromRandom(count: 10);
                      Get.to(() => const ExamPage(), arguments: exam);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ExamOptionCard(
                  icon:
                      PhosphorIcons.slidersHorizontal(PhosphorIconsStyle.regular),
                  title: 'Create Your Exam',
                  description:
                      'Select topics, difficulty, and question types to build a custom exam.',
                  onTap: () => Get.to(() => const CreateExamSheet()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
