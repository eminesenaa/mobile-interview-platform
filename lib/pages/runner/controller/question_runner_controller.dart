// ============================================================================
// File: lib/pages/runner/controller/question_runner_controller.dart
// Purpose: Soru koşum (runner) akışı için merkezi controller.
// Düzenleme Notu: Aşağıdaki kodun tek bir satırı bile değiştirilmemiştir.
//                 Yalnızca bölümlere ayrılarak yeniden sıralanmıştır.
// ============================================================================

import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../question_types/controllers/coding_controller.dart';
import '../../question_types/controllers/fill_blank_controller.dart';
import '../../question_types/controllers/mcq_controller.dart';
import '../../question_types/controllers/short_answer_controller.dart';
import '../question_feed.dart';

// ============================================================================
// [1] CONTROLLER TANIMI & ALANLAR
// ============================================================================
class QuestionRunnerController extends GetxController {
  // --- Feed ve index kontrolü ---
  final feed = Rxn<QuestionFeed>();
  final currentIndex = 0.obs;

  // --- İşlem/submit durumları ---
  final isSubmitting = false.obs;

  //final canSubmit = false.obs; // Tip widget “valid” sinyali verir.
  final isLocked = false.obs; // Submit sonrası kilit (opsiyonel)

  // --- Mevcut soru ve cevap payload ---
  final currentQuestion = Rxn<Question>(); // UI render kaynağı
  dynamic answerPayload;

  // --- Soru cache'i ---
  final _cache = <String, Question>{};

  /// EDITOR & SUBMIT ENTEGRASYONU — Coding için eklendi
  final RxBool isEditorOpen = false.obs; // Editor açık mı? (submit bloklanır)
  final RxBool canSubmit = false.obs; // Çocuk widget'tan gelen valid bilgisi
  Map<String, dynamic>? _answerPayload; // Çocuk widget'tan gelen payload

  // ========================================================================
  // [2] GETTER'LAR (Sadece-okunur arayüz)
  // ========================================================================
  bool get editorOpen => isEditorOpen.value;

  bool get submitEnabled => canSubmit.value && !isEditorOpen.value;

  bool get hasPrev => currentIndex.value > 0;

  bool get hasNext =>
      feed.value != null && currentIndex.value < feed.value!.length - 1;

  String get positionLabel =>
      "${currentIndex.value + 1}/${feed.value?.length ?? 0}";

  // ========================================================================
  // [3] YAŞAM DÖNGÜSÜ / BAŞLATMA
  // ========================================================================
  void init(QuestionFeed f) {
    _cache.clear();
    feed.value = f;
    currentIndex.value = f.startIndex;
    _loadQuestionAt(f.startIndex);
    // _prefetchAround(f.startIndex); // hazır olunca açarsın
    _resetAnswerState(); // aşağıda eklendi
  }

  // ========================================================================
  // [4] SORU YÜKLEME / GEZİNME (public gezinti API'leri)
  // ========================================================================
  Future<void> loadQuestionAt(int idx) async {
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

  Future<void> next() async {
    if (!hasNext) return;
    currentIndex.value++;
    await _loadQuestionAt(currentIndex.value);
    // _prefetchAround(currentIndex.value);
  }

  Future<void> prev() async {
    if (!hasPrev) return;
    currentIndex.value--;
    await _loadQuestionAt(currentIndex.value);
    // _prefetchAround(currentIndex.value);
  }

  void onQuestionIndexChanged(int i) {
    closeEditor();
    // mevcut index güncelleme mantığın burada devam eder...
  }

  // ========================================================================
  // [5] SORU YÜKLEME (private yardımcılar)
  // ========================================================================
  Future<void> _loadQuestionAt(int idx) async {
    final f = feed.value!;
    Question? q;

    if (f.questions != null && f.questions!.length > idx) {
      q = f.questions![idx];
    } else {
      final id = f.questionIds[idx];
      q = _cache[id];
      q ??= await _fetchQuestionById(id);
      _cache[id] = q!;
    }

    currentQuestion.value = q;
    canSubmit.value = false;
    isLocked.value = false;
    answerPayload = null;
  }

  Future<Question> _fetchQuestionById(String id) async {
    final f = feed.value;
    if (f != null && f.questions != null) {
      for (final q in f.questions!) {
        if (q.id == id) return q;
      }
    }
    final cached = _cache[id];
    if (cached != null) return cached;
    throw StateError('No fetch impl for $id');
  }

  void _prefetchAround(int idx) {
    // disabled: we don't have a fetch service yet
  }

  // ========================================================================
  // [6] CEVAP / VALIDASYON / SUBMIT AKIŞI
  // ========================================================================
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
          {
            final mcq = Get.find<McqController>(tag: q.id);
            await mcq.submit();
            break;
          }
        case QuestionType.shortAnswer:
          {
            final sa = Get.find<ShortAnswerController>(tag: q.id);
            await sa.submit();
            break;
          }
        case QuestionType.fillBlank:
          {
            final fb = Get.find<FillBlankController>(tag: q.id);
            await fb.submitAnswersWithAI();
            break;
          }
        case QuestionType.coding:
          {
            // 1) Editor açıksa submit’i blokla
            if (isEditorOpen.value) {
              Get.snackbar(
                  'Editor is open', 'Please close the editor before sending.');
              break;
            }
            // 2) Controller’dan veya runner’daki cache’ten payload’ı toparla
            CodingController? cc;
            if (Get.isRegistered<CodingController>(tag: q.id)) {
              cc = Get.find<CodingController>(tag: q.id);
            }

            final Map<String, dynamic>? p =
                (_answerPayload ?? cc?.payload) as Map<String, dynamic>?;
            final String? code = p?['code'] as String?;
            final bool valid =
                cc?.isValid ?? (code != null && code.trim().isNotEmpty);

            if (!valid) {
              Get.snackbar('Empty answer', 'Write some code to enable Send.');
              break;
            }

            // 3) Gönderim (şimdilik taklit; API bağlayınca burayı değiştir)
            final body = <String, dynamic>{
              'questionId': q.id,
              'type': 'coding',
              'answer': p, // p null olabilir; API tarafında kontrol et
            };
            // TODO: await api.submitAnswer(body);
            // print veya telemetry:
            // debugPrint('[Submit] coding -> $body');

            // 4) (opsiyonel) cc tarafında ekstra işlemler olacaksa:
            // await cc?.finalize(); // ileride eklersin

            break;
          }
        case QuestionType.debugging:
          {
            // TODO: debugging akışı eklenebilir
            break;
          }
      }

      isLocked.value = true; // gönderimden sonra inputları kilitle
    } finally {
      isSubmitting.value = false;
    }
  }

  // ========================================================================
  // [7] EDITOR / CODING AKIŞI (flag ve payload yönetimi)
  // ========================================================================
  void toggleEditor() => isEditorOpen.toggle();

  bool _isCoding(Question q) {
    // ✅ ENUM kıyası — doğru
    return q.type == QuestionType.coding;
  }

  /// Coding (ve diğer tiplerde ortak) – View'dan payload ve valid sinyali al
  void setAnswerPayload(Map<String, dynamic>? p) {
    _answerPayload = p;
  }

  void setCanSubmit(bool v) {
    canSubmit.value = v;
  }

  /// Editor akışı – şimdi sadece flag; bir sonraki adımda sayfa/route açacağız
  void openEditor(Question q) {
    isEditorOpen.value = true;
    // Örn: Get.to(() => CodingEditorView(...)) ile açılacak.
    // Editor kapatıldığında closeEditor() çağrılacak.
  }

  void closeEditor() {
    isEditorOpen.value = false;
  }

  void flushCodingDraftIfAny() {
    // İstersen taslağı burada persist edebilirsin.
  }

  // ========================================================================
  // [8] DURUM SIFIRLAMA / YARDIMCI
  // ========================================================================
  /// Soru değiştiğinde/ileri-geri – submit & payload & editor state sıfırla
  void _resetAnswerState() {
    isEditorOpen.value = false;
    canSubmit.value = false;
    _answerPayload = null;
  }
}
