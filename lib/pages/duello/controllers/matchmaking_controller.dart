import 'package:get/get.dart';
import '../../../models/duel_config.dart';
import '../../../models/duel_enums.dart';
import '../../../models/duel_match.dart';
import '../../../services/duel/fake_duel_matchmaking_service.dart';
import '../duel_game_page.dart';

class MatchmakingController extends GetxController {
  final DuelConfig config;

  MatchmakingController(this.config);

  final _service = FakeDuelMatchmakingService();

  final match = Rxn<DuelMatch>();
  final status = DuelStatus.searching.obs;

  @override
  void onInit() {
    super.onInit();
    _startMatch();
  }

  void _startMatch() {
    _service.startMatch(config).listen((event) {
      match.value = event;
      status.value = event.status;

      if (event.status == DuelStatus.inProgress) {
        Get.off(
          () => const DuelGamePage(),
          arguments: event,
        );
      }
    });
  }

  @override
  void onClose() {
    _service.dispose();
    super.onClose();
  }

  void cancel() {
    _service.cancelMatch();
    Get.back();
  }
}
