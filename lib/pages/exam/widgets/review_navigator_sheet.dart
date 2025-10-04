import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../controllers/exam_review_controller.dart';

class ReviewNavigatorSheet extends StatelessWidget {
  final String examId;

  const ReviewNavigatorSheet({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);
    final questions = c.exam.questions;
    final width = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Review Navigator",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Correct: ${c.correctCount}  |  Wrong: ${c.wrongCount}  |  Unanswered: ${c.unansweredCount}",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),

                // Scrollable Grid of question numbers
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final status = c.getQuestionStatus(q.id);

                        Color bgColor;
                        switch (status) {
                          case ReviewStatus.correct:
                            bgColor = Colors.greenAccent.shade700;
                            break;
                          case ReviewStatus.wrong:
                            bgColor = Colors.redAccent.shade200;
                            break;
                          case ReviewStatus.unanswered:
                          default:
                            bgColor = Colors.grey.shade300;
                            break;
                        }

                        return GestureDetector(
                          onTap: () {
                            c.goToQuestion(index);
                            Get.back();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                _buildLegend(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(Colors.greenAccent.shade700, "Correct"),
        _legendItem(Colors.redAccent.shade200, "Wrong"),
        _legendItem(Colors.grey.shade300, "Unanswered"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
