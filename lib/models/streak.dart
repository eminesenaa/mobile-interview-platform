// ===================== File: lib/models/streak.dart =====================
// Purpose: Kullanıcının çalışma serisini (streak) yönetir. Güncel seri,
//          en uzun seri, en son seri artıran tarih ve son 30 günlük seri
//          geçmişini (true/false) taşır.
// Notes:
// - lastStreakDate artık DateTime tipinde tutulur.
// - Firestore uyumu: hem Timestamp hem "YYYY-MM-DD" String okunur.
// - toJson() içinde istersen Timestamp ya da ISO String döndürebilirsin.
// ========================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Streak {
  final int streakCount;          // şu anki seri (gün)
  final int longestStreak;        // ulaşılan en yüksek seri
  final DateTime lastStreakDate;  // en son streak tarihi (local)
  final String? timezone;         // opsiyonel (örn. Europe/Istanbul)
  final List<bool> streakHistory; // son 30 gün: bugün dahil sağdan sola

  const Streak({
    required this.streakCount,
    required this.longestStreak,
    required this.lastStreakDate,
    this.timezone,
    required this.streakHistory,
  });

  /// Varsayılan boş değerler (0 seri, tüm history false)
  factory Streak.empty({String? timezone}) => Streak(
    streakCount: 0,
    longestStreak: 0,
    lastStreakDate: DateTime.fromMillisecondsSinceEpoch(0),
    timezone: timezone,
    streakHistory: List<bool>.filled(30, false, growable: false),
  );

  /// Bugün check-in olduğunda çağır: streakCount & history günceller.
  Streak updateForCheckIn(DateTime todayLocal) {
    final isSameDay = _isSameDay(lastStreakDate, todayLocal);
    final isYesterday =
    _isSameDay(lastStreakDate.add(const Duration(days: 1)), todayLocal);

    int nextStreak = streakCount;
    if (isSameDay) {
      // bugün zaten sayılmış → streakCount değişmez
      nextStreak = streakCount;
    } else if (isYesterday) {
      nextStreak = streakCount + 1;
    } else {
      // kopmuş → 1’den başla
      nextStreak = 1;
    }

    final nextLongest = nextStreak > longestStreak ? nextStreak : longestStreak;
    final nextHistory = _shiftAndPush(streakHistory, !isSameDay);

    return copyWith(
      streakCount: nextStreak,
      longestStreak: nextLongest,
      lastStreakDate: todayLocal,
      streakHistory: nextHistory,
    );
  }

  /// Gün döndüğünde history’i hizalamak için yardımcı
  Streak alignHistoryToToday(DateTime todayLocal) {
    if (_isSameDay(lastStreakDate, todayLocal) ||
        lastStreakDate.isAfter(todayLocal)) return this;
    // Bugün hiç check-in yapılmadıysa sadece boş bir gün ekle
    final shifted = _shiftAndPush(streakHistory, false);
    return copyWith(streakHistory: shifted);
  }

  // history: sola kaydırıp yeni değeri ekler
  static List<bool> _shiftAndPush(List<bool> history, bool value) {
    var list = List<bool>.from(history);
    list.removeAt(0);
    list.add(value);
    return List<bool>.from(list, growable: false);
  }

  // ---- JSON ----
  factory Streak.fromJson(Map<String, dynamic> json) {
    final raw = json['lastStreakDate'];
    DateTime parsed;
    if (raw is String) {
      parsed = DateTime.parse(raw); // ISO format
    } else if (raw is Timestamp) {
      parsed = raw.toDate();        // Firestore Timestamp
    } else {
      parsed = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Streak(
      streakCount: (json['streakCount'] ?? 0) as int,
      longestStreak: (json['longestStreak'] ?? 0) as int,
      lastStreakDate: parsed,
      timezone: json['timezone'] as String?,
      streakHistory: (json['streakHistory'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList(growable: false) ??
          List<bool>.filled(30, false, growable: false),
    );
  }

  Map<String, dynamic> toJson({bool asTimestamp = false}) => {
    'streakCount': streakCount,
    'longestStreak': longestStreak,
    'lastStreakDate': asTimestamp
        ? Timestamp.fromDate(lastStreakDate) // Firestore Timestamp
        : lastStreakDate.toIso8601String().split('T').first, // "YYYY-MM-DD"
    'timezone': timezone,
    'streakHistory': streakHistory,
  };

  Streak copyWith({
    int? streakCount,
    int? longestStreak,
    DateTime? lastStreakDate,
    String? timezone,
    List<bool>? streakHistory,
  }) =>
      Streak(
        streakCount: streakCount ?? this.streakCount,
        longestStreak: longestStreak ?? this.longestStreak,
        lastStreakDate: lastStreakDate ?? this.lastStreakDate,
        timezone: timezone ?? this.timezone,
        streakHistory: streakHistory ?? this.streakHistory,
      );

  // ---- helpers ----
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
