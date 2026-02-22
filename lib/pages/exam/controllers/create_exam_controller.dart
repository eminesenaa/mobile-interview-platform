import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/question.dart';

class CreateExamController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  // 🔹 Kullanıcının Customize Exam ekranında yaptığı seçimler
  final topics = <String>{}.obs;
  final tags = <String>{}.obs;
  final types = <QuestionType>{}.obs;
  final difficulties = <Difficulty>{}.obs;
  final count = 10.obs;

  // 🔹 UI dropdown'ları doldurmak için mevcut değerler
  final availableTopics = <String>[].obs;
  final availableTags = <String>[].obs;
  final availableTypes = QuestionType.values.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableFilters();
  }

  Future<void> _loadAvailableFilters() async {
    try {
      final col = FirebaseFirestore.instance.collection('questions');
      final snap = await col.limit(1000).get();

      final topicSet = <String>{};
      final tagSet = <String>{};

      for (final doc in snap.docs) {
        final data = doc.data();

        if (data['topic'] != null) {
          topicSet.add(data['topic']);
        }

        // 🔥 FRONT TAG = SUBTOPICS
        final rawSub = data['subtopics'];
        if (rawSub is List) {
          tagSet.addAll(
            rawSub.map((e) => e.toString().trim()).where((e) => e.isNotEmpty),
          );
        } else if (rawSub is String) {
          tagSet.addAll(
            rawSub
                .split(RegExp(r'[;,]'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty),
          );
        }
      }

      availableTopics.assignAll(topicSet.toList()..sort());
      availableTags.assignAll(tagSet.toList()..sort());
    } catch (e) {
      error.value = 'Filter loading failed: $e';
    }

    debugPrint("AVAILABLE TOPICS: $availableTopics");
  }

  /// 🔸 Ana metod — filtrelere göre Firestore’dan soru çeker
  Future<List<Question>> generateExamQuestions() async {
    try {
      isLoading.value = true;
      error.value = '';

      debugPrint(
          '==================== 🔍 EXAM FILTER DEBUG ====================');
      debugPrint('📘 Topics: ${topics.isEmpty ? "None" : topics.join(", ")}');
      debugPrint('🏷️  Tags: ${tags.isEmpty ? "None" : tags.join(", ")}');
      debugPrint(
          '🧩 Types: ${types.isEmpty ? "All" : types.map((e) => e.name).join(", ")}');
      debugPrint(
          '⚙️  Difficulties: ${difficulties.isEmpty ? "All" : difficulties.map((e) => e.name).join(", ")}');
      debugPrint('🎯 Requested Question Count: ${count.value}');
      debugPrint(
          '===============================================================');

      // 🔹 1️⃣ Firestore'dan tüm soruları çek
      final pool = await _fetchAllQuestions(limit: 1000);
      debugPrint('📚 Pulled total questions from Firestore: ${pool.length}');

      // 🔹 Firestore’dan gelen tüm soruları detaylı yaz
      // for (final q in pool) {
      //   debugPrint(
      //     '🔹 [POOL] ${q.id} | Topic: ${q.topic} | Type: ${q.type.name} | '
      //     'Diff: ${q.difficulty.name} | Tags: ${q.tags.join(", ")}',
      //   );
      // }

      // 🔹 2️⃣ Filtreye göre seç (sadece tam eşleşenler)
      final selected = pool.where((q) {
        final topicOk = topics.isEmpty || topics.contains(q.topic);
        final tagOk = tags.isEmpty || q.subtopics.any(tags.contains);
        final typeOk = types.isEmpty || types.contains(q.type);
        final diffOk =
            difficulties.isEmpty || difficulties.contains(q.difficulty);
        return topicOk && tagOk && typeOk && diffOk;
      }).toList()
        ..shuffle(Random());

      // 🔹 3️⃣ İstenen sayıya kadar al (ama eksikse eksik bırak)
      final result = selected.take(count.value).toList();

      debugPrint(
          '===============================================================');
      debugPrint('✅ Selected ${result.length} questions after filtering:');
      for (final q in result) {
        debugPrint(
          '➡️ [SELECTED] ${q.id} | Topic: ${q.topic} | Type: ${q.type.name} | '
          'Diff: ${q.difficulty.name} | Tags: ${q.tags.join(", ")}',
        );
      }
      debugPrint(
          '===============================================================');

      if (result.isEmpty) {
        debugPrint('❌ No questions matched the selected filters!');
      }

      return result;
    } catch (e) {
      error.value = e.toString();
      debugPrint('❌ Error while generating exam questions: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 Firestore'dan tüm soru listesini çek
  Future<List<Question>> _fetchAllQuestions({int limit = 1000}) async {
    final col = FirebaseFirestore.instance.collection('questions');
    final snap = await col.limit(limit).get();
    return snap.docs
        .map((d) => Question.fromFirestore(d.data(), d.id))
        .toList();
  }
}
