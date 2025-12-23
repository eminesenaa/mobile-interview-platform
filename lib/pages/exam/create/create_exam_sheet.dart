import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';

// Controllers
import 'package:interview_project/pages/exam/controllers/create_exam_controller.dart';
import 'package:interview_project/pages/exam/controllers/exam_controller.dart';

// Pages
import 'package:interview_project/pages/exam/take/exam_page.dart';

// Widgets
import 'widgets/section.dart';
import 'widgets/multi_select_field.dart';
import 'widgets/difficulty_picker.dart';
import 'widgets/types_picker.dart';
import 'widgets/count_slider.dart';

class CreateExamSheet extends StatelessWidget {
  const CreateExamSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CreateExamController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Customize Exam',
          style: AppTextStyles.headline,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          // TOPICS
          Section(
            title: 'Topics',
            note: 'You can select multiple topics.',
            child: MultiSelectField(
              title: 'Topics',
              optionsList: c.availableTopics,
              selectedSet: c.topics,
              buttonLabel: 'Select Topics',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // TAGS
          Section(
            title: 'Tags',
            note: 'Select any tags you want to include.',
            child: MultiSelectField(
              title: 'Tags',
              optionsList: c.availableTags,
              selectedSet: c.tags,
              buttonLabel: 'Select Tags',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // DIFFICULTY
          Section(
            title: 'Difficulty',
            child: DifficultyPicker(selected: c.difficulties),
          ),

          const SizedBox(height: AppSpacing.md),

          // QUESTION TYPES
          Section(
            title: 'Question Types',
            child: TypesPicker(
              selected: c.types,
              options: c.availableTypes,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // COUNT
          Section(
            title: 'Question Count',
            child: CountSlider(count: c.count),
          ),

          const SizedBox(height: AppSpacing.md),

          // CTA
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: AppTextStyles.button,
            ),
            onPressed: () async {
              final examController = await ExamController.createFromFilters();

              if (examController.exam.questions.isEmpty) {
                Get.snackbar(
                  'No Questions Found',
                  'Try relaxing your filters.',
                );
                return;
              }

              Get.to(
                () => ExamPage(),
                arguments: examController.exam,
              );
            },
            child: const Text('Create Exam'),
          ),
        ],
      ),
    );
  }
}
