// ===================== File: lib/models/training_module.dart =====================
// Purpose: Uygulamadaki eğitim planı / eğitim yolu (training module) modelidir.
//          Örnek: "Warm-up Quick Win", "30 Days JS Challenge", "SQL Crash Course".
// Notes:
// - Sadece "statik" modül bilgisini tutar (başlık, görsel, toplam soru vb).
// - Kullanıcıya özel ilerleme bilgisi (kaç soru çözdü, yüzde kaç tamamlandı)
//   ayrı bir modelde (UserTrainingModuleProgress) tutulur.
// ==============================================================================

/// Modülün genel formatını / türünü belirtir.
/// Örnek kullanım:
/// - crashCourse   → Kısa sürede temel kavramları bitir.
/// - challenge     → Günlük/haftalık görev içeren uzun soluklu challenge.
/// - interviewPrep → Belli bir role/stack için mülakat odaklı plan.
enum TrainingModuleFormat {
  crashCourse,
  challenge,
  interviewPrep,
}

class TrainingModule {
  /// Firestore document id.
  final String id;

  /// Kartta büyük görünen başlık.
  /// Örn: "Warm-up • Quick Win", "Python Crash Course"
  final String title;

  /// Başlığın altındaki kısa açıklama / tagline.
  /// Örn: "Solve 5 warm-up questions in 10 minutes"
  final String subtitle;

  /// Daha uzun açıklama (detay sayfasında gösterilebilir).
  final String? description;

  /// Modül formatı (crashCourse, challenge, interviewPrep).
  final TrainingModuleFormat format;

  /// Kart arka plan görseli veya thumbnail.
  /// Firestore'da genelde public storage URL olarak tutulur.
  final String? coverImageUrl;

  /// Modülde tanımlı toplam soru adedi.
  /// (section + question referanslarından da hesaplanabilir ama
  ///  listeleme ekranlarında hızlı göstermek için burada da durabilir.)
  final int totalQuestions;

  /// Bu modülü tamamlamak için tahmini süre (dakika).
  /// Örn: 30, 45, 90 gibi. Opsiyonel.
  final int? estimatedMinutes;

  /// Home / Practice gibi yerlerde öne çıkartılacak modüller için flag.
  final bool isFeatured;

  /// Aynı kategorideki modüller arasında sıralama vermek için opsiyonel alan.
  /// Küçük değerler önce gelir (1, 2, 3 gibi).
  final int? sortOrder;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.format,
    required this.totalQuestions,
    this.description,
    this.coverImageUrl,
    this.estimatedMinutes,
    this.isFeatured = false,
    this.sortOrder,
  });

  // ---------------------------------------------------------------------------
  // JSON / Firestore dönüşümleri
  // ---------------------------------------------------------------------------

  /// Firestore dokümanından (Map + docId) TrainingModule üretir.
  ///
  /// Beklenen alanlar:
  /// - title            : String
  /// - subtitle         : String
  /// - description      : String? (opsiyonel)
  /// - format           : String? (enum name, örn: "crashCourse")
  /// - coverImageUrl    : String? (opsiyonel)
  /// - totalQuestions   : int
  /// - estimatedMinutes : int? (opsiyonel)
  /// - isFeatured       : bool? (varsayılan false)
  /// - sortOrder        : int? (opsiyonel)
  factory TrainingModule.fromFirestore(
      Map<String, dynamic> data,
      String documentId,
      ) {
    final formatRaw = (data['format'] ?? 'crashCourse').toString();
    final parsedFormat = TrainingModuleFormat.values.firstWhere(
          (f) => f.name == formatRaw,
      orElse: () => TrainingModuleFormat.crashCourse,
    );

    return TrainingModule(
      id: documentId,
      title: (data['title'] ?? '').toString(),
      subtitle: (data['subtitle'] ?? '').toString(),
      description: (data['description'] ?? '').toString().trim().isEmpty
          ? null
          : (data['description'] ?? '').toString(),
      format: parsedFormat,
      coverImageUrl: (data['coverImageUrl'] ?? '').toString().trim().isEmpty
          ? null
          : (data['coverImageUrl'] ?? '').toString(),
      totalQuestions: (data['totalQuestions'] ?? 0) as int,
      estimatedMinutes: data['estimatedMinutes'] == null
          ? null
          : (data['estimatedMinutes'] as num).toInt(),
      isFeatured: (data['isFeatured'] ?? false) as bool,
      sortOrder: data['sortOrder'] == null
          ? null
          : (data['sortOrder'] as num).toInt(),
    );
  }

  /// Genel JSON dönüşümü (örneğin local mock, cache, nested field vb.).
  /// Eğer `id` alanı JSON içinde ayrı tutuluyorsa buradan da alınabilir.
  factory TrainingModule.fromJson(Map<String, dynamic> j) {
    final formatRaw = (j['format'] ?? 'crashCourse').toString();
    final parsedFormat = TrainingModuleFormat.values.firstWhere(
          (f) => f.name == formatRaw,
      orElse: () => TrainingModuleFormat.crashCourse,
    );

    return TrainingModule(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      subtitle: (j['subtitle'] ?? '').toString(),
      description: (j['description'] ?? '').toString().trim().isEmpty
          ? null
          : (j['description'] ?? '').toString(),
      format: parsedFormat,
      coverImageUrl: (j['coverImageUrl'] ?? '').toString().trim().isEmpty
          ? null
          : (j['coverImageUrl'] ?? '').toString(),
      totalQuestions: (j['totalQuestions'] ?? 0) as int,
      estimatedMinutes: j['estimatedMinutes'] == null
          ? null
          : (j['estimatedMinutes'] as num).toInt(),
      isFeatured: (j['isFeatured'] ?? false) as bool,
      sortOrder:
      j['sortOrder'] == null ? null : (j['sortOrder'] as num).toInt(),
    );
  }

  /// Firestore’a yazarken kullanılacak map.
  ///
  /// Not: `id` alanı burada yok, document id olarak tutulacak.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      if (description != null) 'description': description,
      'format': format.name,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      'totalQuestions': totalQuestions,
      if (estimatedMinutes != null) 'estimatedMinutes': estimatedMinutes,
      'isFeatured': isFeatured,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
  }

  TrainingModule copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    TrainingModuleFormat? format,
    String? coverImageUrl,
    int? totalQuestions,
    int? estimatedMinutes,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return TrainingModule(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      format: format ?? this.format,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
