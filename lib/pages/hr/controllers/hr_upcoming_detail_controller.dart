// ===================== File: hr_upcoming_detail_controller.dart =====================
// Purpose:
// Controls Upcoming Interview Detail page
//
// IMPORTANT:
// - Uses mock data for now
// - Fully backend-ready
//
// TODO (Backend):
// - Fetch interview detail by ID
// - Update schedule (date/time)
// - Manage candidate list (add/remove)
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/ci_time_range_dialog.dart';

class HRUpcomingDetailController extends GetxController {
  final Map<String, dynamic> interview;

  HRUpcomingDetailController({required this.interview});

  // ===============================
  // BASE INFO
  // ===============================
  final title = "".obs;
  final position = "".obs;
  final team = "".obs;

  final interviewId = "".obs;

  // ===============================
  // CANDIDATES INFO
  // ===============================
  final candidateCountText = "".obs;
  final candidateSubText = "".obs;

  // ===============================
  // SCHEDULE
  // ===============================
  final date = "".obs;
  final day = "".obs;
  final timeRange = "".obs;
  final duration = "".obs;

  // ===============================
  // EDITABLE DATA
  // ===============================
  final candidates = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadMockData();

    // ===============================
    // TODO (Backend)
    // ===============================
    /*
    fetchInterviewDetail();
    */
  }

  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    title.value = interview["title"] ?? "Interview";
    position.value = interview["position"] ?? "Senior Frontend";
    team.value = "Engineering Team";

    interviewId.value = interview["id"] ?? "INT-2025-FE-0044";

    candidateCountText.value = "8 invited";
    candidateSubText.value = "All confirmed";

    date.value = "Apr 19, 2025";
    day.value = "Saturday";
    timeRange.value = "1:30 – 2:30 PM";
    duration.value = "60 minutes";

    candidates.value = [
      {
        "name": "James Chen",
        "email": "james.chen@email.com",
      },
      {
        "name": "Mia Kim",
        "email": "mia.kim@email.com",
      },
      {
        "name": "Ava Lopez",
        "email": "ava.lopez@email.com",
      },
      {
        "name": "Noah Park",
        "email": "noah.park@email.com",
      },
    ];
  }

  // ===============================
  // EDIT ACTIONS
  // ===============================

  void updateTitle(String newTitle) {
    title.value = newTitle;
  }

  void updatePosition(String newPosition) {
    position.value = newPosition;
  }

  Future<void> updateDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // 🎯 FORMAT: Apr 19, 2025
      final formatted = DateFormat('MMM d, yyyy').format(picked);

      date.value = formatted;

      // TODO (Backend)
      /*
    await api.updateInterviewDate(id, picked);
    */
    }
  }

  void updateTime(BuildContext context) {
    Get.dialog(
      CITimeRangeDialog(
        onSave: (start, end) {
          timeRange.value = "$start - $end";

          // TODO backend
        },
      ),
    );
  }

  void addCandidate() {
    // TODO: open candidate picker
  }

  void removeCandidate(Map<String, dynamic> candidate) {
    candidates.remove(candidate);
  }

// ===============================
// TODO BACKEND METHODS
// ===============================
/*
  Future<void> fetchInterviewDetail() async {}

  Future<void> updateSchedule(DateTime start, DateTime end) async {}

  Future<void> updateCandidates(List<String> ids) async {}
  */

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";

    return "$hour:$minute $period";
  }
}
