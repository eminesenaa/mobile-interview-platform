import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/leaderboard.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchLeaderboardData() async {
    final uid = _auth.currentUser?.uid;

    // 🔹 TÜM kullanıcılar (limit YOK)
    final snapshot = await _db
        .collection('users')
        .orderBy('totalXp', descending: true)
        .get();

    final List<LeaderboardEntry> fullList = [];
    final List<TopUser> top3 = [];
    MeRank? currentUser;

    for (int i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      final data = doc.data();

      final int newRank = i + 1;

      // 🔹 SADECE OKUMA — previousRank yoksa delta = 0
      final int? previousRank = data['previousRank'] as int?;
      final int delta =
          previousRank == null ? 0 : (previousRank - newRank);

      final fullName = [
        (data['name'] ?? '').toString().trim(),
        (data['surname'] ?? '').toString().trim(),
      ].where((e) => e.isNotEmpty).join(' ');

      final initials = fullName.isNotEmpty
          ? fullName
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
          : '??';

      final bool isMe = doc.id == uid;

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
          TopUser(
            rank: newRank,
            initials: initials,
            xp: entry.xp,
          ),
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

    return {
      'entries': fullList,
      'top3': top3,
      'me': currentUser,
    };
  }
}
