// ===================== File: exam_home_page.dart =====================
// Purpose:
// Redesigned Exam Home Page (centered content)
//
// Improvements:
// - Centered cards area
// - Better vertical balance
// - No scroll
// - Backend untouched
// ======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/models/exam.dart';
import 'package:interview_project/pages/exam/take/exam_page.dart';
import 'package:interview_project/pages/exam/create/create_exam_sheet.dart';
import 'package:interview_project/pages/exam/services/ai_duration_service.dart';
import 'package:interview_project/pages/exam/services/exam_factory.dart';

import '../../../constants/constants.dart';
import 'widgets/exam_option_card.dart';

// 🔥 NEW WIDGETS
import 'widgets/exam_home_header.dart';
import 'widgets/exam_wave_divider.dart';

class ExamHomePage extends StatelessWidget {
  const ExamHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AiDurationServiceStub();
    final factory = ExamFactoryFirebase(ai);

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
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

      // ================= BODY =================
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              const ExamHomeHeader(),

              const SizedBox(height: AppSpacing.md),

              // ================= DIVIDER =================
              const ExamWaveDivider(),

              const SizedBox(height: AppSpacing.md),

              // 🔥 BURASI KRİTİK
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ================= RANDOM EXAM =================
                      ExamOptionCard(
                        icon: PhosphorIcons.shuffle(PhosphorIconsStyle.regular),
                        title: 'Random Exam',
                        description:
                            'Start instantly with a random exam based on your level.',
                        onTap: () async {
                          try {
                            final Exam exam =
                                await factory.fromRandom(count: 10);
                            Get.to(() => const ExamPage(), arguments: exam);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ================= OR TEXT =================
                      Text(
                        'OR',
                        style: AppTextStyles.label.copyWith(
                            fontSize: 16,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ================= CREATE EXAM =================
                      ExamOptionCard(
                        icon: PhosphorIcons.slidersHorizontal(
                          PhosphorIconsStyle.regular,
                        ),
                        title: 'Create Your Exam',
                        description:
                            'Select topics, difficulty, and question types to build a custom exam.',
                        onTap: () => Get.to(() => const CreateExamSheet()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
