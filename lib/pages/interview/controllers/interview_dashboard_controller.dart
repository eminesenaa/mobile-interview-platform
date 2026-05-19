// ===================== File: interview_dashboard_controller.dart =====================
// Purpose:
// Controls Candidate Interview Dashboard using real-time Firestore data.
// ===============================================================================

import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../models/interview_result.dart';
import '../pages/interview/waiting/interview_waiting_page.dart';

class InterviewDashboardController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ===============================
  // STATE
  // ===============================
  final openPositions = <Map<String, dynamic>>[].obs;
  final applications = <Map<String, dynamic>>[].obs;
  final upcomingInterview = Rxn<Map<String, dynamic>>();
  final results = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // ===============================
  // SUBSCRIPTIONS
  // ===============================
  StreamSubscription<User?>? _authSub;
  final List<StreamSubscription> _firestoreSubs = [];

  @override
  void onInit() {
    super.onInit();
    // 🔥 Auth state'ini dinle — kullanıcı login olunca dinleyicileri kur
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        // Kullanıcı giriş yaptı: mevcut listener'ları iptal et, yeniden kur
        _cancelFirestoreListeners();
        _listenToDashboardData(user);
      } else {
        // Kullanıcı çıkış yaptı: temizle
        _cancelFirestoreListeners();
        openPositions.clear();
        applications.clear();
        upcomingInterview.value = null;
        results.clear();
      }
    });
  }

  void _cancelFirestoreListeners() {
    for (final sub in _firestoreSubs) {
      sub.cancel();
    }
    _firestoreSubs.clear();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _cancelFirestoreListeners();
    super.onClose();
  }

  // ===============================
  // REAL-TIME DATA LISTENERS
  // ===============================
  void _listenToDashboardData(User user) {
    isLoading.value = true;

    // 1. Listen to open positions
    _firestoreSubs.add(
      _db.collection('job_postings')
          .where('status', isEqualTo: 'active')
          .limit(10)
          .snapshots()
          .listen((snap) {
            final list = snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();

            // 🔥 Sort by createdAt descending
            list.sort((a, b) {
              final aTime = a['createdAt'] as Timestamp?;
              final bTime = b['createdAt'] as Timestamp?;
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime);
            });
            
            openPositions.value = list;
          })
    );

    // 2. Listen to applications
    _firestoreSubs.add(
      _db.collection('applications')
          .where('candidateId', isEqualTo: user.uid)
          .snapshots()
          .listen((snap) async {
            final List<Map<String, dynamic>> updatedApps = [];
            
            for (var doc in snap.docs) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;
              
              // If missing info, fetch from job_postings
              if (data['workType'] == null || data['location'] == null) {
                final postingDoc = await _db.collection('job_postings').doc(data['jobPostingId']).get();
                if (postingDoc.exists) {
                  final postingData = postingDoc.data()!;
                  data['workType'] = postingData['workType'];
                  data['location'] = postingData['location'];
                  data['company'] = postingData['company'] ?? "Company";
                  data['description'] = postingData['description'];
                  data['requirements'] = postingData['requirements'];
                  if (data['jobTitle'] == null) data['jobTitle'] = postingData['title'];
                }
              }
              updatedApps.add(data);
            }

            // 🔥 Sort by appliedAt descending (latest first)
            updatedApps.sort((a, b) {
              final aTime = a['appliedAt'];
              final bTime = b['appliedAt'];

              DateTime parseTime(dynamic time) {
                if (time is Timestamp) return time.toDate();
                if (time is String) return DateTime.parse(time);
                return DateTime(2000);
              }

              return parseTime(bTime).compareTo(parseTime(aTime));
            });

            applications.value = updatedApps;
          })
    );

    // 3. Listen to upcoming interview
    _firestoreSubs.add(
      _db.collection('interviews')
          .where('candidateIds', arrayContains: user.uid)
          .snapshots()
          .listen((snap) async {
            print("Candidate Interviews found by candidateIds: ${snap.docs.length}");

            List<Map<String, dynamic>> list = snap.docs.map((doc) {
              final d = doc.data();
              d['id'] = doc.id;
              return d;
            }).where((d) {
              // Must be scheduled (not all-done)
              if (d['status'] != 'scheduled') return false;
              // Must not have THIS candidate already completed it
              final completed = List<String>.from(d['completedCandidateIds'] ?? []);
              return !completed.contains(user.uid);
            }).toList();

            // 🔥 FALLBACK: If nothing found by candidateIds, try via inviteCode in applications
            if (list.isEmpty) {
              print("No interview found by candidateIds — trying inviteCode fallback...");
              try {
                final appSnap = await _db.collection('applications')
                    .where('candidateId', isEqualTo: user.uid)
                    .get();

                final Set<String> checkedCodes = {};

                for (var appDoc in appSnap.docs) {
                  final appData = appDoc.data();
                  final inviteCode = (appData['inviteCode'] ?? '').toString().trim();
                  if (inviteCode.isEmpty || checkedCodes.contains(inviteCode)) continue;
                  checkedCodes.add(inviteCode);

                  print("Checking inviteCode from application: $inviteCode");

                  // Search by joinCode
                  var iSnap = await _db.collection('interviews')
                      .where('joinCode', isEqualTo: inviteCode)
                      .where('status', isEqualTo: 'scheduled')
                      .get();

                  // Also try inviteCode field
                  if (iSnap.docs.isEmpty) {
                    iSnap = await _db.collection('interviews')
                        .where('inviteCode', isEqualTo: inviteCode)
                        .where('status', isEqualTo: 'scheduled')
                        .get();
                  }

                  for (var iDoc in iSnap.docs) {
                    final d = iDoc.data();
                    d['id'] = iDoc.id;
                    // 🔥 Self-heal: add this candidate's UID to candidateIds
                    _fixCandidateIdInInterview(iDoc.id, user.uid);
                    list.add(d);
                  }
                }
              } catch (e) {
                print("inviteCode fallback error: $e");
              }
            }

            // 🔥 SAFETY FILTER: Remove interviews the candidate already completed
            // (in case Firestore status update failed/delayed)
            if (list.isNotEmpty) {
              try {
                final resultSnap = await _db.collection('ai_interview_results')
                    .where('candidateId', isEqualTo: user.uid)
                    .get();
                final completedInterviewIds = resultSnap.docs
                    .map((d) => d.data()['interviewId']?.toString() ?? '')
                    .where((id) => id.isNotEmpty)
                    .toSet();

                // Also check by document ID pattern: {interviewId}_{userId}
                final completedByDocId = resultSnap.docs
                    .map((d) => d.id.replaceAll('_${user.uid}', ''))
                    .toSet();

                list = list.where((interview) {
                  final id = interview['id']?.toString() ?? '';
                  return !completedInterviewIds.contains(id) &&
                         !completedByDocId.contains(id);
                }).toList();

                print("After completion filter: ${list.length} upcoming interviews remain");
              } catch (e) {
                print("Error filtering completed interviews: $e");
              }
            }

            if (list.isNotEmpty) {
              list.sort((a, b) {
                try {
                  final aStart = (a['startTime'] is Timestamp) ? (a['startTime'] as Timestamp).toDate() : DateTime.parse(a['startTime'].toString());
                  final bStart = (b['startTime'] is Timestamp) ? (b['startTime'] as Timestamp).toDate() : DateTime.parse(b['startTime'].toString());
                  return aStart.compareTo(bStart);
                } catch (_) { return 0; }
              });
              upcomingInterview.value = list.first;
              print("Upcoming interview set: ${list.first['title']}");
            } else {
              upcomingInterview.value = null;
              print("No upcoming interview found for candidate.");
            }
          }, onError: (e) {
            print("Error listening to interviews: $e");
          })
    );

    // 4. Listen to results
    _firestoreSubs.add(
      _db.collection('ai_interview_results')
          .where('candidateId', isEqualTo: user.uid)
          .snapshots()
          .listen((snap) async {
            final List<Map<String, dynamic>> updatedResults = [];
            for (var doc in snap.docs) {
              final data = doc.data();
              data['id'] = doc.id;

              if (data['company'] == null || data['company'] == "Company" || data['startTime'] == null) {
                final String? interviewId = data['interviewId'];
                if (interviewId != null && interviewId.isNotEmpty) {
                  final interviewSnap = await _db
                      .collection('interviews')
                      .doc(interviewId)
                      .get();

                  if (interviewSnap.exists) {
                    final iData = interviewSnap.data();
                    data['startTime'] = iData?['startTime'];
                    data['endTime'] = iData?['endTime'];
                    
                    final String? jobPostingId = iData?['jobPostingId'] ?? data['jobPostingId'];
                    if (jobPostingId != null && jobPostingId.isNotEmpty) {
                      final postingSnap = await _db
                          .collection('job_postings')
                          .doc(jobPostingId)
                          .get();

                      if (postingSnap.exists) {
                        final pData = postingSnap.data();
                        data['company'] = pData?['company'] ?? data['company'] ?? "Company";
                        data['location'] = pData?['location'] ?? data['location'] ?? "";
                        data['title'] = pData?['title'] ?? data['title'] ?? "Interview";
                      }
                    }
                  }
                }

                // Fallback to applications if still missing
                if (data['company'] == null) {
                  final applicationSnap = await _db
                      .collection('applications')
                      .where('candidateId', isEqualTo: user.uid)
                      .where('jobPostingId', isEqualTo: data['jobPostingId'])
                      .limit(1)
                      .get();

                  if (applicationSnap.docs.isNotEmpty) {
                    final appData = applicationSnap.docs.first.data();
                    data['title'] = appData['jobTitle'] ?? data['title'] ?? "Unknown Position";
                    data['company'] = appData['company'] ?? "Company";
                    data['location'] = appData['location'] ?? "";
                    if (data['startTime'] == null) {
                      data['startTime'] = appData['appliedAt'];
                    }
                  }
                }
              }

              try {
                data['result'] = InterviewResult.fromJson(data);
              } catch (e) {
                print("Error parsing interview result in dashboard controller: $e");
              }
              updatedResults.add(data);
            }
            results.value = updatedResults;
          })
    );

    isLoading.value = false;
  }

  // ===============================
  // DERIVED STATS
  // ===============================
  int get activeApplicationsCount => applications.where((a) => a["status"] == "pending").length;
  int get readyInterviewsCount => upcomingInterview.value != null ? 1 : 0;
  int get pendingResultsCount => results.where((r) => r["decision"] == "pending").length;

  // ===============================
  // ACTIONS
  // ===============================
  void joinInterview(String inviteCode) {
    if (inviteCode.isEmpty) {
      Get.snackbar("Error", "Please enter invite code");
      return;
    }

    // Navigation logic
    Get.to(
      () => const InterviewWaitingPage(),
      arguments: {
        "code": inviteCode,
      },
    );
  }

  // ===============================
  // DATE FORMATTERS
  // ===============================
  String formatDate(dynamic date) {
    if (date == null) return "";
    final dt = (date is Timestamp) ? date.toDate() : (date is DateTime ? date : DateTime.parse(date.toString()));
    return DateFormat('MMM dd, yyyy').format(dt);
  }

  String formatTimeRange(dynamic start, dynamic end) {
    if (start == null || end == null) return "";
    final sDt = (start is Timestamp) ? start.toDate() : (start is DateTime ? start : DateTime.parse(start.toString()));
    final eDt = (end is Timestamp) ? end.toDate() : (end is DateTime ? end : DateTime.parse(end.toString()));
    return "${DateFormat('h:mm a').format(sDt)} – ${DateFormat('h:mm a').format(eDt)}";
  }

  // ===============================
  // SELF-HEALING: Fix candidateIds in Firestore
  // ===============================
  /// If an interview was created without this candidate's UID in candidateIds,
  /// patch it automatically so future lookups work correctly.
  Future<void> _fixCandidateIdInInterview(String interviewId, String userId) async {
    try {
      await _db.collection('interviews').doc(interviewId).update({
        'candidateIds': FieldValue.arrayUnion([userId]),
      });
      print("[Dashboard] Self-healed: added $userId to candidateIds of interview $interviewId");
    } catch (e) {
      print("[Dashboard] Could not self-heal candidateIds: $e");
    }
  }
}
