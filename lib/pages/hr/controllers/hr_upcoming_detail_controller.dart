// ===================== File: hr_upcoming_detail_controller.dart =====================
// Purpose:
// Controls Upcoming Interview Detail page using real Firestore data.
// ================================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../create_interview/widgets/create_interview/ci_time_range_dialog.dart';

class HRUpcomingDetailController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final Map<String, dynamic> interview;

  HRUpcomingDetailController({required this.interview});

  // ===============================
  // STATE
  // ===============================
  final title = "".obs;
  final position = "".obs;
  final team = "".obs;
  final interviewId = "".obs;
  final date = "".obs;
  final day = "".obs;
  final timeRange = "".obs;
  final duration = "".obs;
  final candidates = <Map<String, dynamic>>[].obs;
  final candidateCountText = "".obs;
  final candidateSubText = "".obs;

  @override
  void onInit() {
    super.onInit();
    _initFromInterview(interview);
    _listenToInterviewUpdates();
  }

  void _initFromInterview(Map<String, dynamic> data) {
    title.value = data["title"] ?? "Interview";
    position.value = data["position"] ?? "Position";
    team.value = data["team"] ?? "Engineering Team";
    interviewId.value = data["id"] ?? "";
    
    if (data["startTime"] != null) {
      final start = (data["startTime"] is Timestamp) ? (data["startTime"] as Timestamp).toDate() : DateTime.parse(data["startTime"].toString());
      final end = (data["endTime"] is Timestamp) ? (data["endTime"] as Timestamp).toDate() : DateTime.parse(data["endTime"].toString());
      
      date.value = DateFormat('MMM dd, yyyy').format(start);
      day.value = DateFormat('EEEE').format(start);
      timeRange.value = "${DateFormat('h:mm').format(start)} – ${DateFormat('h:mm a').format(end)}";
      duration.value = "${end.difference(start).inMinutes} minutes";
    }

    candidateSubText.value = "Awaiting candidate confirmation";
  }

  void _listenToInterviewUpdates() {
    if (interviewId.isEmpty) return;

    _db.collection('interviews').doc(interviewId.value).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data()!;
        _initFromInterview(data);
        
        final ids = List<String>.from(data['candidateIds'] ?? []);
        _fetchCandidateDetails(ids);
      }
    });
  }

  Future<void> _fetchCandidateDetails(List<String> ids) async {
    if (ids.isEmpty) {
      candidates.clear();
      candidateCountText.value = "0 invited";
      return;
    }

    final usersSnap = await _db.collection('users').where(FieldPath.documentId, whereIn: ids).get();
    candidates.value = usersSnap.docs.map((doc) => {
      "id": doc.id,
      "name": "${doc.data()['name']} ${doc.data()['surname']}",
      "email": doc.data()['email'],
    }).toList();
    
    candidateCountText.value = "${candidates.length} invited";
  }

  // ===============================
  // ACTIONS
  // ===============================

  Future<void> updateTitle(String newTitle) async {
    title.value = newTitle;
    if (interviewId.isNotEmpty) {
      await _db.collection('interviews').doc(interviewId.value).update({"title": newTitle});
    }
  }

  Future<void> updatePosition(String newPosition) async {
    position.value = newPosition;
    if (interviewId.isNotEmpty) {
      await _db.collection('interviews').doc(interviewId.value).update({"position": newPosition});
    }
  }

  Future<void> updateDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      try {
        await _db.collection('interviews').doc(interviewId.value).update({
          "startTime": Timestamp.fromDate(picked),
        });
        Get.snackbar("Success", "Date updated");
      } catch (e) {
        Get.snackbar("Error", "Failed to update date: $e");
      }
    }
  }

  void updateTime(BuildContext context) {
    Get.dialog(
      CITimeRangeDialog(
        onSave: (start, end) async {
          Get.snackbar("Info", "Time update logic would go here");
        },
      ),
    );
  }

  void removeCandidate(Map<String, dynamic> candidate) async {
    try {
      await _db.collection('interviews').doc(interviewId.value).update({
        "candidateIds": FieldValue.arrayRemove([candidate["id"]]),
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to remove candidate");
    }
  }
}
