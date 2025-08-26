import 'package:get/get.dart';
import '../models/question.dart';
import '../pages/question_types/mcq_question_page.dart';
import '../pages/question_types/short_answer_page.dart';
import '../pages/question_types/fill_in_blank_page.dart';
// coding vs. ekleyebilirsin

class QuestionNavigator {
  static void open(Question q) {
    switch (q.type) {
      case QuestionType.mcq:
        Get.to(() => McqQuestionPage(question: q));
        return;
      case QuestionType.shortAnswer:
        Get.to(() => ShortAnswerPage(question: q));
        return;
      case QuestionType.fillBlank:
        Get.to(() => FillInBlankPage(question: q));
        return;
    // case QuestionType.coding: Get.to(() => CodingQuestionPage(question: q)); return;
      case null:
      default:
        Get.snackbar(
          'Not Implemented',
          'This type is not yet supported.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
    }
  }
}
