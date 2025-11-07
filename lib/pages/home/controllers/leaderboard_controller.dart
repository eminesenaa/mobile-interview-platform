import 'package:get/get.dart';
import '../../../models/leaderboard.dart';
import '../services/leaderboard_service.dart';

class LeaderboardController extends GetxController {
  final RxBool loading = true.obs;
  final RxList<LeaderboardEntry> entries = <LeaderboardEntry>[].obs;
  final RxList<LeaderboardEntry> top3 = <LeaderboardEntry>[].obs;
  final RxnInt myRank = RxnInt();

  final LeaderboardService _leaderboardService = LeaderboardService();

  @override
  void onInit() {
    super.onInit();
    fetchFull();
  }

  /// 🔹 Servis üzerinden tam tabloyu çek
  Future<void> fetchFull() async {
    loading.value = true;
    try {
      final data = await _leaderboardService.fetchLeaderboardData();

      // Servisten gelen veriler
      final fullList = data['entries'] as List<LeaderboardEntry>;
      final top = data['top3'] as List<TopUser>;
      final me = data['me'] as MeRank?;

      // UI güncelle
      entries.assignAll(fullList);
      top3.assignAll(fullList.take(3)); // top 3 entry
      myRank.value = me?.rank;

      print("🏁 Leaderboard loaded — ${entries.length} entries, me: ${me?.name}, Δ${me?.delta}");
    } catch (e) {
      print("🔥 Leaderboard fetch error: $e");
    } finally {
      loading.value = false;
    }
  }
}
