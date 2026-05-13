// ===================== File: hr_ongoing_detail_controller.dart =====================
// Purpose:
// Controls Ongoing Interview Detail page using live Firestore data.
// ================================================================================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HROngoingDetailController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final Map<String, dynamic> interview;

  HROngoingDetailController({required this.interview});

  // ===============================
  // STATE
  // ===============================
  final title = "".obs;
  final position = "".obs;
  final timeRange = "".obs;
  final interviewId = "".obs;
  final elapsedTime = "00:00".obs;
  
  final activeCandidates = <Map<String, dynamic>>[].obs;
  final waitingCandidates = <Map<String, dynamic>>[].obs;
  final completedCandidates = <Map<String, dynamic>>[].obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initFromInterview(interview);
    _listenToLiveUpdates();
    _startClock();
  }

  void _initFromInterview(Map<String, dynamic> data) {
    title.value = data["title"] ?? "Interview";
    position.value = data["position"] ?? "Position";
    interviewId.value = data["id"] ?? "";
    
    if (data["startTime"] != null && data["endTime"] != null) {
      final start = (data["startTime"] is Timestamp) ? (data["startTime"] as Timestamp).toDate() : DateTime.parse(data["startTime"].toString());
      final end = (data["endTime"] is Timestamp) ? (data["endTime"] as Timestamp).toDate() : DateTime.parse(data["endTime"].toString());
      timeRange.value = "${DateFormat('h:mm').format(start)} - ${DateFormat('h:mm a').format(end)}";
    }
  }

  void _listenToLiveUpdates() {
    if (interviewId.isEmpty) return;

    // Listen to the interview document for status changes
    _db.collection('interviews').doc(interviewId.value).snapshots().listen((snap) {
      if (snap.exists) {
        _initFromInterview(snap.data()!);
      }
    });

    // Listen to candidate session statuses (assuming a sub-collection or field)
    // For now, we listen to ai_interview_results as a proxy for progress
    _db.collection('ai_interview_results')
        .where('interviewId', isEqualTo: interviewId.value)
        .snapshots()
        .listen((snap) {
          final all = snap.docs.map((doc) => doc.data()).toList();
          
          completedCandidates.value = all.where((c) => c['status'] == 'completed').map((c) => {
            "name": c['candidateName'] ?? "Candidate",
            "subtitle": "Finished at ${DateFormat('h:mm a').format((c['submittedAt'] as Timestamp).toDate())}",
            "status": "done"
          }).toList();

          activeCandidates.value = all.where((c) => c['status'] == 'in_progress').map((c) => {
            "name": c['candidateName'] ?? "Candidate",
            "subtitle": "Started at ${DateFormat('h:mm a').format((c['startedAt'] as Timestamp).toDate())}",
            "status": "active"
          }).toList();

          // Waiting candidates would be (interview.candidateIds - (active + completed))
          // Logic omitted for brevity but follows the same pattern
        });
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      // Calculate elapsed time since interview start
      if (interview["startTime"] != null) {
        final start = (interview["startTime"] is Timestamp) ? (interview["startTime"] as Timestamp).toDate() : DateTime.parse(interview["startTime"].toString());
        final diff = now.difference(start);
        if (diff.isNegative) {
          elapsedTime.value = "Starting soon";
        } else {
          final minutes = diff.inMinutes.toString().padLeft(2, '0');
          final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
          elapsedTime.value = "$minutes:$seconds";
        }
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
