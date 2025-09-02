import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionPreview {
  final String title;
  final String difficulty; // string olarak tutuyoruz (easy / medium ...)
  final String topic;

  const QuestionPreview({
    required this.title,
    required this.difficulty,
    required this.topic,
  });

  factory QuestionPreview.fromMap(Map<String, dynamic>? map) {
    final m = map ?? const {};
    return QuestionPreview(
      title: (m['title'] as String?) ?? '',
      difficulty: (m['difficulty'] as String?) ?? '',
      topic: (m['topic'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'difficulty': difficulty,
    'topic': topic,
  };
}

class SavedItem {
  final String id;          // saved doc id
  final String questionId;
  final DateTime? savedAt;
  final QuestionPreview? preview;

  const SavedItem({
    required this.id,
    required this.questionId,
    this.savedAt,
    this.preview,
  });

  factory SavedItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return SavedItem(
      id: doc.id,
      questionId: (data['questionId'] as String?) ?? '',
      savedAt: (data['savedAt'] as Timestamp?)?.toDate(),
      preview: QuestionPreview.fromMap(data['preview'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    if (savedAt != null) 'savedAt': Timestamp.fromDate(savedAt!),
    if (preview != null) 'preview': preview!.toMap(),
  };
}
