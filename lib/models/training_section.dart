// ===================== File: lib/models/training_section.dart =====================
// Purpose: Her training module içindeki bölüm / grup bilgisini tutar.
//          Örnek: "Warm-up", "Day 1", "Arrays Basics", "Medium Drills".
// Notes:
// - Sadece bölüm başlığını ve tipini taşır; soru listesi ayrı modelde
//   (TrainingModuleQuestionRef) tutulur.
// ==============================================================================

/// Section’ın nasıl organize edildiğini belirtir.
/// - topicBased : Konu bazlı (Loops, Arrays, DP, ...).
/// - dayBased   : Gün bazlı (Day 1, Day 2, ...).
/// - levelBased : Zorluk bazlı (Warm-up, Easy, Medium, Hard).
enum TrainingSectionType {
  topicBased,
  dayBased,
  levelBased,
}

class TrainingSection {
  /// Firestore document id (module içindeki subCollection id'si).
  final String id;

  /// Bu section'ın bağlı olduğu module id.
  final String moduleId;

  /// Kullanıcıya görünen başlık.
  /// Örn: "Warm-up", "Day 1", "Arrays Basics"
  final String title;

  /// Detay sayfasında, section altında gösterilebilecek açıklama metni.
  final String? description;

  /// Modül içindeki sıralama (1, 2, 3 ...).
  final int order;

  /// Section tipi (topic/day/level).
  final TrainingSectionType type;

  const TrainingSection({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    required this.type,
    this.description,
  });

  // ---------------------------------------------------------------------------
  // JSON / Firestore dönüşümleri
  // ---------------------------------------------------------------------------

  /// Firestore subCollection dokümanından TrainingSection üretir.
  ///
  /// Beklenen alanlar:
  /// - moduleId    : String
  /// - title       : String
  /// - description : String? (opsiyonel)
  /// - order       : int
  /// - type        : String? (enum name, örn: "dayBased")
  factory TrainingSection.fromFirestore(
      Map<String, dynamic> data,
      String documentId,
      ) {
    final typeRaw = (data['type'] ?? 'topicBased').toString();
    final parsedType = TrainingSectionType.values.firstWhere(
          (t) => t.name == typeRaw,
      orElse: () => TrainingSectionType.topicBased,
    );

    return TrainingSection(
      id: documentId,
      moduleId: (data['moduleId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString().trim().isEmpty
          ? null
          : (data['description'] ?? '').toString(),
      order: (data['order'] ?? 0) as int,
      type: parsedType,
    );
  }

  factory TrainingSection.fromJson(Map<String, dynamic> j) {
    final typeRaw = (j['type'] ?? 'topicBased').toString();
    final parsedType = TrainingSectionType.values.firstWhere(
          (t) => t.name == typeRaw,
      orElse: () => TrainingSectionType.topicBased,
    );

    return TrainingSection(
      id: (j['id'] ?? '').toString(),
      moduleId: (j['moduleId'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      description: (j['description'] ?? '').toString().trim().isEmpty
          ? null
          : (j['description'] ?? '').toString(),
      order: (j['order'] ?? 0) as int,
      type: parsedType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'title': title,
      if (description != null) 'description': description,
      'order': order,
      'type': type.name,
    };
  }

  TrainingSection copyWith({
    String? id,
    String? moduleId,
    String? title,
    String? description,
    int? order,
    TrainingSectionType? type,
  }) {
    return TrainingSection(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      type: type ?? this.type,
    );
  }
}
