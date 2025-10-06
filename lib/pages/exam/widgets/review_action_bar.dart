// lib/pages/exam/widgets/review_action_bar.dart
import 'package:flutter/material.dart';
import 'package:interview_project/pages/library/widgets/save_exam_to_collection_sheet.dart';
import '../../../constants/colors.dart';

class ReviewActionBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onNavigator;
  final String examId;


  const ReviewActionBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onNavigator,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: onPrev,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Previous'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                label: const Text('Next'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Alt: Save Exam (renkli ve ortalı)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => SaveExamToCollectionSheet(examId: examId),
                );
              },
              child: const Text("Save to Library"),
            ),
          ),
        ],
      ),
    );
  }
}
