// ===================== File: lib/services/firebase/duel_service.dart =====================
// Purpose: Duel işlemleri sonrası kullanıcı XP güncellemesi.
//          Firestore üzerinde totalXp alanını artırır.
// ==========================================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/duel_result.dart';

class DuelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Duel sonucu sonrası XP'leri ilgili kullanıcılara uygular.
  /// totalXp Firestore'da atomik olarak artırılır.
  Future<void> applyXpToUsers(DuelResult result) async {
    final batch = _firestore.batch();

    result.xpGainedMap.forEach((userId, xpGained) {
      if (xpGained <= 0) return;

      final userRef = _firestore.collection('users').doc(userId);

      // totalXp alanını atomik olarak artır
      batch.update(userRef, {
        'totalXp': FieldValue.increment(xpGained),
      });
    });

    await batch.commit();
  }
}
