// lib/pages/exam/exam_home_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:interview_project/models/exam.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/exam/exam_page.dart';
import 'package:interview_project/pages/exam/create_exam_sheet.dart';

import '../../constants/colors.dart';

/// Exam Home Page
/// Random exam: Firestore'dan random 10 soru çeker.
/// Create exam: filtreli sayfaya yönlendirir.
class ExamHomePage extends StatelessWidget {
  const ExamHomePage({super.key});

  Future<Exam> _createRandomExam() async {
    final db = FirebaseFirestore.instance;

    // 1) Tüm soruları çek
    final snapshot = await db.collection('questions').get();
    final allQuestions = snapshot.docs
        .map((d) => Question.fromFirestore(d.data(), d.id))
        .toList();

    if (allQuestions.isEmpty) {
      throw Exception("No questions found in Firestore");
    }

    // 2) Rastgele sırala
    allQuestions.shuffle(Random());

    // 3) İlk 10 taneyi seç
    final selected = allQuestions.take(10).toList();

    // 4) Exam nesnesi oluştur
    return Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Random Exam",
      duration: const Duration(minutes: 30),
      questions: selected,
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Exam'))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LEFT: Random Exam
                _TapArea(
                  title: 'RANDOM EXAM',
                  onTap: () async {
                    try {
                      final exam = await _createRandomExam();
                      Get.to(() => const ExamPage(), arguments: exam);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                ),
                // middle divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 220,
                  color: ashGrey,
                ),
                // RIGHT: Create Your Exam
                _TapArea(
                  title: 'CREATE YOUR\nEXAM',
                  onTap: () => Get.to(() => const CreateExamSheet()),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: scheme.surface,
    );
  }
}

class _TapArea extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final TextAlign textAlign;
  const _TapArea({
    required this.title,
    required this.onTap,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: Text(
          title,
          textAlign: textAlign,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
