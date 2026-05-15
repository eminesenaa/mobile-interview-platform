// ===================== File: create_interview_controller.dart =====================
// Purpose:
// Handles state & logic for Create Interview
//
// IMPORTANT:
// - Backend-ready
// - UI bağımsız
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../models/interview.dart';
import '../../../models/job_posting.dart';
import '../../../models/question.dart';

class CreateInterviewController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ===============================
  // TEXT FIELDS
  // ===============================
  final titleCtrl = TextEditingController();
  final positionCtrl = TextEditingController();

  // ===============================
  // DATE & TIME
  // ===============================
  final selectedDate = Rxn<DateTime>();
  final selectedStartTime = Rxn<TimeOfDay>();
  final selectedEndTime = Rxn<TimeOfDay>();

  // ===============================
  // INVITE CODE
  // ===============================
  final inviteCode = "—".obs;

  // ===============================
  // QUESTIONS & CANDIDATES
  // ===============================
  final selectedQuestionIds = <String>[].obs;
  final selectedCandidates = <Map<String, dynamic>>[].obs; // {userId, name, status}
  final isLoading = false.obs;

  // ===============================
  // JOB POSTINGS
  // ===============================
  final readyPostings = <JobPosting>[].obs;
  final searchQuery = "".obs;

  // ===============================
  // SELECTED JOB POSTING
  // ===============================
  final selectedPosting = Rxn<JobPosting>();

  @override
  void onInit() {
    super.onInit();
    generateInviteCode();
    _listenToReadyPostings();
    
    // Check if posting passed via arguments
    if (Get.arguments != null && Get.arguments is JobPosting) {
      onPostingSelected(Get.arguments as JobPosting);
    }
  }

  // ===============================
  // REAL-TIME POSTINGS
  // ===============================
  void _listenToReadyPostings() {
    final user = _auth.currentUser;
    if (user == null) return;

    _db.collection('job_postings')
        .snapshots()
        .listen((snap) {
          try {
            final all = snap.docs.map((doc) {
              return JobPosting.fromJson({...doc.data(), 'id': doc.id});
            }).toList();

            // Filter by owner (allow legacy empty ID for now)
            final myPostings = all.where((p) {
              final doc = snap.docs.firstWhere((d) => d.id == p.id).data();
              final ownerId = doc['createdByHrId'] ?? '';
              return ownerId == '' || ownerId == user.uid;
            }).toList();

            // A posting is "ready" for interview if it has at least one accepted candidate
            readyPostings.value = myPostings.where((p) {
              // Check acceptedCount first
              if (p.acceptedCount > 0) return true;
              
              // Fallback: Check raw applicants array from document
              final doc = snap.docs.firstWhere((d) => d.id == p.id).data();
              final applicants = List<Map<String, dynamic>>.from(doc['applicants'] ?? []);
              return applicants.any((a) => a['status'] == 'accepted');
            }).toList();
            
            debugPrint("Loaded ${readyPostings.length} ready postings");
          } catch (e) {
            debugPrint("Error in _listenToReadyPostings: $e");
          }
        }, onError: (err) {
          debugPrint("Firestore listener error: $err");
        });
  }

  List<JobPosting> get filteredPostings {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return readyPostings;
    return readyPostings.where((p) => p.title.toLowerCase().contains(query)).toList();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void onPostingSelected(JobPosting posting) {
    selectedPosting.value = posting;
    positionCtrl.text = posting.title;
    titleCtrl.text = "${posting.title} Interview";
    _loadAcceptedCandidates(posting);
  }

  void _loadAcceptedCandidates(JobPosting posting) async {
    try {
      final doc = await _db.collection('job_postings').doc(posting.id).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final applicants = List<Map<String, dynamic>>.from(data['applicants'] ?? []);
      final accepted = applicants.where((a) => a['status'] == 'accepted').toList();
      
      selectedCandidates.assignAll(accepted);
    } catch (e) {
      debugPrint("Error loading accepted candidates: $e");
    }
  }

  // ===============================
  // ACTIONS
  // ===============================
  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) selectedStartTime.value = picked;
  }

  void pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) selectedEndTime.value = picked;
  }

  void setQuestions(List<String> ids) {
    selectedQuestionIds.assignAll(ids);
  }

  void setStartTime(TimeOfDay time) {
    selectedStartTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    selectedEndTime.value = time;
  }

  int get durationInMinutes {
    if (selectedStartTime.value == null || selectedEndTime.value == null) return 0;
    final start = selectedStartTime.value!;
    final end = selectedEndTime.value!;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes - startMinutes;
  }

  void generateInviteCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final random = Random();
    final part1 = List.generate(2, (_) => chars[random.nextInt(26)]).join();
    final part2 = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    inviteCode.value = "$part1-$part2";
  }

  // ===============================
  // CREATE INTERVIEW
  // ===============================
  Future<void> createInterview() async {
    if (titleCtrl.text.isEmpty ||
        positionCtrl.text.isEmpty ||
        selectedDate.value == null ||
        selectedStartTime.value == null ||
        selectedEndTime.value == null ||
        selectedQuestionIds.isEmpty) {
      showSimpleNotification(
        const Text("Please fill all fields and select questions"),
        background: Colors.red,
      );
      return;
    }

    final startDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    final endDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      selectedEndTime.value!.hour,
      selectedEndTime.value!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      showSimpleNotification(
        const Text("End time must be after start time"),
        background: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) throw "User not logged in";

      // 1. Fetch Question objects for the selected IDs
      final questionSnaps = await Future.wait(
        selectedQuestionIds.map((id) => _db.collection('questions').doc(id).get())
      );
      
      final questions = questionSnaps.map((s) {
        return Question.fromFirestore(s.data()!, s.id);
      }).toList();

      // 2. Prepare Interview Document
      final candidateIds = selectedCandidates.map((c) => (c['userId'] ?? '').toString()).toList();
      
      final interviewDoc = {
        "title": titleCtrl.text.trim(),
        "position": positionCtrl.text.trim(),
        "companyId": user.uid, // HR is the company owner in this simple model
        "createdByHrId": user.uid,
        "jobPostingId": selectedPosting.value?.id,
        "candidateIds": candidateIds,
        "questions": questions.map((q) => q.toJson()).toList(),
        "startTime": Timestamp.fromDate(startDateTime),
        "endTime": Timestamp.fromDate(endDateTime),
        "joinCode": inviteCode.value,
        "status": "scheduled",
        "reviewStatus": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // 3. Save to Firestore
      await _db.collection('interviews').add(interviewDoc);

      showSimpleNotification(
        const Text("Interview session created successfully"),
        background: Colors.green,
      );
      Get.back();
    } catch (e) {
      showSimpleNotification(
        Text("Failed to create interview: $e"),
        background: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    positionCtrl.dispose();
    super.onClose();
  }
}
