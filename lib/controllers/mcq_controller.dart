import 'package:get/get.dart';
import '../models/question.dart';

/// Çoktan Seçmeli (MCQ) controller
/// - Seçim, doğrulama, reset akışı
/// - Hem index tabanlı (correctIndex) hem string tabanlı (correctAnswer) kontrolü destekler
class McqController extends GetxController {
  McqController(this.question, {this.shuffleOptions = false});

  final Question question;
  final bool shuffleOptions;

  /// Görüntülenecek seçenekler (gerekirse karıştırılmış)
  final options = <String>[].obs;

  /// Kullanıcının seçtiği seçenek index'i (options içinde)
  final selectedIndex = RxnInt();

  /// Doğru/yanlış durumu
  final isSubmitted = false.obs;
  final isCorrect = false.obs;

  /// Eğer question doğru cevabı index ile veriyorsa (örn: correctIndex),
  /// bu alana normalize ederiz. Yoksa string tabanlı kontrol yapılır.
  int? _correctIndexInOptions;

  @override
  void onInit() {
    super.onInit();

    // 1) Options’u hazırla
    final base = (question.options ?? <String>[]).map((e) => e.trim()).toList();
    if (shuffleOptions) {
      base.shuffle();
    }
    options.assignAll(base);

    // 2) Doğru index'i belirlemeye çalış (varsa)
    //   - Öncelik: question.correctIndex
    //   - Alternatif: question.correctAnswer (string) -> options içinde bul
    final idxFromModel = _readCorrectIndexFromModel();
    if (idxFromModel != null && idxFromModel >= 0 && idxFromModel < options.length) {
      // Eğer shuffle yaptıysan index mapping zaten options dizisine göre
      _correctIndexInOptions = idxFromModel;
    } else {
      // String tabanlı eşleştirme (case-insensitive/trim)
      final ans = (question.correctAnswer ?? '').trim();
      if (ans.isNotEmpty) {
        final normAns = _norm(ans);
        final found = options.indexWhere((o) => _norm(o) == normAns);
        _correctIndexInOptions = found == -1 ? null : found;
      } else {
        _correctIndexInOptions = null;
      }
    }
  }

  /// Kullanıcı bir seçenek seçti
  void select(int index) {
    if (isSubmitted.value) return; // submit sonrası kilitliyse değiştirme
    selectedIndex.value = index;
  }

  /// Cevabı kontrol et
  void submit() {
    if (selectedIndex.value == null) {
      Get.snackbar('Seçim yok', 'Lütfen bir seçenek seç.',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      return;
    }

    final ok = _checkCorrect(selectedIndex.value!);
    isCorrect.value = ok;
    isSubmitted.value = true;

    Get.snackbar(
      ok ? 'Tebrikler 🎉' : 'Yanlış',
      ok ? 'Doğru cevap!' : 'Bir kez daha dene ya da doğru cevabı kontrol et.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    // (Opsiyonel) doğruysa solved işaretle
    // try { Get.find<QuestionController>().updateStatus(question.id, Status.solved); } catch (_) {}
  }

  /// Baştan dene
  void reset() {
    selectedIndex.value = null;
    isSubmitted.value = false;
    isCorrect.value = false;
  }

  /// UI renklendirme için: bu index doğru mu?
  bool isOptionCorrect(int index) {
    if (_correctIndexInOptions != null) {
      return index == _correctIndexInOptions;
    }
    // String tabanlı kontrol fallback
    final ans = (question.correctAnswer ?? '').trim();
    if (ans.isEmpty) return false;
    return _norm(options[index]) == _norm(ans);
  }

  /// Doğru seçeneğin index'i (varsa) – highlight için işine yarar
  int? get correctIndex => _correctIndexInOptions;

  // --- internal helpers ---

  bool _checkCorrect(int chosenIndex) {
    if (_correctIndexInOptions != null) {
      return chosenIndex == _correctIndexInOptions;
    }
    final ans = (question.correctAnswer ?? '').trim();
    if (ans.isEmpty) return false;
    return _norm(options[chosenIndex]) == _norm(ans);
  }

  int? _readCorrectIndexFromModel() {
    // Modelinde correctIndex alanı varsa buradan çekmek istersin.
    // Örn: return question.correctIndex;  // yoksa null döndür
    try {
      final dynamic maybeIndex = (question as dynamic).correctIndex;
      if (maybeIndex is int) return maybeIndex;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
