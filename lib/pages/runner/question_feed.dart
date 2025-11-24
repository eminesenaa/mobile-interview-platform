// lib/pages/runner/controller/question_feed.dart
import 'package:equatable/equatable.dart';

import '../../models/question.dart';
// import your Question model

enum QuestionSourceKind {
  practiceAll,
  practiceFilter,
  libraryAll,
  collection,
  exam,
  trainingModule
}

class QuestionSourceContext extends Equatable {
  final QuestionSourceKind kind;

  /// UI’da gösterilen başlık: "Practice • Java", "Collection: Network" vb.
  final String? label;

  /// Kaynağın kimliği:
  /// - collection → collectionId
  /// - exam       → examId
  /// - trainingModule → moduleId
  final String? refId;

  const QuestionSourceContext({
    required this.kind,
    this.label,
    this.refId,
  });

  @override
  List<Object?> get props => [kind, label, refId];
}

class QuestionFeed extends Equatable {
  /// Tercih 1: sadece ID’ler taşınır, Runner her adımda detay çeker.
  final List<String> questionIds;

  /// Tercih 2: hazır getirilen “lite” Question listesi (performans için).
  /// (Uygun görürsen sadece birini kullanırsın.)
  final List<Question>? questions;

  final int startIndex;
  final QuestionSourceContext source;

  const QuestionFeed({
    required this.questionIds,
    this.questions,
    required this.startIndex,
    required this.source,
  }) : assert(startIndex >= 0);

  int get length => questions?.length ?? questionIds.length;

  @override
  List<Object?> get props => [questionIds, questions, startIndex, source];
}
