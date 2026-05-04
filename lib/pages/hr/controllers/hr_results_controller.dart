// ===================== File: hr_results_controller.dart =====================
// Purpose:
// Controller for Results (global analytics)
// ===========================================================================

import 'package:get/get.dart';

import '../interviews/reviewed/hr_insights_page.dart';
import 'hr_reviewed_detail_controller.dart';


class HrResultsController extends GetxController {
  /// ================= FILTER =================
  final selectedFilter = "all".obs;

  void changeFilter(String key) {
    selectedFilter.value = key;
    // TODO: filtreye göre data çekilecek
  }

  /// ================= MOCK DATA =================
  final reviewedInterviews = <Map<String, dynamic>>[
    {
      "title": "Frontend Developer",
      "date": "Apr 14",
      "count": 8,
      "avg": 82,
    },
    {
      "title": "Backend Engineering R2",
      "date": "Apr 12",
      "count": 5,
      "avg": 78,
    },
    {
      "title": "Product Designer",
      "date": "Apr 8",
      "count": 6,
      "avg": 85,
    },
    {
      "title": "ML Engineer",
      "date": "Apr 2",
      "count": 7,
      "avg": 76,
    },
  ].obs;

  /// ================= METRICS =================

  double get avgScore {
    if (reviewedInterviews.isEmpty) return 0;
    final total =
        reviewedInterviews.fold<int>(0, (sum, e) => sum + (e["avg"] as int));
    return total / reviewedInterviews.length;
  }

  double get acceptRate => 62; // mock

  int get highestScore {
    if (reviewedInterviews.isEmpty) return 0;
    return reviewedInterviews
        .map((e) => e["avg"] as int)
        .reduce((a, b) => a > b ? a : b);
  }

  int get lowestScore {
    if (reviewedInterviews.isEmpty) return 0;
    return reviewedInterviews
        .map((e) => e["avg"] as int)
        .reduce((a, b) => a < b ? a : b);
  }

  /// ================= DECISION =================
  int get acceptedCount => 55; // mock
  int get rejectedCount => 34; // mock

  /// ================= DISTRIBUTION =================
  Map<String, int> get scoreDistribution => {
        "90-100": 20,
        "80-89": 30,
        "70-79": 16,
        "60-69": 12,
        "Below 60": 11,
      };

  /// ================= NAVIGATION =================
  void openInsights(Map<String, dynamic> interview) {
    Get.to(
          () => const HrInsightsPage(),
      binding: BindingsBuilder(() {
        Get.put(HrReviewedDetailController());
      }),
    );
  }
}
