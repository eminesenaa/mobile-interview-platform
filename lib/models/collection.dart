import 'package:cloud_firestore/cloud_firestore.dart';

class Collection {
  final String id;
  final String name;
  final List<String> questionIds;
  final DateTime? updatedAt;

  int get itemCount => questionIds.length;

  const Collection({
    required this.id,
    required this.name,
    required this.questionIds,
    this.updatedAt,
  });

  factory Collection.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Collection(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Untitled',
      questionIds: List<String>.from((data['questionIds'] as List?) ?? const []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory Collection.fromMap(String id, Map<String, dynamic> data) {
    return Collection(
      id: id,
      name: (data['name'] as String?) ?? 'Untitled',
      questionIds: List<String>.from((data['questionIds'] as List?) ?? const []),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'questionIds': questionIds,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    List<String>? questionIds,
    DateTime? updatedAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      questionIds: questionIds ?? this.questionIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
