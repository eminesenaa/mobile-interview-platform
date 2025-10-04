import 'package:flutter/material.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_fill_blank_view.dart';
import 'package:interview_project/pages/exam/question_widgets/exam_short_answer_view.dart';

import '../../models/question.dart';

class ExamTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final q = Question(
    //   id: "fill1",
    //   title: "Fill in ___ with the missing keyword in a Java loop.",
    //   type: QuestionType.fillBlank,
    //   description: "This question tests your knowledge of Java control structures. "
    //       "Complete the sentence by filling in the correct keyword used to "
    //       "terminate a loop prematurely.",
    //   topic: "Java Programming",
    //   difficulty: Difficulty.easy,
    //   status: Status.todo,
    //   tags: ["java", "loops", "keywords", "beginner"],
    // );
    final q = Question(
      id: "short1",
      title: "Explain the difference between a stack and a queue.",
      type: QuestionType.shortAnswer,
      description:
          "Provide a brief explanation highlighting how data is inserted "
          "and removed in both stack and queue data structures.",
      topic: "Data Structures",
      difficulty: Difficulty.medium,
      status: Status.todo,
      tags: ["stack", "queue", "data structures", "fundamentals"],
    );

    return Scaffold(
      appBar: AppBar(title: Text("Test FillBlank")),
      // body: ExamFillBlankView(
      //   question: q,
      //   onAnswerChanged: (answers) {
      //     debugPrint("Answers: $answers");
      //   },
      // ),
      body: ExamShortAnswerView(
        question: q,
        onAnswerChanged: (answer) {
          debugPrint("Answer: $answer");
        },
      ),
    );
  }
}
