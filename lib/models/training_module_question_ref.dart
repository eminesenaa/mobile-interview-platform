// ============ File: lib/models/training_module_question_ref.dart ============
// Purpose: Bir training module + section içindeki tek bir soruya referans.
//          Question havuzundaki gerçek soruya (Question) sadece id ile bağlanır.
// Notes:
// - Question modelini kopyalamaz; sadece questionId + sırasını + zorluğunu tutar.
// - Kullanıcı ilerlemesi ayrı modelde tutulur (UserTrainingQuestionProgress).
// ==========================================================================

import 'question.dart'; // Difficulty enum’unu yeniden kullanıyoruz.

class TrainingModuleQuestionRef {
  /// Firestore document id (section içindeki subCollection id'si).
  final String id;

  /// Bağlı olduğu module id.
  final String moduleId;

  /// Bağlı olduğu section id.
  final String sectionId;

  /// Ana soru havuzundaki Question document id.
  final String questionId;

  /// Section içindeki sırası (1, 2, 3 ...).
  final int order;

  /// Bu sorunun eğitim planındaki zorluğu.
  /// Not: Question.difficulty ile aynı olmak zorunda değil,
  /// modüle özel yeniden etiketleme yapılabilir.
  final Difficulty difficulty;

  const TrainingModuleQuestionRef({
    required this.id,
    required this.moduleId,
    required this.sectionId,
    required this.questionId,
    required this.order,
    required this.difficulty,
  });

  // ---------------------------------------------------------------------------
  // JSON / Firestore dönüşümleri
  // ---------------------------------------------------------------------------

  /// Firestore dokümanından question ref üretir.
  ///
  /// Beklenen alanlar:
  /// - moduleId   : String
  /// - sectionId  : String
  /// - questionId : String
  /// - order      : int
  /// - difficulty : String? (Difficulty enum name)
  factory TrainingModuleQuestionRef.fromFirestore(
      Map<String, dynamic> data,
      String documentId,
      ) {
    final diffRaw = (data['difficulty'] ?? 'easy').toString();
    final parsedDiff = Difficulty.values.firstWhere(
          (d) => d.name == diffRaw,
      orElse: () => Difficulty.easy,
    );

    return TrainingModuleQuestionRef(
      id: documentId,
      moduleId: (data['moduleId'] ?? '').toString(),
      sectionId: (data['sectionId'] ?? '').toString(),
      questionId: (data['questionId'] ?? '').toString(),
      order: (data['order'] ?? 0) as int,
      difficulty: parsedDiff,
    );
  }

  factory TrainingModuleQuestionRef.fromJson(Map<String, dynamic> j) {
    final diffRaw = (j['difficulty'] ?? 'easy').toString();
    final parsedDiff = Difficulty.values.firstWhere(
          (d) => d.name == diffRaw,
      orElse: () => Difficulty.easy,
    );

    return TrainingModuleQuestionRef(
      id: (j['id'] ?? '').toString(),
      moduleId: (j['moduleId'] ?? '').toString(),
      sectionId: (j['sectionId'] ?? '').toString(),
      questionId: (j['questionId'] ?? '').toString(),
      order: (j['order'] ?? 0) as int,
      difficulty: parsedDiff,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'sectionId': sectionId,
      'questionId': questionId,
      'order': order,
      'difficulty': difficulty.name,
    };
  }

  TrainingModuleQuestionRef copyWith({
    String? id,
    String? moduleId,
    String? sectionId,
    String? questionId,
    int? order,
    Difficulty? difficulty,
  }) {
    return TrainingModuleQuestionRef(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      sectionId: sectionId ?? this.sectionId,
      questionId: questionId ?? this.questionId,
      order: order ?? this.order,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
