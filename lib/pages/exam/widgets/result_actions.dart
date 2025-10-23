import 'package:flutter/material.dart';
import 'package:interview_project/pages/library/widgets/save_exam_to_collection_sheet.dart';

import '../../../constants/colors.dart';

class ResultActions extends StatelessWidget {
  final VoidCallback onReview;
  final VoidCallback onSave;
  final String examId; // ✅ eklendi

  const ResultActions({
    super.key,
    required this.onReview,
    required this.onSave,
    required this.examId, // ✅ eklendi
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor.withOpacity(0.9),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onReview,
          child: const Text("Review Your Exam"),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor.withOpacity(0.9),
            side: BorderSide(color: primaryColor.withOpacity(0.9), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => SaveExamToCollectionSheet(
                examId: examId, // ✅ artık doğrudan parametreden alıyoruz
              ),
            );
          },
          child: const Text('Save Exam to your Library'),
        ),
      ],
    );
  }
}
