// ===================== File: hr_needs_review_detail_controller.dart =====================
// Purpose:
// Controls Needs Review Interview Detail page
//
// IMPORTANT:
// - Uses mock data for now
// - Backend-ready structure
//
// TODO (Backend):
// - Fetch interview result by ID
// - Fetch candidate scores
// - Sort & filter from backend
// - Navigate to candidate result page
// ================================================================================

import 'dart:ui';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../hr_candidate_list_page.dart';

class HrNeedsReviewDetailController extends GetxController {
  final Map<String, dynamic> interview;

  HrNeedsReviewDetailController({required this.interview});

  // ===============================
  // BASE INFO
  // ===============================
  final title = "".obs;
  final interviewId = "".obs;

  final date = "".obs;
  final candidatesCompletedText = "".obs;

  // ===============================
  // CANDIDATES DATA
  // ===============================
  final candidates = <Map<String, dynamic>>[].obs;

  // ===============================
  // DERIVED DATA (UI için)
  // ===============================

  /// Sorted (high → low)
  final sortedCandidates = <Map<String, dynamic>>[].obs;

  /// Top 5 preview
  final topCandidates = <Map<String, dynamic>>[].obs;

  // ===============================
  // FILTER STATE
  // ===============================

  /// Top N (default: 5)
  final topN = 5.obs;

  /// Minimum score (null = Any)
  final minScore = Rxn<int>();

  /// Topic thresholds (örn: SQL ≥ 80)
  final topicThresholds = <String, double>{
    "SQL": 0,
    "ML": 0,
    "C": 0,
  }.obs;

  // ===============================
  // TOPIC COLOR PALETTE 🎨
  // ===============================

  /// Topic slider renkleri (sen burayı istediğin gibi değiştir)
  final topicColors = <Color>[
    AppColors.cinnabar,
    AppColors.accentRoyalPlum,
    AppColors.stormyTeal,
    AppColors.accentCeladon,
    AppColors.accentSpicyOrange,
    AppColors.honeyBronze,
  ];

  /// Filtered sonuç listesi (UI bunu kullanır)
  final filteredCandidates = <Map<String, dynamic>>[].obs;

  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();

    loadMockData();
    processCandidates();
    applyFilters(); // ilk load’da çalıştır

    // ===============================
    // TODO (Backend)
    // ===============================
    /*
    fetchInterviewResults();
    */
  }

  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    title.value = interview["title"] ?? "Frontend Developer Interview";
    interviewId.value = interview["id"] ?? "INT-2025-FE-0044";

    date.value = "Apr 14, 2025";
    candidatesCompletedText.value = "8 completed";

    candidates.value = [
      {
        "name": "James Chen",
        "initials": "JC",
        "score": 96,
        "topics": {
          "SQL": 90,
          "ML": 80,
          "C": 85,
        }
      },
      {
        "name": "Mia Kim",
        "initials": "MK",
        "score": 91,
        "topics": {
          "SQL": 85,
          "ML": 55,
          "C": 72,
        }
      },
      {
        "name": "Ava Lopez",
        "initials": "AL",
        "score": 87,
        "topics": {
          "SQL": 60,
          "ML": 90,
          "C": 65,
        }
      },
      {
        "name": "Noah Park",
        "initials": "NP",
        "score": 79,
        "topics": {
          "SQL": 40,
          "ML": 60,
          "C": 70,
        }
      },
      {
        "name": "Tom Rivera",
        "initials": "TR",
        "score": 74,
        "topics": {
          "SQL": 75,
          "ML": 30,
          "C": 80,
        }
      },
      {
        "name": "Emma Stone",
        "initials": "ES",
        "score": 70,
        "topics": {
          "SQL": 50,
          "ML": 45,
          "C": 60,
        }
      },
      {
        "name": "Chris Lee",
        "initials": "CL",
        "score": 65,
        "topics": {
          "SQL": 30,
          "ML": 20,
          "C": 50,
        }
      },
      {
        "name": "Liam Brown",
        "initials": "LB",
        "score": 60,
        "topics": {
          "SQL": 20,
          "ML": 35,
          "C": 40,
        }
      },
    ];
  }

  // ===============================
  // DATA PROCESSING
  // ===============================

  /// Sorting + Top5 çıkarma
  void processCandidates() {
    final sorted = List<Map<String, dynamic>>.from(candidates);

    sorted.sort((a, b) => b["score"].compareTo(a["score"]));

    sortedCandidates.value = sorted;

    /// Top 5 preview
    topCandidates.value = sorted.take(5).toList();
  }

  /// ===============================
  /// GET TOPIC COLOR BY INDEX 🔥
  /// ---------------------------------------------------------------
  /// index'e göre renk döner
  /// fazla topic varsa başa sarar (mod)
  /// ===============================
  Color getTopicColor(int index) {
    return topicColors[index % topicColors.length];
  }

  /// ===============================
  /// APPLY FILTERS (CORE LOGIC 🔥)
  /// ===============================
  void applyFilters() {
    var result = List<Map<String, dynamic>>.from(sortedCandidates);

    /// -------- TOP N --------
    result = result.take(topN.value).toList();

    /// -------- MIN SCORE --------
    if (minScore.value != null) {
      result = result.where((c) => c["score"] >= minScore.value!).toList();
    }

    /// -------- TOPIC THRESHOLDS --------
    /// ⚠️ Şu an mock data'da topic yok → backend gelince aktif olur
    /*
    /// -------- TOPIC THRESHOLDS --------
    result = result.where((c) {
      final topics = c["topics"] as Map<String, int>;

      for (var entry in topicThresholds.entries) {
        if (topics[entry.key]! < entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
    */

    filteredCandidates.value = result;
  }

  // ===============================
  // UI HELPERS
  // ===============================

  /// ===============================
  /// ACTIVE FILTER CHIPS (UI için)
  /// ===============================
  List<ActiveFilter> get activeFilters {
    final List<ActiveFilter> filters = [];

    /// Top N
    if (topN.value != 5) {
      filters.add(
        ActiveFilter(
          label: "Top ${topN.value}",
          onRemove: () {
            topN.value = 5;
            applyFilters();
          },
        ),
      );
    }

    /// Min Score
    if (minScore.value != null) {
      filters.add(
        ActiveFilter(
          label: "Score ≥ ${minScore.value}",
          onRemove: () {
            minScore.value = null;
            applyFilters();
          },
        ),
      );
    }

    /// Topics
    for (var entry in topicThresholds.entries) {
      if (entry.value > 0) {
        filters.add(
          ActiveFilter(
            label: "${entry.key} ≥ ${entry.value.toInt()}%",
            onRemove: () {
              topicThresholds[entry.key] = 0;
              applyFilters();
            },
          ),
        );
      }
    }

    return filters;
  }

  int get totalCandidateCount => candidates.length;

  // ===============================
  // ACTIONS
  // ===============================

  // ===============================
  // FILTER ACTIONS
  // ===============================

  void updateTopN(int value) {
    topN.value = value;
    applyFilters();
  }

  void updateMinScore(int? value) {
    minScore.value = value;
    applyFilters();
  }

  void updateTopicThreshold(String topic, double value) {
    topicThresholds[topic] = value;
    applyFilters();
  }

  void clearFilters() {
    topN.value = 5;
    minScore.value = null;

    topicThresholds.updateAll((key, value) => 0);

    applyFilters();
  }

  void openCandidateDetail(Map<String, dynamic> candidate) {
    // TODO (Navigation)
    /*
    Get.toNamed('/candidate-result', arguments: candidate);
    */
  }

  void openAllCandidates() {
    Get.to(
      () => const HrCandidateListPage(),
    );
  }

// ===============================
// TODO BACKEND METHODS
// ===============================
/*
  Future<void> fetchInterviewResults() async {}

  Future<void> fetchCandidateScores() async {}

  Future<void> applyFilters() async {}
  */
}

/// ===============================================================
/// ACTIVE FILTER MODEL (UI için)
/// ===============================================================
class ActiveFilter {
  final String label;
  final VoidCallback onRemove;

  ActiveFilter({
    required this.label,
    required this.onRemove,
  });
}
