// ===================== File: hr_ongoing_detail_controller.dart =====================
// Purpose:
// Controls Ongoing Interview Detail page
//
// IMPORTANT:
// - Uses mock data for now
// - Backend-ready (Firestore / API)
//
// TODO (Backend):
// - Fetch interview detail by ID
// - Stream live candidate status
// - Track join / leave / completion events
// ================================================================================

import 'dart:async';

import 'package:get/get.dart';

class HROngoingDetailController extends GetxController {
  final Map<String, dynamic> interview;

  HROngoingDetailController({required this.interview});

  // ===============================
  // BASE INFO
  // ===============================
  final title = "".obs;
  final position = "".obs;
  final timeRange = "".obs;
  final interviewId = "".obs;

  // ===============================
  // LIVE INFO
  // ===============================
  final elapsedTime = "00:00".obs;
  Timer? _timer;
  int _secondsLeft = 300; // 5 dakika

  // ===============================
  // CANDIDATES
  // ===============================
  final activeCandidates = <Map<String, dynamic>>[].obs;
  final waitingCandidates = <Map<String, dynamic>>[].obs;
  final completedCandidates = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    startMockTimer();

    loadMockData();

    // ===============================
    // TODO (Backend)
    // ===============================
    /*
    fetchInterviewDetail();
    listenCandidateUpdates();
    */
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    title.value = interview["title"] ?? "Interview";
    position.value = interview["position"] ?? "Unknown";
    timeRange.value = "${interview["time"]} - ${interview["endTime"]}";
    interviewId.value = interview["id"] ?? "INT-XXXX";


    activeCandidates.value = [
      {
        "name": "James Chen",
        "subtitle": "Started 10:02 AM",
        "status": "active"
      },
      {"name": "Mia Kim", "subtitle": "Started 10:01 AM", "status": "active"},
    ];

    waitingCandidates.value = [
      {
        "name": "Tom Rivera",
        "subtitle": "Invited · No activity",
        "status": "waiting"
      },
    ];

    completedCandidates.value = [
      {
        "name": "Noah Park",
        "subtitle": "Finished at 10:41 AM",
        "status": "done"
      },
    ];
  }

  void startMockTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }

      _secondsLeft--;

      final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
      final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

      elapsedTime.value = "$minutes:$seconds";
    });
  }

// ===============================
// TODO BACKEND METHODS
// ===============================
/*
  Future<void> fetchInterviewDetail() async {
    final data = await api.getInterviewDetail(interviewId);
  }

  void listenCandidateUpdates() {
    // real-time stream (Firestore)
  }
  */
}
