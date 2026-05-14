// ===================== File: lib/pages/practice/controllers/practice_controller.dart =====================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modeller
import '../../../models/question.dart';
import '../../../models/training_module.dart';
import '../../../models/training_section.dart';
import '../../../models/training_module_question_ref.dart';
import '../../../models/user_training_progress.dart';

// Servisler
import '../../practice/services/training_progress_service.dart';

class PracticeController extends GetxController {
  // =========================
  // SERVICES
  // =========================
  final TrainingProgressService _progressService = TrainingProgressService();

  // =========================
  // QUESTION POOL
  // =========================
  final RxList<Question> allQuestions = <Question>[].obs;

  // =========================
  // TRAINING STRUCTURE
  // =========================
  final RxList<TrainingModule> trainingModules = <TrainingModule>[].obs;
  final RxMap<String, List<TrainingSection>> sectionsByModule =
      <String, List<TrainingSection>>{}.obs;
  final RxMap<String, List<TrainingModuleQuestionRef>> refsByModule =
      <String, List<TrainingModuleQuestionRef>>{}.obs;

  // =========================
  // 🔥 LOADING STATE (YENİ)
  // =========================
  /// Training modülleri yükleniyorsa true — PageView yerine spinner göster
  final RxBool isModulesLoading = true.obs;

  // =========================
  // TRAINING PROGRESS STATE
  // =========================
  final RxMap<String, UserTrainingModuleProgress> userProgressMap =
      <String, UserTrainingModuleProgress>{}.obs;

  final RxMap<String, Set<String>> completedQuestionIdsByModule =
      <String, Set<String>>{}.obs;

  List<TrainingModule> get startedModules {
    return trainingModules
        .where((m) => userProgressMap.containsKey(m.id))
        .toList();
  }

  // =========================
  // PRACTICE FILTER STATE
  // =========================
  final RxString searchQuery = ''.obs;
  final RxString selectedTopic = 'All'.obs;
  final Rxn<Difficulty> selectedDifficulty = Rxn<Difficulty>();
  final Rxn<Status> selectedStatus = Rxn<Status>();
  final Rxn<QuestionType> selectedQuestionType = Rxn<QuestionType>();

  final RxList<String> selectedTopicsMulti = <String>[].obs;
  final RxList<Difficulty> selectedDifficultiesMulti = <Difficulty>[].obs;
  final RxList<QuestionType> selectedQuestionTypesMulti = <QuestionType>[].obs;

  final RxList<String> allTopics = <String>['All'].obs;

  // =========================
  // SHUFFLE
  // =========================
  final RxBool shuffleEnabled = true.obs;
  final RxInt shuffleSeed = DateTime.now().millisecondsSinceEpoch.obs;

  // =========================
  // USER STATE (GLOBAL PRACTICE)
  // =========================
  final RxSet<String> solvedQuestionIds = <String>{}.obs;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    loadQuestionsFromFirebase();
    loadSolvedQuestionsForUser();
    _initTrainingData(); // 🔥 Sıralı yükleme: önce modüller, sonra progress
  }

  // =========================
  // 🔥 YENİ: Sıralı başlatma
  // =========================
  Future<void> _initTrainingData() async {
    await loadTrainingModulesFromFirestore();
    await _loadUserProgress();
  }

  // =========================
  // FILTERED QUESTIONS LOGIC
  // =========================
  List<Question> get filteredQuestions {
    var list = allQuestions.toList();

    if (selectedTopicsMulti.isNotEmpty) {
      list = list.where((q) => selectedTopicsMulti.contains(q.topic)).toList();
    } else if (selectedTopic.value != 'All') {
      list = list.where((q) => q.topic == selectedTopic.value).toList();
    }

    if (selectedDifficultiesMulti.isNotEmpty) {
      list = list
          .where((q) => selectedDifficultiesMulti.contains(q.difficulty))
          .toList();
    } else if (selectedDifficulty.value != null) {
      list =
          list.where((q) => q.difficulty == selectedDifficulty.value).toList();
    }

    if (selectedStatus.value != null) {
      list = list.where((q) {
        final id = _questionIdFromQuestion(q);
        return selectedStatus.value == Status.solved
            ? solvedQuestionIds.contains(id)
            : !solvedQuestionIds.contains(id);
      }).toList();
    }

    if (selectedQuestionTypesMulti.isNotEmpty) {
      list = list
          .where((q) => selectedQuestionTypesMulti.contains(q.type))
          .toList();
    } else if (selectedQuestionType.value != null) {
      list = list.where((q) => q.type == selectedQuestionType.value).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((q) {
        final haystack =
            '${q.title} ${q.description ?? ''} ${q.topic} ${q.tags.join(" ")}'
                .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    if (shuffleEnabled.value) {
      list.shuffle(Random(shuffleSeed.value));
    }

    return list;
  }

  // =========================
  // FILTER API
  // =========================
  void updateSearch(String query) => searchQuery.value = query;

  Future<void> updateFilters({
    String? topic,
    Difficulty? difficulty,
    Status? status,
    QuestionType? questionType,
  }) async {
    if (topic != null) selectedTopic.value = topic;
    selectedDifficulty.value = difficulty;
    selectedStatus.value = status;
    selectedQuestionType.value = questionType;

    selectedTopicsMulti.clear();
    selectedDifficultiesMulti.clear();
    selectedQuestionTypesMulti.clear();
  }

  Future<void> updateFiltersMulti({
    List<String>? topics,
    List<Difficulty>? difficulties,
    List<QuestionType>? questionTypes,
    Status? status,
  }) async {
    selectedTopicsMulti
      ..clear()
      ..addAll(topics ?? []);
    selectedDifficultiesMulti
      ..clear()
      ..addAll(difficulties ?? []);
    selectedQuestionTypesMulti
      ..clear()
      ..addAll(questionTypes ?? []);

    selectedStatus.value = status;
  }

  Question? getRandomQuestion() {
    final list = filteredQuestions;
    if (list.isEmpty) return null;
    return list.first;
  }

  // =========================
  // FIREBASE LOADERS
  // =========================
  Future<void> loadQuestionsFromFirebase() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('questions').get();
      final items =
          snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();
      allQuestions.assignAll(items);

      final uniqueTopics = items.map((e) => e.topic).toSet().toList()..sort();

      // 🔥 ALL sabit en başta
      allTopics.assignAll(['All', ...uniqueTopics]);
    } catch (e) {
      debugPrint('[Questions] Yükleme hatası: $e');
    }
  }

  Future<void> loadTrainingModulesFromFirestore() async {
    isModulesLoading.value = true; // 🔥 Yükleme başladı

    try {
      final db = FirebaseFirestore.instance;

      // 🔥 DÜZELTME: orderBy hatasını önlemek için try/catch + fallback
      QuerySnapshot<Map<String, dynamic>> moduleSnap;
      try {
        moduleSnap = await db.collection('modules').orderBy('sortOrder').get();
      } catch (e) {
        debugPrint(
            '[Modules] orderBy(sortOrder) başarısız, sırasız çekiliyor: $e');
        moduleSnap = await db.collection('modules').get();
      }

      final modules = moduleSnap.docs
          .map((d) => TrainingModule.fromFirestore(d.data(), d.id))
          .toList();

      // 🔥 RELEVANCE SORTING (Sort by job title match)
      final args = Get.arguments as Map<String, dynamic>?;
      final targetJob = args?["targetJob"]?.toString().toLowerCase();

      if (targetJob != null && targetJob.isNotEmpty) {
        modules.sort((a, b) {
          final aTitle = a.title.toLowerCase();
          final bTitle = b.title.toLowerCase();
          
          bool aMatch = aTitle.contains(targetJob) || targetJob.contains(aTitle);
          bool bMatch = bTitle.contains(targetJob) || targetJob.contains(bTitle);

          if (aMatch && !bMatch) return -1;
          if (!aMatch && bMatch) return 1;
          return 0;
        });
      }

      trainingModules.assignAll(modules);

      // 🔥 PARALEL YÜKLEME: Her modülü aynı anda çek (sequential yerine)
      await Future.wait(modules.map((module) async {
        try {
          QuerySnapshot<Map<String, dynamic>> sectionSnap;
          try {
            sectionSnap = await db
                .collection('modules')
                .doc(module.id)
                .collection('sections')
                .orderBy('order')
                .get();
          } catch (e) {
            debugPrint('[Sections] orderBy(order) başarısız, sırasız: $e');
            sectionSnap = await db
                .collection('modules')
                .doc(module.id)
                .collection('sections')
                .get();
          }

          final sections = sectionSnap.docs
              .map((d) => TrainingSection.fromFirestore(d.data(), d.id))
              .toList();

          sectionsByModule[module.id] = sections;

          // Tüm section'ların refs'lerini paralel çek
          final List<TrainingModuleQuestionRef> allRefs = [];

          await Future.wait(sections.map((section) async {
            try {
              QuerySnapshot<Map<String, dynamic>> refSnap;
              try {
                refSnap = await db
                    .collection('modules')
                    .doc(module.id)
                    .collection('sections')
                    .doc(section.id)
                    .collection('questions')
                    .orderBy('order')
                    .get();
              } catch (e) {
                debugPrint('[Refs] orderBy(order) başarısız, sırasız: $e');
                refSnap = await db
                    .collection('modules')
                    .doc(module.id)
                    .collection('sections')
                    .doc(section.id)
                    .collection('questions')
                    .get();
              }

              allRefs.addAll(
                refSnap.docs.map(
                  (d) =>
                      TrainingModuleQuestionRef.fromFirestore(d.data(), d.id),
                ),
              );
            } catch (e) {
              debugPrint(
                  '[Refs] Section ${section.id} refs yükleme hatası: $e');
            }
          }));

          refsByModule[module.id] = allRefs;
        } catch (e) {
          debugPrint(
              '[Modules] Modül ${module.id} sections yükleme hatası: $e');
        }
      }));

      debugPrint('[Modules] ✅ ${modules.length} modül yüklendi.');
    } catch (e) {
      debugPrint('[Modules] ❌ Kritik hata: $e');
    } finally {
      isModulesLoading.value = false; // 🔥 Yükleme bitti (hata olsa da)
    }
  }

  Future<void> loadSolvedQuestionsForUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('solved')
          .get();

      solvedQuestionIds
        ..clear()
        ..addAll(snap.docs.map((d) => d.id));
    } catch (e) {
      debugPrint('[Solved] Yükleme hatası: $e');
    }
  }

  // =========================
  // TRAINING PROGRESS LOGIC
  // =========================
  Future<void> _loadUserProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final progressList = await _progressService.getAllProgressForUser(userId);

      for (var p in progressList) {
        userProgressMap[p.moduleId] = p;
        if (p.solvedQuestionIds.isNotEmpty) {
          completedQuestionIdsByModule[p.moduleId] =
              p.solvedQuestionIds.toSet();
        }
      }

      update();
      debugPrint('[Progress] ✅ İlerleme yüklendi.');
    } catch (e) {
      debugPrint('[Progress] ❌ Yükleme hatası: $e');
    }
  }

  Future<void> markModuleQuestionCompleted(
      String moduleId, String questionId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final module = trainingModules.firstWhereOrNull((m) => m.id == moduleId);
    if (module == null) return;

    await _progressService.markQuestionSolved(
      userId: userId,
      moduleId: moduleId,
      questionId: questionId,
      totalQuestionsInModule: module.totalQuestions,
    );

    final currentProgress = userProgressMap[moduleId] ??
        UserTrainingModuleProgress(
          userId: userId,
          moduleId: moduleId,
          completedQuestions: 0,
          totalQuestions: module.totalQuestions,
          lastUpdated: DateTime.now(),
          isCompleted: false,
        );

    final currentSet =
        Set<String>.from(completedQuestionIdsByModule[moduleId] ?? {});
    if (!currentSet.contains(questionId)) {
      currentSet.add(questionId);
      completedQuestionIdsByModule[moduleId] = currentSet;

      final newCompletedCount = currentProgress.completedQuestions + 1;

      userProgressMap[moduleId] = currentProgress.copyWith(
        completedQuestions: newCompletedCount,
        lastUpdated: DateTime.now(),
        isCompleted: newCompletedCount >= module.totalQuestions,
      );
    }

    update();
    debugPrint('[Training Progress] Updated: $moduleId -> $questionId');
  }

  bool isQuestionCompleted(String moduleId, String questionId) {
    return completedQuestionIdsByModule[moduleId]?.contains(questionId) ??
        false;
  }
}

// =========================
// HELPER
// =========================
String _questionIdFromQuestion(Question q) {
  try {
    final dynamic v = (q as dynamic).id;
    if (v != null) return v.toString();
  } catch (_) {}
  try {
    final dynamic v = (q as dynamic).docId;
    if (v != null) return v.toString();
  } catch (_) {}
  return q.title.toString();
}
