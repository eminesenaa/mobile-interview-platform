import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/collection.dart';
import '../../models/question.dart';
import '../../widgets/question_card.dart';

class CollectionDetailPage extends StatelessWidget {
  final String collectionId;
  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('collections')
        .doc(collectionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Collection not found'));
          }

          final collection = Collection.fromDoc(snap.data!);
          final ids = collection.questionIds;

          if (ids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${collection.name}\n\nNo items yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }

          return FutureBuilder<List<Question>>(
            future: _fetchQuestionsByIds(ids),
            builder: (context, qsnap) {
              if (qsnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final questions = qsnap.data ?? const <Question>[];

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final q = questions[i];
                  return QuestionCard(
                    question: q,
                    onTap: () {
                      // soru sayfasına git
                      // Get.to(() => McqQuestionPage(question: q));
                    },
                    onSaveTap: () {
                      // mevcut save sheet’i question.id ile aç
                      // openSaveSheet(q);
                    },
                    isSaved: true, // koleksiyon içindeyiz
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Firestore whereIn 10 sınırı: id’leri 10’arlı gruplar halinde çek.
Future<List<Question>> _fetchQuestionsByIds(List<String> ids) async {
  const chunk = 10;
  final db = FirebaseFirestore.instance;
  final List<Question> result = [];

  for (var i = 0; i < ids.length; i += chunk) {
    final batch = ids.sublist(i, (i + chunk > ids.length) ? ids.length : i + chunk);
    final q = await db
        .collection('questions')
        .where(FieldPath.documentId, whereIn: batch)
        .get();
    // geçici olarak hata vermemesi için kapatıldı backend yapılırken açılıp düzenlenir.
    // result.addAll(q.docs.map((d) => Question.fromDoc(d)));
  }

  // istersen collection’daki sırayı korumak için id sırasına göre tekrar sırala
  final index = {for (var i = 0; i < ids.length; i++) ids[i]: i};
  result.sort((a, b) => (index[a.id] ?? 0).compareTo(index[b.id] ?? 0));

  return result;
}
