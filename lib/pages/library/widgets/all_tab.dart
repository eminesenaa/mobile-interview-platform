// ===================== File: lib/pages/library/widgets/all_tab.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/question_card.dart';
import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/library_controller.dart';
import 'empty_state.dart';

class LibraryAllTab extends StatelessWidget {
  const LibraryAllTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return StreamBuilder<List<Question>>(
      stream: c.savedQuestionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final raw = snapshot.data!;

        // 🔥 Sadece filtre kısmı reactive olacak
        return Obx(() {
          final items = c.filterQuestions(raw);

          if (items.isEmpty) {
            return const LibraryEmptyState(
              title: 'No saved questions',
              subtitle: 'Start saving questions to see them here.',
              icon: Icons.bookmark_border_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final q = items[i];

              return QuestionCard(
                question: q,
                isSaved: true,
                onTap: () => c.openRunnerAllTab(items, i),
                onSaveTap: () async {
                  await c.openQuestionOptions(q);
                },
              );
            },
          );
        });
      },
    );
  }
}
