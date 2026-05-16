// ===================== File: interview_session_controller.dart =====================
// Purpose:
// Controls Interview Waiting & Session Flow
//
// Responsibilities:
// - Hold interview session data
// - Manage waiting state
// - Auto-start interview (simulate host start)
// - Navigate to exam page
//
// IMPORTANT:
// - Uses mock logic for now
// - Backend-ready structure
//
// TODO (Backend):
// - Validate invite code via API
// - Fetch interview session details
// - Listen to "session started" event (WebSocket / Firestore)
// - Replace timer-based auto start
// ==============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../models/exam.dart';
import '../../../models/question.dart';
import '../../exam/take/exam_page.dart'; // 🔥 REUSE
import '../../../constants/constants.dart';

class InterviewSessionController extends GetxController {
  // ===============================
  // INTERVIEW DATA
  // ===============================

  final date = "".obs;
  final time = "".obs;
  final sessionCode = "".obs;
  final isWaiting = true.obs;

  // ===============================
  // INTERNAL TIMER
  // ===============================

  Timer? _autoStartTimer;

  // ===============================
  // FIRESTORE
  // ===============================

  final _db = FirebaseFirestore.instance;

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null) {
      final inviteCode = args["code"] ?? "";
      _loadInterviewData(inviteCode);
    }
  }

  Future<void> _loadInterviewData(String code) async {
    final inputCode = code.trim().toUpperCase();
    final inputCodeNoHyphen = inputCode.replaceAll("-", "");
    
    print("InterviewSessionController: Aggressive Search for: $inputCode");
    
    try {
      // Strategy 1: Search by Document ID directly (Fallback)
      try {
        final docById = await _db.collection('interviews').doc(code.trim()).get();
        if (docById.exists) {
          print("InterviewSessionController: Match found by Document ID!");
          _processMatch(docById);
          return;
        }
      } catch (_) {}

      // Strategy 2: Direct joinCode match
      var snap = await _db.collection('interviews')
          .where('joinCode', isEqualTo: inputCode)
          .get();

      if (snap.docs.isNotEmpty) {
        _processMatch(snap.docs.first);
        return;
      }

      // Strategy 3: Hyphen-insensitive search
      final allRecent = await _db.collection('interviews').get();
      print("InterviewSessionController: Scanning ${allRecent.docs.length} documents...");
      
      DocumentSnapshot? match;
      for (var doc in allRecent.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dbCode = (data['joinCode']?.toString() ?? "").replaceAll("-", "").toUpperCase();
        
        print("Comparing input '$inputCodeNoHyphen' with DB code '$dbCode' (Doc: ${doc.id})");
        
        if (dbCode == inputCodeNoHyphen && inputCodeNoHyphen.isNotEmpty) {
          match = doc;
          break;
        }
      }
      
      if (match != null) {
        _processMatch(match);
      } else {
        showSimpleNotification(
          Text("No interview found for '$inputCode'"),
          background: Colors.red,
        );
      }
    } catch (e) {
      print("InterviewSessionController: Error: $e");
      showSimpleNotification(Text("Search Error: $e"), background: Colors.red);
    }
  }

  void _processMatch(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }
    
    final start = parseDate(data['startTime']);
    final end = parseDate(data['endTime']);
    final now = DateTime.now();

    // 🔥 Set values first so they are visible in UI
    date.value = DateFormat('MMM dd, yyyy').format(start);
    time.value = "${DateFormat('h:mm').format(start)} – ${DateFormat('h:mm a').format(end)}";
    sessionCode.value = doc.id;

    // 🔥 TIME RESTRICTIONS
    if (now.isAfter(end)) {
      showSimpleNotification(
        Text("This interview session has already ended."),
        background: AppColors.error,
      );
      Navigator.of(Get.context!).pop();
      return;
    }

    if (now.isBefore(start)) {
      final formattedStart = DateFormat('HH:mm').format(start);
      showSimpleNotification(
        Text("You've joined early! The interview will start at $formattedStart"),
        background: Colors.blue,
      );
      
      // Calculate delay until start
      final delay = start.difference(now);
      startWaitingFlow(data, customDelay: delay);
      return;
    }

    showSimpleNotification(
      Text("Success! Joined ${data['title'] ?? 'Interview'}"),
      background: Colors.green,
    );

    startWaitingFlow(data);
  }

  // ===============================
  // WAITING FLOW
  // ===============================

  void startWaitingFlow(Map<String, dynamic> interviewData, {Duration? customDelay}) {
    // If it's time or early, set a timer. 
    // If early, wait until start time. If already time, wait 3 seconds for simulation.
    final delay = customDelay ?? const Duration(seconds: 3);
    
    print("InterviewSessionController: Starting in ${delay.inSeconds} seconds...");
    
    _autoStartTimer?.cancel();
    _autoStartTimer = Timer(delay, () {
      startInterview(interviewData);
    });
  }

  // ===============================
  // START INTERVIEW
  // ===============================

  Future<void> startInterview(Map<String, dynamic> interviewData) async {
    isWaiting.value = false;

    final List<Question> questions = (interviewData['questions'] as List<dynamic>? ?? [])
        .map((q) => Question.fromFirestore(q, q['id'] ?? ''))
        .toList();

    final exam = Exam(
      id: sessionCode.value,
      title: interviewData['title'] ?? "Interview",
      duration: Duration(minutes: questions.length),
      createdAt: DateTime.now(),
      questions: questions,
    );

    Get.offAll(
      () => const ExamPage(),
      arguments: exam,
    );
  }

  // ===============================
  // CLEANUP
  // ===============================

  @override
  void onClose() {
    _autoStartTimer?.cancel();
    super.onClose();
  }
}
