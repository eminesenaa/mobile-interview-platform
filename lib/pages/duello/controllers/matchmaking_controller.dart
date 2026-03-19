import 'dart:async';
import 'package:get/get.dart';
import '../../../models/duel_config.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_match.dart';
import '../../../services/firebase/firebase_duel_matchmaking_service.dart';
import '../duel_game_page.dart';
import '../duel_type_page.dart';

/// ===============================================================
/// MatchmakingController
/// ---------------------------------------------------------------
/// Responsible for:
/// - Starting matchmaking process
/// - Listening realtime match updates (Firestore stream)
/// - Managing lobby countdown (multi mode)
/// - Handling timeout if no match is found (120s)
/// - Navigating to game page when match starts
///
/// Notes:
/// - Backend stream is the source of truth
/// - Timeout is only a fallback mechanism
/// ===============================================================
class MatchmakingController extends GetxController {
  final DuelConfig config;

  MatchmakingController(this.config);

  final _service = FirebaseDuelMatchmakingService();

  /// Current match data (reactive)
  final match = Rxn<DuelMatch>();

  /// Current matchmaking status
  final status = DuelStatus.searching.obs;

  /// ===============================
  /// LOBBY COUNTDOWN (multi mode)
  /// ===============================
  final lobbyCountdownSeconds = 0.obs;
  Timer? _lobbyCountdownTimer;

  /// ===============================
  /// MATCHMAKING TIMEOUT (120s)
  /// If no match is found within this duration,
  /// user will be redirected back.
  /// ===============================
  Timer? _matchTimeoutTimer;

  @override
  void onInit() {
    super.onInit();
    print('🎮 [MC] MatchmakingController onInit');
    print(
        '🎮 [MC] Config: type=${config.duelType.name}, cat=${config.category}');

    _startMatch();
  }

  /// ===============================================================
  /// Starts matchmaking process
  /// ===============================================================
  Future<void> _startMatch() async {
    print('🎮 [MC] _startMatch called');

    try {
      /// 1. Cleanup any existing "zombie" matches
      await _service.cancelMatch();
      print('🧹 [MC] Cleanup finished, starting fresh matchmaking...');

      /// 2. Start timeout countdown (120 seconds)
      _startMatchTimeout();

      /// 3. Start listening matchmaking stream
      _service.startMatch(config).listen(
        (event) {
          print('📡 [MC] Stream event: status=${event.status.name}');

          match.value = event;
          status.value = event.status;

          /// ===============================
          /// Cancel timeout if process moves forward
          /// ===============================
          if (event.status != DuelStatus.searching) {
            _matchTimeoutTimer?.cancel();
          }

          /// ===============================
          /// Handle lobby countdown (multi mode)
          /// ===============================
          if (event.status == DuelStatus.lobbyCountdown &&
              event.lobbyCountdownEndAt != null) {
            _startLocalCountdown(event.lobbyCountdownEndAt!);
          } else if (event.status != DuelStatus.lobbyCountdown) {
            _lobbyCountdownTimer?.cancel();
          }

          /// ===============================
          /// Navigate to game when match starts
          /// ===============================
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

  /// ===============================================================
  /// MATCH TIMEOUT HANDLER (120 seconds)
  /// If still searching → cancel matchmaking & redirect
  /// ===============================================================
  void _startMatchTimeout() {
    _matchTimeoutTimer?.cancel();

    _matchTimeoutTimer = Timer(const Duration(seconds: 120), () {
      /// Only trigger if still searching
      if (status.value == DuelStatus.searching) {
        print('⏱️ [MC] Matchmaking timeout reached');

        _service.cancelMatch();

        Get.snackbar(
          'Eşleşme Bulunamadı',
          'Bu düello için şu anda bir kullanıcı bulunamadı.',
          snackPosition: SnackPosition.BOTTOM,
        );

        /// Navigate back to duel selection page
        /// (Adjust route if needed)
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAll(() => const DuelTypePage());
        });
      }
    });
  }

  /// ===============================================================
  /// Starts local countdown based on backend timestamp
  /// ===============================================================
  void _startLocalCountdown(DateTime endAt) {
    _lobbyCountdownTimer?.cancel();

    _updateCountdown(endAt);

    _lobbyCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(endAt),
    );
  }

  /// Updates countdown value every second
  void _updateCountdown(DateTime endAt) {
    final remaining = endAt.difference(DateTime.now()).inSeconds;
    lobbyCountdownSeconds.value = remaining > 0 ? remaining : 0;
  }

  @override
  void onClose() {
    print('🧹 [MC] MatchmakingController onClose');

    /// Cancel all timers
    _lobbyCountdownTimer?.cancel();
    _matchTimeoutTimer?.cancel();

    /// Dispose backend service
    _service.dispose();

    super.onClose();
  }

  /// ===============================================================
  /// Manual cancel (user action)
  /// ===============================================================
  void cancel() {
    print('🚫 [MC] cancel called');

    _lobbyCountdownTimer?.cancel();
    _matchTimeoutTimer?.cancel();

    _service.cancelMatch();

    Get.back();
  }
}
