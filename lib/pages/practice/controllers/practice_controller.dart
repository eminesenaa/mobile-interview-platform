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
  // TRAINING PROGRESS STATE
  // =========================
  
  /// Modül ID'sine göre kullanıcının ilerlemesi (Progress Bar için)
  final RxMap<String, UserTrainingModuleProgress> userProgressMap =
      <String, UserTrainingModuleProgress>{}.obs;

  /// Modül ID -> Çözülen Soru ID'leri Seti (UI'da tik işareti ve Start/Continue hesabı için)
  final RxMap<String, Set<String>> completedQuestionIdsByModule =
      <String, Set<String>>{}.obs;

  /// Library sekmesi için "Başlanmış Modüller" listesi
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
    loadTrainingModulesFromFirestore();
    loadSolvedQuestionsForUser();
    
    // Yeni eklenen progress yükleme işlemi
    _loadUserProgress(); 
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
  // FILTER API (UI UYUMLU)
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
  // FIREBASE LOADERS (CORE)
  // =========================
  Future<void> loadQuestionsFromFirebase() async {
    final snap = await FirebaseFirestore.instance.collection('questions').get();
    final items =
        snap.docs.map((d) => Question.fromFirestore(d.data(), d.id)).toList();
    allQuestions.assignAll(items);

    final topics = <String>{'All', ...items.map((e) => e.topic)};
    allTopics.assignAll(topics.toList()..sort());
  }

  Future<void> loadTrainingModulesFromFirestore() async {
    final db = FirebaseFirestore.instance;

    final moduleSnap =
        await db.collection('modules').orderBy('sortOrder').get();
    final modules = moduleSnap.docs
        .map((d) => TrainingModule.fromFirestore(d.data(), d.id))
        .toList();
    trainingModules.assignAll(modules);

    for (final module in modules) {
      final sectionSnap = await db
          .collection('modules')
          .doc(module.id)
          .collection('sections')
          .orderBy('order')
          .get();

      final sections = sectionSnap.docs
          .map((d) => TrainingSection.fromFirestore(d.data(), d.id))
          .toList();

      sectionsByModule[module.id] = sections;

      final List<TrainingModuleQuestionRef> allRefs = [];

      for (final section in sections) {
        final refSnap = await db
            .collection('modules')
            .doc(module.id)
            .collection('sections')
            .doc(section.id)
            .collection('questions')
            .orderBy('order')
            .get();

        allRefs.addAll(
          refSnap.docs.map(
            (d) => TrainingModuleQuestionRef.fromFirestore(d.data(), d.id),
          ),
        );
      }
      refsByModule[module.id] = allRefs;
    }
  }

  Future<void> loadSolvedQuestionsForUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('solved')
        .get();

    solvedQuestionIds
      ..clear()
      ..addAll(snap.docs.map((d) => d.id));
  }

  // =========================
  // TRAINING PROGRESS LOGIC
  // =========================
  
  /// Kullanıcının modül ilerlemelerini çeker ve state'i doldurur.
  Future<void> _loadUserProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid; 
    if (userId == null) return;

    try {
      // Firebase'den tüm modül ilerlemelerini çekiyoruz
      final progressList = await _progressService.getAllProgressForUser(userId);

      for (var p in progressList) {
        // 1. Modül özetini (Progress Bar için) kaydet
        userProgressMap[p.moduleId] = p;
        
        // 2. 🔥 TİK İŞARETLERİ İÇİN: 
        // Modelin içindeki 'solvedQuestionIds' listesini Set olarak aktar
        if (p.solvedQuestionIds.isNotEmpty) {
          completedQuestionIdsByModule[p.moduleId] = p.solvedQuestionIds.toSet();
        }
      }
      
      update(); // GetX arayüzü yenile
      debugPrint('[Progress] Tik işaretleri ve ilerleme başarıyla yüklendi.');
    } catch (e) {
      debugPrint("Progress yükleme hatası: $e");
    }
  }
  /// Bir soru çözüldüğünde çağrılır (Training Mode)
  Future<void> markModuleQuestionCompleted(String moduleId, String questionId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // 1. Modülü bul (Total question sayısı için)
    final module = trainingModules.firstWhereOrNull((m) => m.id == moduleId);
    if (module == null) return;

    // 2. Servise yaz
    await _progressService.markQuestionSolved(
      userId: userId,
      moduleId: moduleId,
      questionId: questionId,
      totalQuestionsInModule: module.totalQuestions,
    );

    // 3. Local state'i güncelle (Tekrar fetch yapmamak için)
    // Progress Map güncelle
    final currentProgress = userProgressMap[moduleId] ??
        UserTrainingModuleProgress(
            userId: userId,
            moduleId: moduleId,
            completedQuestions: 0,
            totalQuestions: module.totalQuestions,
            // 🔥 DÜZELTME: lastUpdated zorunlu alan olduğu için eklendi.
            lastUpdated: DateTime.now(),
            isCompleted: false, 
        );

    // Eğer bu soru zaten çözülmemişse sayacı artır
    final currentSet = completedQuestionIdsByModule[moduleId] ?? {};
    if (!currentSet.contains(questionId)) {
      currentSet.add(questionId);
      completedQuestionIdsByModule[moduleId] = currentSet;

      final newCompletedCount = currentProgress.completedQuestions + 1;
      
      userProgressMap[moduleId] = currentProgress.copyWith(
          completedQuestions: newCompletedCount,
          // 🔥 DÜZELTME: lastUpdated ve isCompleted güncellendi
          lastUpdated: DateTime.now(),
          isCompleted: newCompletedCount >= module.totalQuestions,
      );
    }

    update();
    debugPrint('[Training Progress] Updated locally: $moduleId -> $questionId');
  }

  /// UI Helper: Bir soru çözüldü mü? (Training Mode)
  bool isQuestionCompleted(String moduleId, String questionId) {
    return completedQuestionIdsByModule[moduleId]?.contains(questionId) ?? false;
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