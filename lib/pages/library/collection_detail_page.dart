// ===================== File: lib/pages/library/collection_detail_page.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/question.dart';
import '../runner/question_feed.dart';
import '../runner/question_runner_page.dart';
import 'library_page.dart';
import 'services/library_service.dart';
import '../../widgets/question_card.dart';
import 'widgets/save_to_collection_sheet.dart';

class CollectionDetailPage extends StatelessWidget {
  final String collectionId;
  final String? collectionName;
  final OpenRunner openRunner;
  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    this.collectionName,
    required this.openRunner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
      ),
      body: StreamBuilder<List<Question>>(
        stream: LibraryService.instance.questionsInCollectionStream(collectionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final questions = snapshot.data!;
          if (questions.isEmpty) {
            return const Center(child: Text('No questions in this collection.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final q = questions[i];
              final qId = q.id; // Firestore doc id

              return StreamBuilder<bool>(
                stream: LibraryService.instance.isSavedStream(qId),
                builder: (context, snap) {
                  final isSaved = snap.data ?? false;

                  return QuestionCard(
                    question: q,
                    isSaved: isSaved,
                    onTap: () =>  _openRunnerFromCollection(
                      questions,
                      i,
                      collectionId: collectionId,
                      collectionName: collectionName,
                    ),
                    onSaveTap: () async {
                      if (isSaved) {
                        // 🔹 Kaydedilmişse → seçenek sun
                        await showModalBottomSheet(
                          context: context,
                          builder: (_) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  title: const Text("Remove from My Library"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await LibraryService.instance
                                        .removeQuestionEverywhere(qId);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.folder_outlined,
                                    color: Colors.blue,
                                  ),
                                  title: const Text("Move to Collection"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) =>
                                          SaveToCollectionSheet(questionId: qId),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // 🔹 Kaydedilmemişse → direkt koleksiyon seçtir
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) =>
                              SaveToCollectionSheet(questionId: qId),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openRunnerFromCollection(
      List<Question> questions,
      int startIndex, {
        required String collectionId,
        String? collectionName,
      }) {
    final feed = QuestionFeed(
      questionIds: questions.map((q) => q.id).toList(),
      questions: questions,               // ekranda gördüğün sırayı korur
      startIndex: startIndex,             // tıklanan index
      source: QuestionSourceContext(
        kind: QuestionSourceKind.collection,
        label: collectionName != null
            ? 'Collection: $collectionName'
            : 'Collection',
        refId: collectionId,
      ),
    );

    Get.to(() => QuestionRunnerPage(feed: feed));
  }
}
