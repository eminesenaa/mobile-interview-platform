import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/exam.dart';
import '../main_view.dart';
import 'controllers/exam_result_controller.dart';
import 'exam_home_page.dart';
import 'exam_review_page.dart';
import 'widgets/score_circle.dart';
import 'widgets/answer_summary_row.dart';
import 'widgets/topic_charts.dart';
import 'widgets/xp_reward.dart';
import 'widgets/result_actions.dart';

class ExamResultPage extends StatelessWidget {
  const ExamResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ExamResultController());
    final args = Get.arguments;
    final Exam? exam = args is Exam ? args : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Exam Result"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(
                () => const MainView(initialIndex: 2));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text("You have completed your exam",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Here is your result"),
            const SizedBox(height: 24),

            // Puan
            ScoreCircle(score: c.score, total: 100),

            const SizedBox(height: 24),

            // Doğru/Yanlış/Boş kutuları
            AnswerSummaryRow(
              correct: c.correct,
              wrong: c.wrong,
              unanswered: c.unanswered,
            ),

            const SizedBox(height: 24),

            // Topic bazlı grafikler
            const TopicCharts(
              topicPercents: {
                "Java": 0.8,
                "Data Structures": 0.65,
                "Algorithms": 0.5,
                "Machine Learning": 0.26,
              },
            ),

            const SizedBox(height: 24),

            // XP ödülü
            XpRewardCard(xp: c.xp),

            const SizedBox(height: 24),

            // Butonlar
            ResultActions(
              onReview: () {
                final reviewExam = c.exam.copyWith(
                  answers: c.latestAnswers,
                  stats: {
                    'correct': c.correct,
                    'wrong': c.wrong,
                    'unanswered': c.unanswered,
                  },
                  aiFeedback: const {}, // ileride dolduracağız
                );
                Get.to(() => const ExamReviewPage(), arguments: reviewExam);
              },
              onSave: () {
                // Exam kaydetme işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Exam saved to library!")),
                );
              },
              examId: c.exam.id, // ✅ eklendi — required parametreyi karşılıyor
            ),
          ],
        ),
      ),
    );
  }
}
