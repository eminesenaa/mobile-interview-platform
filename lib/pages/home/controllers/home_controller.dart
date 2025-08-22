import 'dart:math';
import 'package:get/get.dart';
import '../../../controllers/progress_controller.dart';
import '../../../controllers/question_controller.dart';
import '../../../models/question.dart';

class HomeController extends GetxController {
  final _rng = Random();

  /// Today’s Popular Questions
  final RxList<Question> popularQuestions = <Question>[].obs;

  /// Progress (Your Progress bölümünü besler)
  final ProgressController pc =
  Get.put<ProgressController>(ProgressController(), permanent: true);

  @override
  void onInit() {
    super.onInit();
    _loadPopularQuestions();
  }

  /// Easy / Medium / Hard’tan rastgele 1’er soru seç
  void _loadPopularQuestions() {
    final qc = Get.find<QuestionController>();

    Question? pickOne(Difficulty d) {
      final pool = qc.allQuestions.where((q) => q.difficulty == d).toList();
      if (pool.isEmpty) return null;
      return pool[_rng.nextInt(pool.length)];
    }

    final picks = <Question>[
      if (pickOne(Difficulty.easy) != null) pickOne(Difficulty.easy)!,
      if (pickOne(Difficulty.medium) != null) pickOne(Difficulty.medium)!,
      if (pickOne(Difficulty.hard) != null) pickOne(Difficulty.hard)!,
    ];

    popularQuestions.assignAll(picks);
  }

  /// Pull‑to‑refresh’te çağır
  Future<void> refreshAll() async {
    _loadPopularQuestions();
    // ileride: user/progress güncellemesi eklenebilir
  }
}
