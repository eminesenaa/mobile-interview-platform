// ===================== File: lib/services/duel/firebase_duel_matchmaking_service.dart =====================
// Purpose: Duel matchmaking ve match lifecycle için abstract servis.
//          Backend implementasyonu daha sonra bu contract'a göre yazılacaktır.
// ================================================================================================

import '../../models/duel_config.dart';
import '../../models/duel_match.dart';

/// Matchmaking servisinin uyması gereken kontrat.
/// Backend hangi teknoloji ile yazılırsa yazılsın
/// bu interface'i implement etmelidir.
abstract class DuelMatchmakingService {
  /// Yeni bir düello başlatır.
  /// - Searching durumuna geçer.
  /// - Rakip bulunduğunda stream üzerinden DuelMatch döner.
  Stream<DuelMatch> startMatch(DuelConfig config);

  /// Aktif eşleşmeyi iptal eder.
  Future<void> cancelMatch();

  /// Aktif match'i sonlandırır (disconnect durumları için)
  Future<void> dispose();
}