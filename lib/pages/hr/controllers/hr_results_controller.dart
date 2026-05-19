import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../interviews/reviewed/hr_insights_page.dart';
import 'hr_reviewed_detail_controller.dart';
import 'hr_interviews_controller.dart';

class HrResultsController extends GetxController {
  final _db = FirebaseFirestore.instance;

  final selectedFilter = "all".obs;
  
  final isLoading = false.obs;

  final reviewedInterviews = <Map<String, dynamic>>[].obs;
  
  final avgScore = 0.0.obs;
  final acceptRate = 0.0.obs;
  final highestScore = 0.obs;
  final lowestScore = 0.obs;
  final acceptedCount = 0.obs;
  final rejectedCount = 0.obs;
  
  final scoreDistribution = <String, int>{
    "90-100": 0,
    "80-89": 0,
    "70-79": 0,
    "60-69": 0,
    "Below 60": 0,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchAnalytics();
  }

  void changeFilter(String key) {
    selectedFilter.value = key;
    // can implement date filtering later
  }

  Future<void> _fetchAnalytics() async {
    isLoading.value = true;
    try {
      // 1. Ensure HRInterviewsController is available and fetch interviews
      final interviewsCtrl = Get.put(HRInterviewsController());
      
      // We will listen to ai_interview_results
      _db.collection('ai_interview_results').snapshots().listen((snap) {
        if (snap.docs.isEmpty) {
          _resetStats();
          return;
        }

        int totalScore = 0;
        int maxS = 0;
        int minS = 100;
        int acc = 0;
        int rej = 0;
        int totalValid = 0;
        
        Map<String, int> dist = {
          "90-100": 0,
          "80-89": 0,
          "70-79": 0,
          "60-69": 0,
          "Below 60": 0,
        };

        // For reviewedInterviews list aggregation
        Map<String, Map<String, dynamic>> agg = {};

        for (var doc in snap.docs) {
          final data = doc.data();
          final decision = data['decision']?.toString() ?? 'pending';
          if (decision == 'pending') continue; // only count completed/reviewed

          final score = (data['totalScore'] as num?)?.toInt() ?? 0;
          
          totalValid++;
          totalScore += score;
          if (score > maxS) maxS = score;
          if (score < minS) minS = score;
          
          if (decision == 'accepted') acc++;
          if (decision == 'rejected') rej++;

          if (score >= 90) dist["90-100"] = dist["90-100"]! + 1;
          else if (score >= 80) dist["80-89"] = dist["80-89"]! + 1;
          else if (score >= 70) dist["70-79"] = dist["70-79"]! + 1;
          else if (score >= 60) dist["60-69"] = dist["60-69"]! + 1;
          else dist["Below 60"] = dist["Below 60"]! + 1;

          // Aggregation by interview
          final interviewId = data['interviewId']?.toString() ?? '';
          if (interviewId.isNotEmpty) {
             if (!agg.containsKey(interviewId)) {
                agg[interviewId] = {
                  "id": interviewId,
                  "title": data['title'] ?? "Unknown Position",
                  "date": data['startTime'] != null ? DateFormat('MMM d').format((data['startTime'] as Timestamp).toDate()) : "Recent",
                  "count": 0,
                  "totalScore": 0,
                  "avg": 0,
                };
             }
             agg[interviewId]!["count"] = (agg[interviewId]!["count"] as int) + 1;
             agg[interviewId]!["totalScore"] = (agg[interviewId]!["totalScore"] as int) + score;
          }
        }

        if (totalValid > 0) {
          avgScore.value = totalScore / totalValid;
          acceptRate.value = (acc / totalValid) * 100;
          highestScore.value = maxS;
          lowestScore.value = minS;
          acceptedCount.value = acc;
          rejectedCount.value = rej;
          scoreDistribution.value = dist;
          
          final list = agg.values.map((v) {
             v["avg"] = (v["totalScore"] as int) ~/ (v["count"] as int);
             return v;
          }).toList();
          
          // Sort by highest count or most recent
          list.sort((a, b) => (b["count"] as int).compareTo(a["count"] as int));
          reviewedInterviews.value = list;
        } else {
          _resetStats();
        }
      });
      
    } catch (e) {
      print("Error fetching HR analytics: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _resetStats() {
    avgScore.value = 0.0;
    acceptRate.value = 0.0;
    highestScore.value = 0;
    lowestScore.value = 0;
    acceptedCount.value = 0;
    rejectedCount.value = 0;
    scoreDistribution.value = {
      "90-100": 0,
      "80-89": 0,
      "70-79": 0,
      "60-69": 0,
      "Below 60": 0,
    };
    reviewedInterviews.clear();
  }

  void openInsights(Map<String, dynamic> interview) {
    // Navigate using HRInterviewsController if available
    try {
       final ctrl = Get.find<HRInterviewsController>();
       final iList = ctrl.reviewedInterviews.where((i) => i.id == interview['id']).toList();
       if (iList.isNotEmpty) {
          ctrl.openInterviewDetail(iList.first);
       } else {
          Get.snackbar("Error", "Interview details not found");
       }
    } catch (_) {
       Get.to(
          () => const HrInsightsPage(),
          binding: BindingsBuilder(() {
            Get.put(HrReviewedDetailController());
          }),
        );
    }
  }
}
