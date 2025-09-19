// lib/pages/runner/controller/question_runner_controller.dart
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../question_types/controllers/fill_blank_controller.dart';
import '../../question_types/controllers/mcq_controller.dart';
import '../../question_types/controllers/short_answer_controller.dart';
import '../question_feed.dart';

// import your Question model & repo/service

class QuestionRunnerController extends GetxController {
  final feed = Rxn<QuestionFeed>();
  final currentIndex = 0.obs;

  final isSubmitting = false.obs;
  final canSubmit = false.obs;   // Tip widget “valid” sinyali verir.
  final isLocked = false.obs;    // Submit sonrası kilit (opsiyonel)

  final currentQuestion = Rxn<Question>(); // UI render kaynağı

  // Tip-özgü yanıta dair ham veri (ör: seçili index, text vs.)
  dynamic answerPayload;

  // Opsiyonel: detay cache’i (ID -> Question)
  final _cache = <String, Question>{};

  void init(QuestionFeed f) {
    feed.value = f;
    currentIndex.value = f.startIndex;
    _loadQuestionAt(f.startIndex);
    _prefetchAround(f.startIndex);
  }

  bool get hasPrev => currentIndex.value > 0;
  bool get hasNext => feed.value != null && currentIndex.value < feed.value!.length - 1;
  String get positionLabel =>
      "${currentIndex.value + 1}/${feed.value?.length ?? 0}";

  // controller'a ekle
  Future<void> loadQuestionAt(int idx) async {
    // varsa mevcut _loadQuestionAt'ına delegasyon:
    // return _loadQuestionAt(idx);

    // veya doğrudan yükleme mantığın:
    final f = feed.value!;
    Question? q;
    if (f.questions != null && f.questions!.length > idx) {
      q = f.questions![idx];
    } else {
      final id = f.questionIds[idx];
      q = _cache[id] ?? await _fetchQuestionById(id);
      _cache[id] = q!;
    }
    currentQuestion.value = q;
    canSubmit.value = false;
    isLocked.value = false;
    answerPayload = null;
  }


  Future<void> _loadQuestionAt(int idx) async {
    final f = feed.value!;
    Question? q;

    if (f.questions != null && f.questions!.length > idx) {
      q = f.questions![idx];
    } else {
      final id = f.questionIds[idx];
      q = _cache[id];
      q ??= await _fetchQuestionById(id); // repo/service’ten çek
      _cache[id] = q;
    }

    currentQuestion.value = q;
    canSubmit.value = false;
    isLocked.value = false;
    answerPayload = null;
  }

  Future<Question> _fetchQuestionById(String id) async {
    // TODO: kendi service’inle doldur
    throw UnimplementedError();
  }

  void onAnswerChanged(dynamic payload, {required bool valid}) {
    answerPayload = payload;
    canSubmit.value = valid && !isSubmitting.value && !isLocked.value;
  }

  Future<void> submit() async {
    if (!canSubmit.value || currentQuestion.value == null) return;
    isSubmitting.value = true;
    try {
      final q = currentQuestion.value!;

      switch (q.type) {
        case QuestionType.mcq:
          final mcq = Get.find<McqController>(tag: q.id);
          await mcq.submit(); // sende adı farklıysa (submitWithAI vs) onu çağır
          break;

        case QuestionType.shortAnswer:
          final sa = Get.find<ShortAnswerController>(tag: q.id);
          await sa.submit();
          break;

        case QuestionType.fillBlank:
          final fb = Get.find<FillBlankController>(tag: q.id);
          await fb.submitAnswersWithAI();
          break;

        default:
        // diğer tipler henüz yoksa boş bırak
          break;
      }

      isLocked.value = true; // gönderimden sonra inputları kilitle
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> next() async {
    if (!hasNext) return;
    currentIndex.value++;
    await _loadQuestionAt(currentIndex.value);
    _prefetchAround(currentIndex.value);
  }

  Future<void> prev() async {
    if (!hasPrev) return;
    currentIndex.value--;
    await _loadQuestionAt(currentIndex.value);
    _prefetchAround(currentIndex.value);
  }

  void _prefetchAround(int idx) {
    // Opsiyonel: idx±1 prefetch
    final f = feed.value!;
    for (final j in [idx + 1, idx - 1]) {
      if (j >= 0 && j < f.length) {
        final id = f.questions != null ? f.questions![j].id : f.questionIds[j];
        if (!_cache.containsKey(id)) {
          // fire-and-forget
          _fetchQuestionById(id).then((q) => _cache[id] = q).ignore();
        }
      }
    }
  }
}

extension _Ignore on Future {
  void ignore() {}
}
