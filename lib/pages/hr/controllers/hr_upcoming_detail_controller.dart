// ===================== File: hr_upcoming_detail_controller.dart =====================
// Purpose:
// Controls Upcoming Interview Detail page using real Firestore data.
// ================================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

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
    debugPrint("Initializing HRUpcomingDetailController with ID: ${data['id']}");
    
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
    if (interviewId.isEmpty) {
      debugPrint("Warning: interviewId is empty, cannot listen to updates.");
      return;
    }

    _db.collection('interviews').doc(interviewId.value).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data()!;
        _initFromInterview({...data, 'id': snap.id});
        
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
    if (interviewId.isEmpty) {
      showSimpleNotification(const Text("Error: Missing Interview ID"), background: Colors.red);
      return;
    }
    title.value = newTitle;
    await _db.collection('interviews').doc(interviewId.value).update({"title": newTitle});
  }

  Future<void> updatePosition(String newPosition) async {
    if (interviewId.isEmpty) {
      showSimpleNotification(const Text("Error: Missing Interview ID"), background: Colors.red);
      return;
    }
    position.value = newPosition;
    await _db.collection('interviews').doc(interviewId.value).update({"position": newPosition});
  }

  Future<void> updateDate(BuildContext context) async {
    if (interviewId.isEmpty) {
      showSimpleNotification(const Text("Error: Missing Interview ID"), background: Colors.red);
      return;
    }
    // Current date for initial picker
    final current = date.value.isNotEmpty ? DateFormat('MMM dd, yyyy').parse(date.value) : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      try {
        final doc = await _db.collection('interviews').doc(interviewId.value).get();
        if (!doc.exists) return;
        
        final data = doc.data()!;
        final oldStart = (data['startTime'] as Timestamp).toDate();
        final oldEnd = (data['endTime'] as Timestamp).toDate();

        // Preserve hours and minutes
        final newStart = DateTime(picked.year, picked.month, picked.day, oldStart.hour, oldStart.minute);
        final newEnd = DateTime(picked.year, picked.month, picked.day, oldEnd.hour, oldEnd.minute);

        await _db.collection('interviews').doc(interviewId.value).update({
          "startTime": Timestamp.fromDate(newStart),
          "endTime": Timestamp.fromDate(newEnd),
        });
        
        showSimpleNotification(const Text("Date updated"), background: Colors.green);
      } catch (e) {
        showSimpleNotification(Text("Failed to update date: $e"), background: Colors.red);
      }
    }
  }

  void updateTime(BuildContext context) {
    if (interviewId.isEmpty) {
      showSimpleNotification(const Text("Error: Missing Interview ID"), background: Colors.red);
      return;
    }
    Get.dialog(
      CITimeRangeDialog(
        onSave: (start, end) async {
          try {
            final currentDt = DateFormat('MMM dd, yyyy').parse(date.value);
            
            final newStart = DateTime(currentDt.year, currentDt.month, currentDt.day, start.hour, start.minute);
            final newEnd = DateTime(currentDt.year, currentDt.month, currentDt.day, end.hour, end.minute);

            await _db.collection('interviews').doc(interviewId.value).update({
              "startTime": Timestamp.fromDate(newStart),
              "endTime": Timestamp.fromDate(newEnd),
            });

            showSimpleNotification(const Text("Time updated"), background: Colors.green);
          } catch (e) {
            showSimpleNotification(Text("Failed to update time: $e"), background: Colors.red);
          }
        },
      ),
    );
  }

  void removeCandidate(Map<String, dynamic> candidate) async {
    if (interviewId.isEmpty) return;
    try {
      await _db.collection('interviews').doc(interviewId.value).update({
        "candidateIds": FieldValue.arrayRemove([candidate["id"]]),
      });
    } catch (e) {
      showSimpleNotification(const Text("Failed to remove candidate"), background: Colors.red);
    }
  }
}
