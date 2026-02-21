// ===================== File: lib/services/firebase/firebase_duel_matchmaking_service.dart =====================
// Purpose: Gerçek backend (Firebase) üzerinden duel matchmaking implementasyonu.
//          Şu an sadece placeholder.
// ================================================================================================

/*
TODO: Gerçek backend implementasyonu burada yapılacak.

Planlanan yapı:

1. startMatch(DuelConfig config)
   - Firestore "matchQueue" collection'ına kullanıcı eklenir.
   - Backend (Cloud Function / Server) eşleşme yapar.
   - "matches" collection'ında match dokümanı oluşturulur.
   - Frontend bu match dokümanını snapshot ile dinler.
   - State değiştikçe DuelMatch modeline map edilir.

2. cancelMatch()
   - Kullanıcı queue'dan çıkarılır.
   - Eğer match oluşmuşsa backend'e cancel request gönderilir.

3. Real-time sync
   - questions
   - players
   - currentQuestionIndex
   - questionPhase
   - status
   Firestore snapshot üzerinden güncellenir.

Bu dosya FakeDuelMatchmakingService yerine kullanılacaktır.
*/