import 'package:flutter/material.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/models/duel_enums.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';
import 'mcq_question_widget.dart';

class QuestionRenderer extends StatelessWidget {
  final Question question;
  final DuelGameController controller;
  final DuelQuestionPhase phase;

  const QuestionRenderer({
    super.key,
    required this.question,
    required this.controller,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    // Düelloda sadece MCQ desteklediğimiz için tipi zorla kontrol ediyoruz
    if (question.type == QuestionType.mcq || question.options != null) {
      return MCQQuestionWidget(
        question: question,
        controller: controller,
        phase: phase,
      );
    }

    return const Center(
      child: Text(
        "Unsupported question type or missing options",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
