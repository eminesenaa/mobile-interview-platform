// lib/pages/exam/exam_overview_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/exam.dart';
import 'package:interview_project/pages/exam/exam_page.dart';

class ExamOverviewPage extends StatelessWidget {
  final Exam exam;
  const ExamOverviewPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exam.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${exam.duration.inMinutes} min'),
            const SizedBox(height: 12),
            Text('Questions: ${exam.questions.length}'),
            const Spacer(),
            FilledButton(
              // constructor boş; exam nesnesi Get.arguments ile geçiyor
              onPressed: () => Get.to(() => const ExamPage(), arguments: exam),
              child: const Text('Start Exam'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
