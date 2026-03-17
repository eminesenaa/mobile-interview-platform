import 'dart:async';
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

  /// Multi modda lobby countdown kalan süresi (saniye)
  final lobbyCountdownSeconds = 0.obs;
  Timer? _lobbyCountdownTimer;

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

          // Multi modda lobbyCountdown durumu → yerel countdown başlat
          if (event.status == DuelStatus.lobbyCountdown &&
              event.lobbyCountdownEndAt != null) {
            _startLocalCountdown(event.lobbyCountdownEndAt!);
          } else if (event.status != DuelStatus.lobbyCountdown) {
            _lobbyCountdownTimer?.cancel();
          }

          if (event.status == DuelStatus.inProgress) {
            _lobbyCountdownTimer?.cancel();
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

  /// lobbyCountdownEndAt'e kadar geriye sayım yapar
  void _startLocalCountdown(DateTime endAt) {
    _lobbyCountdownTimer?.cancel();
    _updateCountdown(endAt);
    _lobbyCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown(endAt));
  }

  void _updateCountdown(DateTime endAt) {
    final remaining = endAt.difference(DateTime.now()).inSeconds;
    lobbyCountdownSeconds.value = remaining > 0 ? remaining : 0;
  }

  @override
  void onClose() {
    print('🧹 [MC] MatchmakingController onClose');
    _lobbyCountdownTimer?.cancel();
    _service.dispose();
    super.onClose();
  }

  void cancel() {
    print('🚫 [MC] cancel called');
    _lobbyCountdownTimer?.cancel();
    _service.cancelMatch();
    Get.back();
  }
}
