// ===================== File: hr_interviews_controller.dart =====================
// Purpose:
// Controls data for HR Interviews page using real-time Firestore data.
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../models/interview.dart';

import '../interviews/needs_review/hr_needs_review_detail_page.dart';
import '../interviews/ongoing/hr_ongoing_interview_detail_page.dart';
import '../interviews/reviewed/hr_reviewed_detail_page.dart';
import '../interviews/upcoming/hr_upcoming_interview_detail_page.dart';
import 'hr_needs_review_detail_controller.dart';

class HRInterviewsController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ===============================
  // RAW INTERVIEW LIST
  // ===============================
  final interviews = <Interview>[].obs;

  // ===============================
  // GROUPED DATA (UI READY)
  // ===============================
  final todayInterviews = <Interview>[].obs;
  final needsReviewInterviews = <Interview>[].obs;
  final reviewedInterviews = <Interview>[].obs;

  // ===============================
  // STATS
  // ===============================
  final totalCount = 0.obs;
  final ongoingCount = 0.obs;
  final completedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToInterviews();
  }

  // ===============================
  // REAL-TIME INTERVIEWS
  // ===============================
  void _listenToInterviews() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _db.collection('interviews')
       .where('createdByHrId', isEqualTo: user.uid)
       .snapshots().listen((snap) {
      interviews.value = snap.docs.map((doc) {
        return Interview.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
      processInterviews();
    });
  }

  // ===============================
  // PROCESS DATA FOR UI
  // ===============================
  void processInterviews() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    todayInterviews.clear();
    needsReviewInterviews.clear();
    reviewedInterviews.clear();

    for (final interview in interviews) {
      final status = interview.status;
      final reviewStatus = interview.reviewStatus;
      final startTime = interview.startTime;
      final endTime = interview.endTime;
      final interviewDate = DateTime(startTime.year, startTime.month, startTime.day);

      final isTimeCompleted = now.isAfter(endTime);
      final hasCompletedCandidates = interview.completedCandidateIds.isNotEmpty;
      final isCompleted = status == InterviewStatus.completed || isTimeCompleted || hasCompletedCandidates;

      if (isCompleted) {
        if (reviewStatus == ReviewStatus.reviewed) {
          reviewedInterviews.add(interview);
        } else {
          needsReviewInterviews.add(interview);
        }
      } else {
        if (interviewDate.isAtSameMomentAs(today)) {
          todayInterviews.add(interview);
        }
      }
    }

    // SORT BY TIME
    todayInterviews.sort((a, b) => a.startTime.compareTo(b.startTime));
    needsReviewInterviews.sort((a, b) => b.startTime.compareTo(a.startTime));
    reviewedInterviews.sort((a, b) => b.startTime.compareTo(a.startTime));

    // STATS
    totalCount.value = interviews.length;
    ongoingCount.value = interviews.where((i) => i.status == InterviewStatus.active).length;
    completedCount.value = interviews.where((i) => i.status == InterviewStatus.completed).length;
  }

  // ===============================
  // ACTIONS
  // ===============================

  void openInterviewDetail(Interview interview) {
    final status = interview.status;
    final reviewStatus = interview.reviewStatus;
    final interviewMap = interview.toJson();

    if (status == InterviewStatus.active) {
      Get.to(() => HROngoingInterviewDetailPage(interview: interviewMap));
      return;
    }

    if (status == InterviewStatus.scheduled) {
      Get.to(() => HRUpcomingInterviewDetailPage(interview: interviewMap));
      return;
    }

    if (status == InterviewStatus.completed && reviewStatus == ReviewStatus.pending) {
      Get.to(
        () => HrNeedsReviewDetailPage(interview: interviewMap),
        binding: BindingsBuilder(() {
          Get.put(HrNeedsReviewDetailController(interview: interviewMap));
        }),
      );
      return;
    }

    if (status == InterviewStatus.completed && reviewStatus == ReviewStatus.reviewed) {
      Get.to(() => HrReviewedDetailPage(
        interview: {
          ...interviewMap,
          "candidates": interviewMap["candidates"] ?? [],
        },
      ));
      return;
    }
  }
}
