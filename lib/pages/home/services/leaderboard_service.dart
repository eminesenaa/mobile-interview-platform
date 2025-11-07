import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/leaderboard.dart';

class LeaderboardService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchLeaderboardData() async {
    final uid = _auth.currentUser?.uid;
    final usersRef = _db.collection('users');
    
    // 🔹 Sadece en iyi 10 kullanıcıyı çek
    final snapshot = await usersRef
        .orderBy('totalXp', descending: true)
        .limit(10)
        .get();

    final List<LeaderboardEntry> fullList = [];
    final List<TopUser> top3 = [];
    MeRank? currentUser;
    final Map<String, int> newRanks = {};

    // 🟣 1️⃣ Tüm kullanıcıların yeni sıralamasını hesapla
    for (int i = 0; i < snapshot.docs.length; i++) {
      newRanks[snapshot.docs[i].id] = i + 1;
    }

    // 🟣 2️⃣ Delta hesapla
    for (int i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      final data = doc.data();
      final newRank = newRanks[doc.id]!;
      final prevRank = data['previousRank'] ?? newRank;
      int delta = (prevRank != newRank) ? (prevRank - newRank) : 0;

      final fullName = [
        (data['name'] ?? '').toString().trim(),
        (data['surname'] ?? '').toString().trim()
      ].where((e) => e.isNotEmpty).join(' ').trim();

      final initials = fullName.isNotEmpty
          ? fullName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
          : '??';

      final isMe = (data['id'] ?? data['uid']) == uid;

      final entry = LeaderboardEntry(
        rank: newRank,
        name: fullName.isEmpty ? 'Unknown' : fullName,
        initials: initials,
        xp: (data['totalXp'] ?? 0) as int,
        delta: delta,
        isMe: isMe,
      );

      fullList.add(entry);
      if (i < 3) {
        top3.add(
          TopUser(rank: newRank, initials: initials, xp: entry.xp),
        );
      }

      if (isMe) {
        currentUser = MeRank(
          rank: newRank,
          name: entry.name,
          xp: entry.xp,
          delta: delta,
        );
      }
    }

    // 🟣 3️⃣ Firestore senkronizasyonu (yalnızca ilk 10 için)
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      final newRank = newRanks[doc.id]!;
      final data = doc.data();
      final prevRank = data['currentRank'];
      final oldPrev = data['previousRank'];

      if (prevRank != newRank) {
        batch.update(doc.reference, {
          'previousRank': prevRank ?? newRank,
          'currentRank': newRank,
        });
      } else if (oldPrev == null) {
        batch.update(doc.reference, {
          'previousRank': newRank,
          'currentRank': newRank,
        });
      }
    }
    await batch.commit();

    return {
      'entries': fullList,
      'top3': top3,
      'me': currentUser,
    };
  }
}
