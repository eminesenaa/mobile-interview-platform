import 'package:get/get.dart';
import '../../../models/duel_config.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_match.dart';
import '../../../services/firebase/firebase_duel_matchmaking_service.dart';
import '../duel_game_page.dart';

class MatchmakingController extends GetxController {
  final DuelConfig config;

  MatchmakingController(this.config);

  final _service = FirebaseDuelMatchmakingService();

  final match = Rxn<DuelMatch>();
  final status = DuelStatus.searching.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎮 [MC] MatchmakingController onInit');
    print(
        '🎮 [MC] Config: type=${config.duelType.name}, cat=${config.category}');
    _startMatch();
  }

  Future<void> _startMatch() async {
    print('🎮 [MC] _startMatch called');

    try {
      // 1. Önce veritabanındaki eski "zombi" kayıtları temizle
      await _service.cancelMatch();
      print('🧹 [MC] Cleanup finished, starting fresh matchmaking...');

      // 2. Temiz sayfadan eşleşmeyi başlat
      _service.startMatch(config).listen(
        (event) {
          print('📡 [MC] Stream event: status=${event.status.name}');

          match.value = event;
          status.value = event.status;

          if (event.status == DuelStatus.inProgress) {
            print('🚀 [MC] Navigating to DuelGamePage');
            Get.off(
              () => const DuelGamePage(),
              arguments: event,
            );
          }
        },
        onError: (error) {
          print('❌ [MC] Stream error: $error');
          status.value = DuelStatus.cancelled;
          Get.snackbar(
            'Bağlantı Hatası',
            'Eşleşme sırasında bir hata oluştu.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      print('❌ [MC] Critical error during startMatch: $e');
    }
  }

  @override
  void onClose() {
    print('🧹 [MC] MatchmakingController onClose');
    _service.dispose();
    super.onClose();
  }

  void cancel() {
    print('🚫 [MC] cancel called');
    _service.cancelMatch();
    Get.back();
  }
}
