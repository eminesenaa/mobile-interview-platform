import 'package:get/get.dart';
import '../models/question.dart';
import '../pages/question_types/mcq_question_page.dart';
import '../pages/question_types/short_answer_page.dart';
import '../pages/question_types/fill_in_blank_page.dart';
// TODO: coding, debugging için sayfalar eklenebilir.

class QuestionNavigator {
  static void open(Question q) {
    switch (q.type) {
      case QuestionType.mcq:
        Get.to(() => McqQuestionPage(question: q));
        break;

      case QuestionType.shortAnswer:
        Get.to(() => ShortAnswerPage(question: q));
        break;

      case QuestionType.fillBlank:
        Get.to(() => FillInBlankPage(question: q));
        break;

      case QuestionType.coding:
        // Get.to(() => CodingQuestionPage(question: q));
        Get.snackbar(
          'Not Implemented',
          'Coding question page not yet implemented.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case QuestionType.debugging:
        // Get.to(() => DebuggingQuestionPage(question: q));
        Get.snackbar(
          'Not Implemented',
          'Debugging question page not yet implemented.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      default:
        Get.snackbar(
          'Not Implemented',
          'This question type is not yet supported.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;
    }
  }
}
