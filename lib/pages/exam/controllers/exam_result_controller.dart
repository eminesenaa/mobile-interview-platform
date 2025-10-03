import 'package:get/get.dart';

class ExamResultController extends GetxController {
  final score = 80; // mock
  final correct = 16;
  final wrong = 4;
  final unanswered = 0;
  final xp = 20;

  final topicStats = [
    {"topic": "Data Science", "percent": 0.34},
    {"topic": "Java", "percent": 0.08},
    {"topic": "Machine Learning", "percent": 0.26},
  ];
}
