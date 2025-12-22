// ============================================================================
// File: lib/pages/runner/controller/question_runner_controller.dart
// Purpose: Soru koşum (runner) akışı için merkezi controller.
// Update: Training Module entegrasyonu eklendi.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../services/ai/ai_service.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/services/library_service.dart';
import '../../question_types/controllers/coding_controller.dart';
import '../../question_types/controllers/fill_blank_controller.dart';
import '../../question_types/controllers/mcq_controller.dart';
import '../../question_types/controllers/short_answer_controller.dart';
import '../question_feed.dart';

// 🔥 TRAINING MODULE ENTEGRASYONU İÇİN EKLENDİ
import '../../practice/controllers/practice_controller.dart';

enum SolveState {
  idle, // ilk açılış, hiçbir input yok
  canSubmit, // input var, send aktif
  submitting, // AI değerlendiriyor
  solvedCorrect, // doğru çözüldü
  solvedWrong, // yanlış çözüldü
}

// ============================================================================
// [1] CONTROLLER TANIMI & ALANLAR
// ============================================================================
class QuestionRunnerController extends GetxController {
  // --- Feed ve index kontrolü ---
  final feed = Rxn<QuestionFeed>();
  final currentIndex = 0.obs;

  // --- İşlem/submit durumları ---
  final isSubmitting = false.obs;

  //final canSubmit = false.obs; // Tip widgets “valid” sinyali verir.
  final isLocked = false.obs; // Submit sonrası kilit (opsiyonel)

  // --- Mevcut soru ve cevap payload ---
  final currentQuestion = Rxn<Question>(); // UI render kaynağı
  dynamic answerPayload;

  // --- Soru cache'i ---
  final _cache = <String, Question>{};

  // Her soru için submit & cevap cache'i
  final Map<String, bool> _canSubmitById = {};
  final Map<String, dynamic> _answerById = {};

  // Bookmark state (UI için)
  final RxBool isBookmarked = false.obs;

  /// EDITOR & SUBMIT ENTEGRASYONU — Coding için eklendi
  final RxBool isEditorOpen = false.obs; // Editor açık mı? (submit bloklanır)
  final RxBool canSubmit = false.obs; // Çocuk widgets'tan gelen valid bilgisi
  Map<String, dynamic>? _answerPayload; // Çocuk widgets'tan gelen payload

  final solveState = SolveState.idle.obs;

  // + AI service instance
  final AiService _ai = AiService();

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
  // [2.1] APP BAR TITLE (Context-aware)
  // ========================================================================

  String get appBarTitle {
    final f = feed.value;
    if (f == null) return 'Question';

    switch (f.source.kind) {
      case QuestionSourceKind.practiceAll:
      case QuestionSourceKind.practiceFilter:
        return 'Practice';

      case QuestionSourceKind.libraryAll:
        return 'Library';

      case QuestionSourceKind.collection:
        return f.source.label ?? 'Collection';

      case QuestionSourceKind.trainingModule:
        return 'Training Module';

      case QuestionSourceKind.exam:
        return 'Exam';

      case QuestionSourceKind.practiceAll: // safety (enum genişlerse)
      default:
        return 'Question';
    }
  }

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
      _restoreStateFor(q);
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
    isEditorOpen.value = false;
    // editörden dönünce kodu runner’a yansıt, send’i buna göre ayarla
    flushCodingDraftIfAny();
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

    // BOOKMARK STATE SYNC
    syncBookmarkState();
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
    // answerPayload = payload;
    // canSubmit.value = valid && !isSubmitting.value && !isLocked.value;

    final q = currentQuestion.value;
    if (q == null) return;

    _answerPayload = payload;
    canSubmit.value = valid;

    // Soru bazlı cache
    _answerById[q.id] = payload;
    _canSubmitById[q.id] = valid;
  }

  Future<void> submit() async {
    solveState.value = SolveState.submitting;

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
            await fb.submit();
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
            // 2) Kodu controller’dan oku
            if (Get.isRegistered<CodingController>(tag: q.id)) {
              final cc = Get.find<CodingController>(tag: q.id);
              await cc
                  .evaluateWithAi(); // Feedback artık view içinde gösterilecek
              _answerById[q.id] = {'code': cc.getCode()};
            } else {
              Get.snackbar('Error', 'CodingController not found');
            }
            break;
          }
        case QuestionType.debugging:
          {
            // TODO: debugging akışı eklenebilir
            break;
          }
      }
      bool? correct;

      switch (q.type) {
        case QuestionType.mcq:
          final c = Get.find<McqController>(tag: q.id);
          correct = c.isCorrect.value;
          break;

        case QuestionType.shortAnswer:
          final c = Get.find<ShortAnswerController>(tag: q.id);
          correct = c.aiMeta.value?.correct;
          break;

        case QuestionType.fillBlank:
          final c = Get.find<FillBlankController>(tag: q.id);
          correct = c.aiMeta.value?.correct;
          break;

        case QuestionType.coding:
          final c = Get.find<CodingController>(tag: q.id);
          correct = c.aiMeta.value?.correct;
          break;

        default:
          correct = null;
      }

      if (correct == true) {
        solveState.value = SolveState.solvedCorrect;
      } else if (correct == false) {
        solveState.value = SolveState.solvedWrong;
      } else {
        solveState.value = SolveState.idle;
      }


      // gönderimden sonra inputları kilitle
      isLocked.value = true;

      // ============================
      // 🔥 TRAINING MODULE PROGRESS HOOK (ACTIVE)
      // ============================
      if (feed.value != null &&
          feed.value!.source.kind == QuestionSourceKind.trainingModule &&
          feed.value!.source.refId != null &&
          feed.value!.questionIds.isNotEmpty &&
          currentIndex.value >= 0 &&
          currentIndex.value < feed.value!.questionIds.length) {
        final moduleId = feed.value!.source.refId!;
        final questionId = feed.value!.questionIds[currentIndex.value];

        // PracticeController üzerinden Backend'e yaz
        if (Get.isRegistered<PracticeController>()) {
          final practiceCtrl = Get.find<PracticeController>();

          await practiceCtrl.markModuleQuestionCompleted(
            moduleId,
            questionId,
          );

          debugPrint(
            '[TrainingProgress] ✔️ SAVED → module=$moduleId, question=$questionId',
          );
        } else {
          debugPrint(
              '[TrainingProgress] ⚠️ PracticeController not found, progress not saved.');
        }
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> onPrimaryAction() async {
    switch (solveState.value) {
      case SolveState.solvedCorrect:
        if (hasNext) {
          await next();
        }
        break;

      case SolveState.solvedWrong:
        _resetCurrentAnswer();
        break;

      default:
        await submit();
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
    //await Get.to(() => CodingEditorPage(question: q));
    //closeEditor(); // dönünce flush + restore
  }

  void closeEditor() {
    isEditorOpen.value = false;
    // editörden dönünce kodu runner’a yansıt, send’i buna göre ayarla
    final q = currentQuestion.value;
    if (q != null && Get.isRegistered<CodingController>(tag: q.id)) {
      final cc = Get.find<CodingController>(tag: q.id);
      final edited =
          cc.edited; // getter eklemiştik: bool get edited => hasEdited.value;
      canSubmit.value = edited;
      _canSubmitById[q.id] = edited;
    }
    //flushCodingDraftIfAny();
  }

  // + Ekrandaki "Send" (FAB) tetikleyicisi
  Future<void> onTapSend() async {
    final q = currentQuestion.value;
    if (q == null) return;
    if (isEditorOpen.value) {
      Get.snackbar('Editor is open', 'Please close the editor before sending.');
      return;
    }

    if (q.type == QuestionType.coding) {
      if (Get.isRegistered<CodingController>(tag: q.id)) {
        final cc = Get.find<CodingController>(tag: q.id);
        if (cc.getCode().trim().isEmpty) {
          Get.snackbar(
              'Empty answer', 'Please type some code (even a single space).');
          return;
        }
        isSubmitting.value = true;
        try {
          await cc.evaluateWithAi(); // feedback UI view’de gösterilecek
          _answerPayload = {'code': cc.getCode()};
          _answerById[q.id] = _answerPayload;

          // 🔥 Coding tipi için de Training Progress kaydı lazım
          await _handleTrainingProgress();
        } catch (e) {
          Get.snackbar('Send failed', e.toString());
        } finally {
          isSubmitting.value = false;
        }
      }
      return;
    }

    // coding dışındaki tiplerde submit zaten switch-case içinden çağrılıyor
    await submit();
  }

  // Coding için özel progress handler (submit metoduna girmeden doğrudan çalışıyorsa)
  Future<void> _handleTrainingProgress() async {
    if (feed.value != null &&
        feed.value!.source.kind == QuestionSourceKind.trainingModule &&
        feed.value!.source.refId != null &&
        feed.value!.questionIds.isNotEmpty &&
        currentIndex.value >= 0 &&
        currentIndex.value < feed.value!.questionIds.length) {
      final moduleId = feed.value!.source.refId!;
      final questionId = feed.value!.questionIds[currentIndex.value];

      if (Get.isRegistered<PracticeController>()) {
        final practiceCtrl = Get.find<PracticeController>();
        await practiceCtrl.markModuleQuestionCompleted(moduleId, questionId);
        debugPrint(
            '[TrainingProgress - Code] ✔️ SAVED → $moduleId, $questionId');
      }
    }
  }

  void flushCodingDraftIfAny() {
    // İstersen taslağı burada persist edebilirsin.
    final q = currentQuestion.value;
    if (q == null || q.type != QuestionType.coding) return;

    if (Get.isRegistered<CodingController>(tag: q.id)) {
      final cc = Get.find<CodingController>(tag: q.id);
      final code = cc.getCode();
      final starter = q.codeTemplate ?? '';
      final hasEdited = (code ?? '') != starter; // boşluk dahil her fark kabul
      _answerPayload = {'code': code};
      canSubmit.value = hasEdited;

      // Cache’le
      _answerById[q.id] = {'code': code};
      _canSubmitById[q.id] = hasEdited;
    }
  }

// Soru değiştiğinde cache’ten geri yükleyen küçük yardımcı
  void _restoreStateFor(Question q) {
    canSubmit.value = _canSubmitById[q.id] ?? false;
    _answerPayload = _answerById[q.id];
  }

  // Current question değiştiğinde bookmark durumunu sync et
  Future<void> syncBookmarkState() async {
    final q = currentQuestion.value;
    if (q == null) return;

    final saved = await LibraryService.instance.isSavedOnce(q.id);

    isBookmarked.value = saved;
  }

  // QuestionRunnerController içine EKLE
  Future<void> onTapBookmark() async {
    final q = currentQuestion.value;
    if (q == null) return;

    if (!Get.isRegistered<LibraryController>()) return;
    final lib = Get.find<LibraryController>();

    await lib.openSaveSheetFor(q.id);

    // Sheet kapandıktan sonra state’i senkronla
    await syncBookmarkState();
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

  void _resetCurrentAnswer() {
    final q = currentQuestion.value;
    if (q == null) return;

    solveState.value = SolveState.idle;
    canSubmit.value = false;
    isLocked.value = false;

    switch (q.type) {
      case QuestionType.mcq:
        Get.find<McqController>(tag: q.id)
          ..selectedIndex.value = -1
          ..isSubmitted.value = false;
        break;

      case QuestionType.shortAnswer:
        Get.find<ShortAnswerController>(tag: q.id)
          ..answer.value = ''
          ..isSubmitted.value = false;
        break;

      case QuestionType.fillBlank:
        Get.find<FillBlankController>(tag: q.id)
          ..answers.assignAll(
            List.filled(
              Get.find<FillBlankController>(tag: q.id).answers.length,
              '',
            ),
          )
          ..isSubmitted.value = false;
        break;

      case QuestionType.coding:
        final c = Get.find<CodingController>(tag: q.id);
        c.setCode(c.question.codeTemplate ?? '');
        break;

      default:
        break;
    }
  }

}
