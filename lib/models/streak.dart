import 'package:cloud_firestore/cloud_firestore.dart';

/// Streak Model
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
      } catch (_) {}
    }
    return DateTime(1970, 1, 1);
  }

  static Map<String, bool> _normalizeHistory(dynamic raw) {
    final map = <String, bool>{};
    for (int i = 1; i <= 7; i++) {
      map['$i'] = false;
    }

    if (raw is Map) {
      raw.forEach((k, v) {
        map[k.toString()] = v == true;
      });
    } else if (raw is List) {
      for (int i = 0; i < raw.length && i < 7; i++) {
        map['${i + 1}'] = raw[i] == true;
      }
    }
    return map;
  }

  // 🔥 STREAK DURUMUNU KONTROL ET VE GEREKİRSE SIFIRLA
  static Future<void> checkAndResetStreakIfNeeded(String uid) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc(uid);
    final snap = await ref.get();

    if (!snap.exists) return;

    final data = snap.data() ?? {};
    final current = Streak.fromMap(data['streak'] ?? {});

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      current.lastStreakDate.year,
      current.lastStreakDate.month,
      current.lastStreakDate.day,
    );

    final diff = today.difference(last).inDays;

    // Eğer 2+ gün atlandıysa streak'i sıfırla
    if (diff >= 2 && current.streakCount > 0) {
      print("❄️ Streak sıfırlanıyor: $diff gün atlandı");
      
      final history = <String, bool>{};
      for (int i = 1; i <= 7; i++) {
        history['$i'] = false;
      }

      await ref.update({
        'streak': {
          'streakCount': 0,
          'longestStreak': current.longestStreak,
          'lastStreakDate': current.lastStreakDate.toIso8601String().split('T').first,
          'streakHistory': history,
        }
      });
      
      print("✅ Streak 0'a sıfırlandı");
    }
  }

  // 🔥 SADECE SORU ÇÖZÜLDÜĞÜNDE ÇAĞRILACAK
static Future<void> updateStreak(String uid) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection('users').doc(uid);
  final snap = await ref.get();
  if (!snap.exists) return;

  final data = snap.data()!;
  final streakData = data['streak'] ?? {};
  final current = Streak.fromMap(streakData);

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final lastDate = DateTime(
    current.lastStreakDate.year,
    current.lastStreakDate.month,
    current.lastStreakDate.day,
  );

  final diff = todayDate.difference(lastDate).inDays;

  int newCount = current.streakCount;
  int newLongest = current.longestStreak;

  if (diff == 0) {
    // bugün zaten sayılmış → dokunma
    return;
  } else if (diff == 1) {
    newCount += 1;
  } else {
    // gün kaçırıldı
    newCount = 1;
  }

  if (newCount > newLongest) {
    newLongest = newCount;
  }

  // ---- HISTORY: SON 7 GÜNÜ DOLDUR ----
  final Map<String, bool> history = {
    '1': false,
    '2': false,
    '3': false,
    '4': false,
    '5': false,
    '6': false,
    '7': false,
  };

  final daysToFill = newCount.clamp(1, 7);

  for (int i = 0; i < daysToFill; i++) {
    final d = todayDate.subtract(Duration(days: i));
    history[d.weekday.toString()] = true;
  }

  await ref.update({
    'streak': {
      'streakCount': newCount,
      'longestStreak': newLongest,
      'lastStreakDate': todayDate.toIso8601String().split('T').first,
      'streakHistory': history,
    }
  });



    print("✅ Streak güncellendi: count=$newCount longest=$newLongest");
  }

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