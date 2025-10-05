import 'package:cloud_firestore/cloud_firestore.dart';

/// Streak Model
/// Firestore'daki users/{uid} dokümanındaki alanları temsil eder.
class Streak {
  final DateTime lastStreakDate;
  final int streakCount;
  final int longestStreak;
  final Map<String, bool> streakHistory;

  Streak({
    required this.lastStreakDate,
    required this.streakCount,
    required this.longestStreak,
    required this.streakHistory,
  });

  factory Streak.fromMap(Map<String, dynamic> data) {
    return Streak(
      lastStreakDate: _parseDate(data['lastStreakDate']),
      streakCount: data['streakCount'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      streakHistory: _normalizeHistory(data['streakHistory']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastStreakDate': lastStreakDate.toIso8601String().split('T').first,
      'streakCount': streakCount,
      'longestStreak': longestStreak,
      'streakHistory': streakHistory,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(1970, 1, 1);
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime(1970, 1, 1);
      }
    }
    return DateTime(1970, 1, 1);
  }

  /// 🔧 Array (List<bool>) veya Map<String,bool> fark etmeksizin normalize eder
  static Map<String, bool> _normalizeHistory(dynamic raw) {
    final map = <String, bool>{};
    if (raw == null) {
      for (int i = 1; i <= 7; i++) {
        map['$i'] = false;
      }
      return map;
    }

    if (raw is Map) {
      raw.forEach((k, v) {
        map[k.toString()] = v == true;
      });
      return map;
    }

    if (raw is List) {
      for (int i = 0; i < raw.length; i++) {
        map['${i + 1}'] = raw[i] == true;
      }
      return map;
    }

    return {'1': false, '2': false, '3': false, '4': false, '5': false, '6': false, '7': false};
  }

  // 🔥 STREAK UPDATE HELPER
  static Future<void> updateStreak(String uid) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      print("⚠️ updateStreak: user doc bulunamadı ($uid)");
      return;
    }

    final data = snap.data() ?? {};
    final streakData = data['streak'] ?? {};
    final current = Streak.fromMap(streakData);

    final today = DateTime.now();
    final todayKey = today.weekday.toString();

    final history = Map<String, bool>.from(current.streakHistory);
    final diff = today
        .difference(DateTime(
          current.lastStreakDate.year,
          current.lastStreakDate.month,
          current.lastStreakDate.day,
        ))
        .inDays;

    int newCount = current.streakCount;
    int newLongest = current.longestStreak;

    print("🧩 updateStreak(): diff=$diff | oldCount=$newCount");

    if (diff == 0) {
      print("🕓 Aynı gün zaten çözülmüş, streak artmıyor.");
      return;
    } else if (diff == 1) {
      newCount += 1;
      print("🔥 1 gün arayla çözüm → streak +1 → $newCount");
    } else {
      newCount = 1;
      history.updateAll((k, v) => false);
      print("❄️ Gün kaçırıldı, streak sıfırlandı (yeniden başlatıldı)");
    }

    history[todayKey] = true;
    if (newCount > newLongest) newLongest = newCount;

    // 🔧 Güncelleme map formatında kaydedilir
    await ref.update({
      'streak': {
        'streakCount': newCount,
        'longestStreak': newLongest,
        'lastStreakDate': today.toIso8601String().split('T').first,
        'streakHistory': history,
      }
    });

    print("✅ Firestore streak güncellendi: count=$newCount longest=$newLongest");
  }

  /// 🔹 Boş başlangıç verisi
  factory Streak.empty() {
    return Streak(
      lastStreakDate: DateTime(1970, 1, 1),
      streakCount: 0,
      longestStreak: 0,
      streakHistory: {
        '1': false,
        '2': false,
        '3': false,
        '4': false,
        '5': false,
        '6': false,
        '7': false,
      },
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
