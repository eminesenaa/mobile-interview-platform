import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/services/ai/ai_service.dart';

import '../services/xp_service.dart';
import '../services/solve_service.dart';
import '../../runner/controller/question_runner_controller.dart';

/// =======================================================
///  FILL IN BLANK CONTROLLER
/// =======================================================
///
/// Responsibilities:
/// - Parse blank count from codeTemplate (___)
/// - Manage user inputs for each blank
/// - Control submit availability via Runner
/// - Handle AI evaluation + XP + Firestore save
/// - Expose unified state for AiFeedbackWidget
///
class FillBlankController extends GetxController {
  final Question question;

  FillBlankController(this.question);

  /// User answers for each blank (index-based)
  final RxList<String> answers = <String>[].obs;

  /// Submission state (MCQ ile aynı pattern)
  final RxBool isSubmitted = false.obs;

  /// Loading state
  final RxBool isEvaluating = false.obs;

  /// AI evaluation result
  final Rx<AiEvaluateResult?> aiMeta = Rx<AiEvaluateResult?>(null);

  /// Earned XP after evaluation
  final RxInt earnedXp = 0.obs;

  final solveState = SolveState.idle.obs;

  final AiService _ai = Get.find<AiService>();

  // =======================================================
  //  INIT
  // =======================================================

  @override
  void onInit() {
    super.onInit();
    _initializeBlanks();
  }

  /// Count blanks ONLY from codeTemplate (single source of truth)
  void _initializeBlanks() {
    final code = question.codeTemplate;
    final desc = question.description;

    int blankCount = 0;

    if (code != null && code.isNotEmpty) {
      blankCount = RegExp(r'___').allMatches(code).length;
    } else if (desc != null && desc.isNotEmpty) {
      blankCount = RegExp(r'___').allMatches(desc).length;
    }

    answers.assignAll(List.filled(blankCount, ''));

    _updateCanSubmit();
  }

  // =======================================================
  //  USER INPUT
  // =======================================================

  void updateAnswer(int index, String value) {
    if (index < 0 || index >= answers.length) return;

    answers[index] = value;

    // 🔑 Kullanıcı tekrar yazmaya başladıysa
    // önceki submit state’ini sıfırla
    if (solveState.value == SolveState.solvedWrong ||
        solveState.value == SolveState.solvedCorrect) {
      isSubmitted.value = false;
      aiMeta.value = null;
      earnedXp.value = 0;
      solveState.value = SolveState.idle;
    }

    _updateCanSubmit();
  }

  void _updateCanSubmit() {
    final allFilled =
        answers.isNotEmpty && answers.every((e) => e.trim().isNotEmpty);

    solveState.value = allFilled ? SolveState.canSubmit : SolveState.idle;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(allFilled);
    }
  }

  // =======================================================
  //  SUBMIT (Runner bunu çağırır)
  // =======================================================

  Future<void> submit() async {
    if (answers.isEmpty) return;

    final userAnswers = answers.map((e) => e.trim()).toList();

    if (userAnswers.any((e) => e.isEmpty)) {
      Get.snackbar(
        'Incomplete',
        'Please fill in all blanks before submitting.',
      );
      return;
    }

    solveState.value = SolveState.submitting;
    isSubmitted.value = true;

    await _evaluateWithAi(userAnswers);
  }

  // =======================================================
  //  AI EVALUATION
  // =======================================================

  Future<void> _evaluateWithAi(List<String> userAnswers) async {
    isEvaluating.value = true;

    try {
      final res = await _ai.evaluate(
        question: question,
        userAnswer: userAnswers.join(' | '),
      );

      aiMeta.value = res;

      // XP calculation (MCQ ile birebir aynı)
      final score = (res.score ?? 0).toInt();
      final xp = XpService.computeXp(
        baseXp: question.xp,
        score: score,
      );

      earnedXp.value = xp;

      // Persist result
      await SolveService.savePracticeResult(
        question: question,
        score: score,
        earnedXp: xp,
      );
      solveState.value =
          res.correct ? SolveState.solvedCorrect : SolveState.solvedWrong;
    } catch (e, st) {
      solveState.value = SolveState.solvedWrong;
      print('AI error (fill blank): $e\n$st');

      Get.snackbar(
        'AI error',
        'Something went wrong. Please try again.',
      );
    } finally {
      isEvaluating.value = false;
    }
  }

  void resetBlanks() {
    for (var i = 0; i < answers.length; i++) {
      answers[i] = '';
    }

    isSubmitted.value = false;
    isEvaluating.value = false;
    aiMeta.value = null;
    earnedXp.value = 0;
    solveState.value = SolveState.idle;

    if (Get.isRegistered<QuestionRunnerController>()) {
      Get.find<QuestionRunnerController>().setCanSubmit(false);
    }
  }
}
