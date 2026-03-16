// lib/models/duel_enums.dart

/// Düello türleri
enum DuelType {
  oneVsOne,     // 1v1
  multi,        // Çoklu oyuncu
  privateRoom,  // Özel oda
}

/// Düellonun genel durumu (match lifecycle)
enum DuelStatus {
  idle,             // Henüz başlamadı
  searching,        // Rakip aranıyor
  matched,          // Rakip bulundu
  countdown,        // 3-2-1 geri sayım
  lobbyCountdown,   // Multi: 3+ oyuncu, 18s bekleme
  waiting,          // Private room: waiting for players
  inProgress,       // Oyun devam ediyor
  revealing,        // Cevaplar gösteriliyor
  finished,         // Oyun bitti
  cancelled,        // İptal edildi
}

/// Soru içindeki anlık faz
enum DuelQuestionPhase {
  active,        // Oyuncular cevap verebilir
  waiting,       // Oyuncu cevap verdi, diğerlerini bekliyor
  reveal,        // Doğru cevap ve seçimler gösteriliyor
}