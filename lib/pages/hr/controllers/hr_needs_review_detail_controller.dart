// ===================== File: hr_needs_review_detail_controller.dart =====================
// Purpose:
// Controls Needs Review Interview Detail page using real Firestore results.
// ================================================================================

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../interviews/needs_review/hr_candidate_list_page.dart';
import '../interviews/needs_review/hr_candidate_result_page.dart';

class HrNeedsReviewDetailController extends GetxController {
  final _db = FirebaseFirestore.instance;
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
  final sortedCandidates = <Map<String, dynamic>>[].obs;
  final topCandidates = <Map<String, dynamic>>[].obs;
  final filteredCandidates = <Map<String, dynamic>>[].obs;

  // ===============================
  // FILTER STATE
  // ===============================
  final topN = 5.obs;
  final minScore = Rxn<int>();
  final topicThresholds = <String, double>{}.obs;

  final topicColors = <Color>[
    AppColors.cinnabar,
    AppColors.accentRoyalPlum,
    AppColors.stormyTeal,
    AppColors.accentCeladon,
    AppColors.accentSpicyOrange,
    AppColors.honeyBronze,
  ];

  @override
  void onInit() {
    super.onInit();
    
    title.value = interview["title"] ?? "Interview Result";
    interviewId.value = interview["id"] ?? "";
    
    if (interview["startTime"] != null) {
      final dt = (interview["startTime"] as Timestamp).toDate();
      date.value = DateFormat('MMM dd, yyyy').format(dt);
    }

    _listenToResults();
  }

  // ===============================
  // REAL-TIME RESULTS
  // ===============================
  void _listenToResults() {
    if (interviewId.isEmpty) return;

    _db.collection('ai_interview_results')
        .where('interviewId', isEqualTo: interviewId.value)
        .snapshots()
        .listen((snap) {
          candidates.value = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            
            // Extract topics from STAR analysis or scores
            final topics = <String, int>{};
            if (data['starAnalysis'] != null) {
              final star = data['starAnalysis'] as Map<String, dynamic>;
              star.forEach((key, value) {
                topics[key] = (value as num).toInt();
              });
            }

            return {
              "name": data['candidateName'] ?? "Candidate",
              "initials": _getInitials(data['candidateName'] ?? "C"),
              "score": (data['totalScore'] ?? 0).toInt(),
              "interviewTitle": title.value,
              "interviewDate": date.value,
              "decision": data['decision'],
              "topics": topics,
              "resultId": doc.id,
              ...data,
            };
          }).toList();

          candidatesCompletedText.value = "${candidates.length} completed";
          
          // Update topic keys for filters based on actual data
          final allTopics = <String>{};
          for (var c in candidates) {
            final t = c["topics"] as Map<String, int>?;
            if (t != null) allTopics.addAll(t.keys);
          }
          
          for (var t in allTopics) {
            if (!topicThresholds.containsKey(t)) {
              topicThresholds[t] = 0.0;
            }
          }

          processCandidates();
          applyFilters();
        });
  }

  String _getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void processCandidates() {
    final sorted = List<Map<String, dynamic>>.from(candidates);
    sorted.sort((a, b) => (b["score"] as int).compareTo(a["score"] as int));

    for (int i = 0; i < sorted.length; i++) {
      sorted[i]["rank"] = i + 1;
    }

    sortedCandidates.value = sorted;
    topCandidates.value = sorted.take(5).toList();
  }

  Color getTopicColor(int index) {
    return topicColors[index % topicColors.length];
  }

  void applyFilters() {
    var result = List<Map<String, dynamic>>.from(sortedCandidates);

    result = result.take(topN.value).toList();

    if (minScore.value != null) {
      result = result.where((c) => (c["score"] as int) >= minScore.value!).toList();
    }

    // Topic thresholds
    result = result.where((c) {
      final topics = c["topics"] as Map<String, int>?;
      if (topics == null) return true;

      for (var entry in topicThresholds.entries) {
        if (entry.value > 0) {
          final candidateTopicScore = topics[entry.key] ?? 0;
          if (candidateTopicScore < entry.value) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    filteredCandidates.value = result;
  }

  List<ActiveFilter> get activeFilters {
    final List<ActiveFilter> filters = [];

    if (topN.value != 5) {
      filters.add(ActiveFilter(
        label: "Top ${topN.value}",
        onRemove: () { topN.value = 5; applyFilters(); },
      ));
    }

    if (minScore.value != null) {
      filters.add(ActiveFilter(
        label: "Score ≥ ${minScore.value}",
        onRemove: () { minScore.value = null; applyFilters(); },
      ));
    }

    for (var entry in topicThresholds.entries) {
      if (entry.value > 0) {
        filters.add(ActiveFilter(
          label: "${entry.key} ≥ ${entry.value.toInt()}%",
          onRemove: () { topicThresholds[entry.key] = 0; applyFilters(); },
        ));
      }
    }

    return filters;
  }

  void updateTopN(int value) { topN.value = value; applyFilters(); }
  void updateMinScore(int? value) { minScore.value = value; applyFilters(); }
  void updateTopicThreshold(String topic, double value) { topicThresholds[topic] = value; applyFilters(); }
  void clearFilters() {
    topN.value = 5;
    minScore.value = null;
    topicThresholds.updateAll((key, value) => 0);
    applyFilters();
  }

  int get totalCandidateCount => candidates.length;

  void openCandidateDetail(Map<String, dynamic> candidate) {
    Get.to(
      () => const HrCandidateResultPage(),
      arguments: {
        ...candidate,
        "interview": interview,
      },
    );
  }

  void openAllCandidates() {
    Get.to(() => const HrCandidateListPage());
  }
}

class ActiveFilter {
  final String label;
  final VoidCallback onRemove;
  ActiveFilter({required this.label, required this.onRemove});
}
