// ===================== File: lib/models/user_library.dart =====================
// Purpose: Kullanıcının Library özeti (meta). Büyük listeler burada tutulmaz.
//          - savedCount, collectionsCount, examsCount
//          - lastUsedCollectionId
//          Hem Firestore meta dokümanı için hem de JSON (user.toJson) için
//          dönüştürücüler içerir.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class UserLibrary {
  final int savedCount;
  final int collectionsCount;
  final int examsCount;
  final String? lastUsedCollectionId;

  const UserLibrary({
    required this.savedCount,
    required this.collectionsCount,
    required this.examsCount,
    this.lastUsedCollectionId,
  });

  factory UserLibrary.empty() => const UserLibrary(
    savedCount: 0,
    collectionsCount: 0,
    examsCount: 0,
    lastUsedCollectionId: null,
  );

  // -------- JSON (User.fromJson / User.toJson için) --------
  factory UserLibrary.fromJson(Map<String, dynamic> json) {
    return UserLibrary(
      savedCount: (json['savedCount'] as num?)?.toInt() ?? 0,
      collectionsCount: (json['collectionsCount'] as num?)?.toInt() ?? 0,
      examsCount: (json['examsCount'] as num?)?.toInt() ?? 0,
      lastUsedCollectionId: json['lastUsedCollectionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'savedCount': savedCount,
    'collectionsCount': collectionsCount,
    'examsCount': examsCount,
    if (lastUsedCollectionId != null)
      'lastUsedCollectionId': lastUsedCollectionId,
  };

  // -------- Firestore meta dokümanı (users/{uid}/meta/library) için --------
  factory UserLibrary.fromMetaDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserLibrary(
      savedCount: (data['savedCount'] as num?)?.toInt() ?? 0,
      collectionsCount: (data['collectionsCount'] as num?)?.toInt() ?? 0,
      examsCount: (data['examsCount'] as num?)?.toInt() ?? 0,
      lastUsedCollectionId: data['lastUsedCollectionId'] as String?,
    );
  }

  Map<String, dynamic> toMetaMap() => {
    'savedCount': savedCount,
    'collectionsCount': collectionsCount,
    'examsCount': examsCount,
    if (lastUsedCollectionId != null)
      'lastUsedCollectionId': lastUsedCollectionId,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  UserLibrary copyWith({
    int? savedCount,
    int? collectionsCount,
    int? examsCount,
    String? lastUsedCollectionId,
  }) =>
      UserLibrary(
        savedCount: savedCount ?? this.savedCount,
        collectionsCount: collectionsCount ?? this.collectionsCount,
        examsCount: examsCount ?? this.examsCount,
        lastUsedCollectionId:
        lastUsedCollectionId ?? this.lastUsedCollectionId,
      );
}
