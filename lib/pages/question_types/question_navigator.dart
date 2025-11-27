// lib/pages/question_types/widgets/question_navigator.dart
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../runner/question_feed.dart';
import '../runner/question_runner_page.dart';


class QuestionNavigator {
  const QuestionNavigator._();

  static void open(Question question) {
    // Tek soruluk feed oluştur
    final feed = QuestionFeed(
      questionIds: [question.id],
      questions: [question],
      startIndex: 0,
      source: const QuestionSourceContext(
        kind: QuestionSourceKind.practiceAll,
        label: "Today's popular",
      ),
    );

    // Normal runner sayfasını aç -> içinde RunnerBottomBar + submit/AI akışı hazır
    Get.to(() => QuestionRunnerPage(feed: feed));
  }
}
