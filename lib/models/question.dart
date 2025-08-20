// ===================== File: lib/models/question.dart =====================
// Purpose: Uygulamadaki soruların veri modelini tanımlar.
//          JSON (API/Local) ile dönüştürülebilir, filtreleme/arayüz için kullanılır.
//
// Notlar:
// - `enum` yapısı ile QuestionType / Difficulty gibi sabit değerler tutulur.
// - `Question` class'ı: bir sorunun başlık, açıklama, zorluk, konu, etiketler,
//   tip (MCQ, Coding vs.) gibi tüm alanlarını kapsar.
// ==========================================================================

/// Soru tipleri (ör. çoktan seçmeli, kodlama, vb.)
enum QuestionType {
  mcq,
  shortAnswer,
  coding,
  fillBlank,
  debugging,
  // TODO: İleride yeni tip eklenirse buraya eklenecek.
}

/// Soru zorluk seviyeleri
enum Difficulty {
  easy,
  easy_medium,
  medium,
  medium_hard,
  hard,
}

enum Status {
  todo,
  solved,
}

/// Bir soru nesnesini temsil eder.
/// - `id`: veritabanı veya local JSON içindeki benzersiz kimlik
/// - `title`: soru başlığı
/// - `description`: açıklama / soru metni
/// - `topic`: soru kategorisi (ör. "Algorithms", "OOP", "Networking")
/// - `difficulty`: kolay-orta-zor
/// - `status`: çözülme durumu (örn. "unsolved", "in-progress", "solved")
/// - `tags`: ekstra anahtar kelimeler (örn. ["array", "binary search"])
/// - `type`: QuestionType (mcq, coding, essay)
class Question {
  final String id;
  final String title;
  final String? description;
  final String topic;
  final Difficulty difficulty;
  final Status status;
  final List<String> tags;
  final QuestionType type;

  final List<String>? options;
  final String? correctAnswer;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.difficulty,
    required this.status,
    required this.tags,
    required this.type,
    this.options,
    this.correctAnswer,
  });
}