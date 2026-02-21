// lib/models/duel_player.dart

/// Bir düello içerisindeki oyuncu state modeli
class DuelPlayer {
  final String userId;
  final String username;
  final String? avatarUrl;

  int score;
  int correctCount;
  int totalXpGained;

  /// Mevcut soruya cevap verip vermediği
  bool answeredCurrentQuestion;

  /// Seçtiği şık (MCQ için)
  int? selectedOptionIndex;

  /// Soruyu kaç saniyede cevapladı (hız bonusu için)
  int? answerTimeSeconds;

  DuelPlayer({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.score = 0,
    this.correctCount = 0,
    this.totalXpGained = 0,
    this.answeredCurrentQuestion = false,
    this.selectedOptionIndex,
    this.answerTimeSeconds,
  });

  /// Yeni soru başladığında oyuncu state'ini sıfırlamak için
  void resetForNextQuestion() {
    answeredCurrentQuestion = false;
    selectedOptionIndex = null;
    answerTimeSeconds = null;
  }
}