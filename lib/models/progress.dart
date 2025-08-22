// ===================== File: lib/models/progress.dart =====================
// Purpose: Kullanıcının kısa vadeli ilerlemesini ve puanlarını (XP) tutar.
//          Seviye (level), o seviyedeki mevcut XP, bir sonraki seviyeye
//          kalan XP, günlük/haftalık kazanımlar ve soru istatistikleri.
// Notes:
// - level/XP mantığı customizable: _levelXpCap(level) ile değiştirilebilir.
// - weeklyXpLast7: son 7 gün (soldan sağa: 6 gün önce … bugün)
//   Home’daki mini bar chart için doğrudan kullanılabilir.
// ==========================================================================

class QuestionStats {
  final int total;     // çözülen toplam soru
  final int correct;   // doğru
  final int wrong;     // yanlış

  const QuestionStats({this.total = 0, this.correct = 0, this.wrong = 0});

  double get accuracy => total == 0 ? 0 : correct / total;

  QuestionStats add({int correctDelta = 0, int wrongDelta = 0}) {
    final t = total + correctDelta + wrongDelta;
    return QuestionStats(
      total: t,
      correct: correct + correctDelta,
      wrong: wrong + wrongDelta,
    );
  }

  factory QuestionStats.fromJson(Map<String, dynamic> j) => QuestionStats(
    total: (j['total'] ?? 0) as int,
    correct: (j['correct'] ?? 0) as int,
    wrong: (j['wrong'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'correct': correct,
    'wrong': wrong,
  };

  QuestionStats copyWith({int? total, int? correct, int? wrong}) =>
      QuestionStats(
        total: total ?? this.total,
        correct: correct ?? this.correct,
        wrong: wrong ?? this.wrong,
      );
}

class Progress {
  // Seviye & XP
  final int level;            // mevcut seviye (1,2,3…)
  final int xpInLevel;        // bulunduğu seviyedeki biriken XP
  final int xpCapInLevel;     // bu seviyeyi bitirmek için gereken XP (örn. 200)

  // Toplam kazanımlar
  final int totalXp;          // tüm zamanların toplam XP’si
  final int todayEarnedXp;    // bugün kazanılan XP
  final int weeklyEarnedXp;   // bu hafta kazanılan XP

  // İstatistik
  final QuestionStats questionStats;

  // Grafik için: son 7 gün (soldan sağa: 6 gün önce … bugün)
  final List<int> weeklyXpLast7;

  const Progress({
    required this.level,
    required this.xpInLevel,
    required this.xpCapInLevel,
    required this.totalXp,
    required this.todayEarnedXp,
    required this.weeklyEarnedXp,
    required this.questionStats,
    required this.weeklyXpLast7,
  });

  /// Başlangıç için boş/deft değerler
  factory Progress.initial() => Progress(
    level: 1,
    xpInLevel: 0,
    xpCapInLevel: _levelXpCap(1),
    totalXp: 0,
    todayEarnedXp: 0,
    weeklyEarnedXp: 0,
    questionStats: const QuestionStats(),
    weeklyXpLast7: List<int>.filled(7, 0, growable: false),
  );

  // ---- Hesaplamalar / Getter’lar ----
  double get levelProgress => xpCapInLevel == 0 ? 0 : xpInLevel / xpCapInLevel;
  int get xpToNextLevel => (xpCapInLevel - xpInLevel).clamp(0, xpCapInLevel);

  // ---- İş mantığı ----

  /// XP ekle ve gerekiyorsa level atlat.
  Progress addXp(int delta) {
    if (delta <= 0) return this;

    var newTotal = totalXp + delta;
    var lvl = level;
    var xp = xpInLevel + delta;
    var cap = xpCapInLevel;

    // Seviye atlama döngüsü (birden çok seviye geçebilir)
    while (xp >= cap) {
      xp -= cap;
      lvl += 1;
      cap = _levelXpCap(lvl);
    }

    return copyWith(
      level: lvl,
      xpInLevel: xp,
      xpCapInLevel: cap,
      totalXp: newTotal,
      todayEarnedXp: todayEarnedXp + delta,
      weeklyEarnedXp: weeklyEarnedXp + delta,
      // son 7 gün serisine bugünkü XP’yi ekle (push)
      weeklyXpLast7: _pushTodayXp(weeklyXpLast7, delta),
    );
  }

  /// Soru sonucunu işler: doğru/yanlış ve XP kazanımı birlikte güncellenebilir.
  Progress registerAnswer({required bool correct, int xpGain = 0}) {
    final stats = questionStats.add(
      correctDelta: correct ? 1 : 0,
      wrongDelta: correct ? 0 : 1,
    );
    final afterStats = copyWith(questionStats: stats);
    return xpGain > 0 ? afterStats.addXp(xpGain) : afterStats;
  }

  /// Gün değiştiğinde çağır: today’i sıfırlar ve haftalık diziye kaydırma uygular.
  Progress rolloverToNewDay() {
    // bugünün XP’si zaten dizinin son elemanında; günü kapatıp yeni gün başlatıyoruz
    final shifted = _shiftAndPush(weeklyXpLast7, 0);
    return copyWith(todayEarnedXp: 0, weeklyXpLast7: shifted);
  }

  /// Haftalık reset (pazartesi başı gibi) – istersen cron ile
  Progress resetWeekly() => copyWith(weeklyEarnedXp: 0);

  // ---- JSON ----
  factory Progress.fromJson(Map<String, dynamic> j) => Progress(
    level: (j['level'] ?? 1) as int,
    xpInLevel: (j['xpInLevel'] ?? 0) as int,
    xpCapInLevel: (j['xpCapInLevel'] ?? _levelXpCap(j['level'] ?? 1)) as int,
    totalXp: (j['totalXp'] ?? 0) as int,
    todayEarnedXp: (j['todayEarnedXp'] ?? 0) as int,
    weeklyEarnedXp: (j['weeklyEarnedXp'] ?? 0) as int,
    questionStats: j['questionStats'] == null
        ? const QuestionStats()
        : QuestionStats.fromJson(j['questionStats'] as Map<String, dynamic>),
    weeklyXpLast7: (j['weeklyXpLast7'] as List<dynamic>?)
        ?.map((e) => (e ?? 0) as int)
        .toList(growable: false) ??
        List<int>.filled(7, 0, growable: false),
  );

  Map<String, dynamic> toJson() => {
    'level': level,
    'xpInLevel': xpInLevel,
    'xpCapInLevel': xpCapInLevel,
    'totalXp': totalXp,
    'todayEarnedXp': todayEarnedXp,
    'weeklyEarnedXp': weeklyEarnedXp,
    'questionStats': questionStats.toJson(),
    'weeklyXpLast7': weeklyXpLast7,
  };

  Progress copyWith({
    int? level,
    int? xpInLevel,
    int? xpCapInLevel,
    int? totalXp,
    int? todayEarnedXp,
    int? weeklyEarnedXp,
    QuestionStats? questionStats,
    List<int>? weeklyXpLast7,
  }) =>
      Progress(
        level: level ?? this.level,
        xpInLevel: xpInLevel ?? this.xpInLevel,
        xpCapInLevel: xpCapInLevel ?? this.xpCapInLevel,
        totalXp: totalXp ?? this.totalXp,
        todayEarnedXp: todayEarnedXp ?? this.todayEarnedXp,
        weeklyEarnedXp: weeklyEarnedXp ?? this.weeklyEarnedXp,
        questionStats: questionStats ?? this.questionStats,
        weeklyXpLast7: weeklyXpLast7 ?? this.weeklyXpLast7,
      );

  // ---- helpers ----

  /// Seviye başına gereken XP – burada basitçe artan bir fonksiyon.
  /// İstersen sabit dizi kullanabilirsin.
  static int _levelXpCap(int level) {
    // Örn: L1=200, L2=250, L3=300, … (50 * (level-1) artış)
    return 200 + (level - 1) * 50;
  }

  static List<int> _pushTodayXp(List<int> last7, int delta) {
    final list = List<int>.from(last7);
    list[list.length - 1] = (list.last + delta);
    return List<int>.from(list, growable: false);
  }

  /// Sola kaydır ve yeni değeri ekle (grafik için gün değişiminde kullanılır)
  static List<int> _shiftAndPush(List<int> last7, int newValue) {
    final list = List<int>.from(last7);
    list.removeAt(0);
    list.add(newValue);
    return List<int>.from(list, growable: false);
  }
}
