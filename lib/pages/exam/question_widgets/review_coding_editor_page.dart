// lib/pages/exam/question_widgets/review_coding_editor_page.dart
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';

class ReviewCodingEditorPage extends StatelessWidget {
  final Question question;
  final String code;

  const ReviewCodingEditorPage({
    super.key,
    required this.question,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.title ?? "Code Question",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    code.isEmpty ? "// No code submitted." : code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {},
                child: const Text(
                  "See AI Explanation",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
