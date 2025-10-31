import 'package:get/get.dart';
import '../../../models/leaderboard.dart';

class LeaderboardController extends GetxController {
  final RxBool loading = true.obs;
  final RxList<LeaderboardEntry> entries = <LeaderboardEntry>[].obs;
  final RxList<LeaderboardEntry> top3 = <LeaderboardEntry>[].obs;
  final RxnInt myRank = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchFull();
  }

  /// TODO: backend bağla
  Future<void> fetchFull() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    final data = <LeaderboardEntry>[
      LeaderboardEntry(rank: 1,
          name: 'A. Şahin',
          initials: 'AS',
          xp: 980,
          delta: 1),
      LeaderboardEntry(rank: 2,
          name: 'Ö. Deniz',
          initials: 'ÖD',
          xp: 910,
          delta: 0),
      LeaderboardEntry(rank: 3,
          name: 'E. Sena',
          initials: 'ES',
          xp: 905,
          delta: -1),
      LeaderboardEntry(rank: 4,
          name: 'Jennifer',
          initials: 'J',
          xp: 880,
          delta: 3),
      LeaderboardEntry(rank: 5,
          name: 'William',
          initials: 'W',
          xp: 756,
          delta: -1),
      LeaderboardEntry(rank: 6,
          name: 'Rümeysa',
          initials: 'RY',
          xp: 756,
          delta: 3,
          isMe: true),
      LeaderboardEntry(rank: 7,
          name: 'Emery',
          initials: 'E',
          xp: 636,
          delta: -1),
      LeaderboardEntry(rank: 8,
          name: 'Lydia',
          initials: 'L',
          xp: 560,
          delta: -1),
    ];

    entries.assignAll(data);
    top3.assignAll(data.take(3));
    myRank.value = data
        .firstWhereOrNull((e) => e.isMe == true)
        ?.rank;
    loading.value = false;
  }
}
