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
    switch (question.type) {
      case QuestionType.mcq:
        return MCQQuestionWidget(
          question: question,
          controller: controller,
          phase: phase,
        );

      // 🔮 Future question types
      // case QuestionType.textInput:
      //   return TextInputQuestionWidget(...);

      default:
        return const Center(
          child: Text("Unsupported question type"),
        );
    }
  }
}
