import 'package:get/get.dart';

import '../../../models/exam.dart';

class ExamResultController extends GetxController {
  late final Exam exam;
  late final Map<String, dynamic> latestAnswers;
  int score = 80;
  int correct = 16;
  int wrong = 4;
  int unanswered = 0;
  int xp = 20;

  String? answerFor(String qid) => latestAnswers[qid]?.toString();

  final topicStats = [
    {"topic": "Data Science", "percent": 0.34},
    {"topic": "Java", "percent": 0.08},
    {"topic": "Machine Learning", "percent": 0.26},
  ];

  /// ✅ ExamResultPage'de kullanılacak exam getter
  // Exam get exam {
  //   if (Get.arguments is Exam) {
  //     return Get.arguments as Exam;
  //   } else {
  //     // fallback exam (hata durumunda)
  //     return Exam(
  //       id: 'unknown',
  //       title: 'Unknown Exam',
  //       duration: const Duration(minutes: 0),
  //       questions: const [],
  //       createdAt: DateTime.now(),
  //     );
  //   }
  // }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Exam) {
      exam = args;
    } else {
      // güvenli fallback
      exam = Exam(
        id: 'unknown',
        title: 'Unknown Exam',
        duration: const Duration(minutes: 0),
        questions: const [],
        createdAt: DateTime.now(),
      );
    }
    latestAnswers = Map<String, dynamic>.from(exam.answers ?? {});
  }
}
