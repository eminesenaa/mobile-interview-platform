import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

class ReviewMcqView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewMcqView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);

    // Seçenekleri güvenli string listesine çevir
    final options = (question.options ?? []).map((e) => e.toString()).toList();

    // Cevabı farklı olası formatlardan çöz (String / int index / Map)
    final dynamic raw = c.answers[question.id];
    String? selectedOption;

    if (raw is String && options.contains(raw)) {
      selectedOption = raw;
    } else if (raw is int && raw >= 0 && raw < options.length) {
      selectedOption = options[raw];
    } else if (raw is Map) {
      final dyn =
          raw['selectedIndex'] ?? raw['index'] ?? raw['answer'] ?? raw['value'];
      if (dyn is int && dyn >= 0 && dyn < options.length) {
        selectedOption = options[dyn];
      } else if (dyn is String && options.contains(dyn)) {
        selectedOption = dyn;
      }
    }

    if (options.isEmpty) {
      return const Text(
        "⚠ No options found for this question.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...options.map((opt) {
          final bool isSelected = selectedOption == opt;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: ListTile(
              title: Text(opt),
              leading: Radio<String>(
                value: opt,
                groupValue: selectedOption,
                onChanged: null, // 🔒 Read-only mode
                fillColor: MaterialStateProperty.resolveWith(
                  (states) => isSelected ? primaryColor : Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              // 🔹 Gelecekte: AI explanation modal
            },
            child: const Text(
              "See AI Explanation",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
