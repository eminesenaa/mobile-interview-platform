import 'dart:async';
import 'package:get/get.dart';
import '../../../models/duel_match.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_result.dart';
import '../../../models/question.dart';
import '../duel_result_page.dart';

class DuelGameController extends GetxController {
  final DuelMatch initialMatch;

  DuelGameController(this.initialMatch);

  // ==============================
  // REACTIVE STATE
  // ==============================

  final match = Rx<DuelMatch?>(null);
  final remainingSeconds = 0.obs;

  Timer? _questionTimer;

  // ==============================
  // LIFECYCLE
  // ==============================

  @override
  void onInit() {
    super.onInit();

    // Mock soruları match içine yükle
    initialMatch.questions.clear();
    initialMatch.questions.addAll(_mockQuestions());

    match.value = initialMatch;

    _startQuestion();
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    super.onClose();
  }

  // ==============================
  // QUESTION FLOW
  // ==============================

  void _startQuestion() {
    final currentMatch = match.value!;
    remainingSeconds.value = 10; // 🔥 Şimdilik fix 60

    currentMatch.questionPhase = DuelQuestionPhase.active;

    _startTimer();
  }

  void _startTimer() {
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        }

        if (remainingSeconds.value == 0) {
          timer.cancel();
          _forceReveal();
        }
      },
    );
  }

  // ==============================
  // USER ACTION
  // ==============================

  void selectOption(int optionIndex) {
    final currentMatch = match.value!;
    if (currentMatch.questionPhase != DuelQuestionPhase.active) return;

    currentMatch.submitAnswer(
      userId: _localUserId(),
      selectedOptionIndex: optionIndex,
      answerTimeSeconds: 60 - remainingSeconds.value,
    );

    match.refresh();

    if (currentMatch.allPlayersAnswered) {
      _questionTimer?.cancel();
      _forceReveal();
    }
  }

  String _localUserId() {
    return currentMatchLocalUserId();
  }

  String currentMatchLocalUserId() {
    // Şimdilik local_user sabit
    return 'local_user';
  }

  // ==============================
  // REVEAL FLOW
  // ==============================

  void _forceReveal() {
    final currentMatch = match.value!;

    currentMatch.questionPhase = DuelQuestionPhase.reveal;
    match.refresh();

    Future.delayed(const Duration(seconds: 2), () {
      _afterReveal();
    });
  }

  void _afterReveal() {
    final currentMatch = match.value!;

    if (currentMatch.isLastQuestion) {
      currentMatch.finalizeMatch();
      match.refresh();

      final DuelResult result = currentMatch.buildResult();

      Get.off(
        () => const DuelResultPage(),
        arguments: result,
      );
    } else {
      currentMatch.moveToNextQuestion();
      match.refresh();
      _startQuestion();
    }
  }

  // ==============================
// MOCK QUESTIONS (TEMP)
// ==============================

  List<Question> _mockQuestions() {
    return [
      Question(
        id: 'q1',
        title: 'What is the time complexity of binary search?',
        description: null,
        topic: 'Algorithms',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['binary search', 'complexity'],
        type: QuestionType.mcq,
        options: const [
          'O(n)',
          'O(log n)',
          'O(n log n)',
          'O(1)',
        ],
        correctAnswer: '1',
      ),
      Question(
        id: 'q2',
        title: 'Which data structure uses FIFO?',
        description: null,
        topic: 'Data Structures',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['queue'],
        type: QuestionType.mcq,
        options: const [
          'Stack',
          'Tree',
          'Queue',
          'Graph',
        ],
        correctAnswer: '2',
      ),
      Question(
        id: 'q3',
        title: 'Which keyword is used to define a constant in C++?',
        description: null,
        topic: 'C / C++',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['c++'],
        type: QuestionType.mcq,
        options: const [
          'let',
          'var',
          'const',
          'define',
        ],
        correctAnswer: '2',
      ),
      Question(
        id: 'q4',
        title: 'Which collection does not allow duplicates in Java?',
        description: null,
        topic: 'Java',
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: const ['set'],
        type: QuestionType.mcq,
        options: const [
          'List',
          'Map',
          'Set',
          'ArrayList',
        ],
        correctAnswer: '2',
      ),
      Question(
        id: 'q5',
        title: 'Which SQL command is used to remove a table?',
        description: null,
        topic: 'SQL',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['sql'],
        type: QuestionType.mcq,
        options: const [
          'DELETE',
          'REMOVE',
          'DROP',
          'TRUNCATE',
        ],
        correctAnswer: '2',
      ),
      Question(
        id: 'q6',
        title: 'Which protocol is used for secure web communication?',
        description: null,
        topic: 'Network',
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: const ['https'],
        type: QuestionType.mcq,
        options: const [
          'HTTP',
          'FTP',
          'HTTPS',
          'SMTP',
        ],
        correctAnswer: '2',
      ),
      Question(
        id: 'q7',
        title: 'Which Git command creates a new branch?',
        description: null,
        topic: 'Git',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['git'],
        type: QuestionType.mcq,
        options: const [
          'git checkout',
          'git merge',
          'git branch',
          'git init',
        ],
        correctAnswer: '2',
      ),
      Question(
        id: 'q8',
        title: 'Which algorithm is used for supervised learning?',
        description: null,
        topic: 'Machine Learning',
        difficulty: Difficulty.medium,
        status: Status.todo,
        tags: const ['ml'],
        type: QuestionType.mcq,
        options: const [
          'K-Means',
          'Linear Regression',
          'Apriori',
          'PCA',
        ],
        correctAnswer: '1',
      ),
      Question(
        id: 'q9',
        title: 'Which library is commonly used for data analysis in Python?',
        description: null,
        topic: 'Data Science',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['python'],
        type: QuestionType.mcq,
        options: const [
          'NumPy',
          'React',
          'Flutter',
          'Laravel',
        ],
        correctAnswer: '0',
      ),
      Question(
        id: 'q10',
        title: 'Which skill is most important in team collaboration?',
        description: null,
        topic: 'Soft Skills',
        difficulty: Difficulty.easy,
        status: Status.todo,
        tags: const ['communication'],
        type: QuestionType.mcq,
        options: const [
          'Communication',
          'Silence',
          'Isolation',
          'Ego',
        ],
        correctAnswer: '0',
      ),
    ];
  }
}
