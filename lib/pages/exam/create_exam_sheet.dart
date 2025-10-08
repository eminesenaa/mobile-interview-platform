import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';

// Controllers
import 'package:interview_project/pages/exam/controllers/create_exam_controller.dart';
import 'package:interview_project/pages/exam/controllers/exam_controller.dart';

// Pages
import 'package:interview_project/pages/exam/exam_page.dart';

// Widgets
import 'package:interview_project/pages/exam/widgets/section.dart';
import 'package:interview_project/pages/exam/widgets/multi_select_field.dart';
import 'package:interview_project/pages/exam/widgets/difficulty_picker.dart';
import 'package:interview_project/pages/exam/widgets/types_picker.dart';
import 'package:interview_project/pages/exam/widgets/count_slider.dart';

class CreateExamSheet extends StatelessWidget {
  const CreateExamSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CreateExamController());

    return Scaffold(
      appBar: AppBar(title: const Text('Customize Exam')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Topics
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

          // Tags
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

          // Difficulty
          Section(
            title: 'Difficulty',
            child: DifficultyPicker(selected: c.difficulties),
          ),

          // Types
          Section(
            title: 'Question Types',
            child: TypesPicker(selected: c.types, options: c.availableTypes),
          ),

          // Count
          Section(
            title: 'Question Count',
            child: CountSlider(count: c.count),
          ),

          const SizedBox(height: 12),

          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              // 🔹 Yeni sistem: sınavı oluştur ve sayfaya yönlendir
              final examController = await ExamController.createFromFilters();

              if (examController.exam.questions.isEmpty) {
                Get.snackbar('No Questions Found', 'Try relaxing your filters.');
                return;
              }

              Get.to(() => ExamPage(), arguments: examController.exam);
            },
            child: const Text('Create Exam'),
          ),
        ],
      ),
    );
  }
}
