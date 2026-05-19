import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/job_application.dart';

class JobApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<JobApplication>> getApplicationsStream() {
    return _firestore
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobApplication.fromJson(doc.data())).toList();
    });
  }

  Stream<List<JobApplication>> getApplicationsForPostingStream(String jobPostingId) {
    return _firestore
        .collection('applications')
        .where('jobPostingId', isEqualTo: jobPostingId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobApplication.fromJson(doc.data())).toList();
    });
  }

  Future<void> submitApplication(JobApplication application) async {
    try {
      // 1. Check for existing application
      final existing = await _firestore
          .collection('applications')
          .where('candidateId', isEqualTo: application.candidateId)
          .where('jobPostingId', isEqualTo: application.jobPostingId)
          .limit(1)
          .get();

      final postingRef = _firestore.collection('job_postings').doc(application.jobPostingId);
      final userRef = _firestore.collection('users').doc(application.candidateId);

      if (existing.docs.isNotEmpty) {
        // UPDATE MODE
        final docId = existing.docs.first.id;
        final oldData = existing.docs.first.data();
        
        // Update application document
        await _firestore.collection('applications').doc(docId).update(application.toJson());

        // Update Job Posting's applicant list (Replace old entry in array)
        final postingSnap = await postingRef.get();
        if (postingSnap.exists) {
          final List applicants = List.from(postingSnap.data()?['applicants'] ?? []);
          final index = applicants.indexWhere((a) => a['userId'] == application.candidateId);
          
          final updatedEntry = {
            'userId': application.candidateId,
            'name': application.candidateName ?? "Anonymous",
            'university': application.university ?? "",
            'department': application.department ?? "",
            'status': oldData['status'] ?? 'pending', // Keep existing status
            'appliedAt': oldData['appliedAt'] ?? DateTime.now().toIso8601String(),
          };

          if (index != -1) {
            applicants[index] = updatedEntry;
          } else {
            applicants.add(updatedEntry);
          }

          await postingRef.update({'applicants': applicants});
        }
        return;
      }

      // Deterministic ID to prevent duplicates
      final deterministicId = "${application.candidateId}_${application.jobPostingId}";
      final docRef = _firestore.collection('applications').doc(deterministicId);
      final appWithId = application.copyWith(id: deterministicId);

      // 1. Save application document (using set to overwrite if exists, but we'll also check counters)
      if (existing.docs.isEmpty) {
        // NEW APPLICATION MODE
        await docRef.set(appWithId.toJson());

        // 2. Update Job Posting's applicant list & count
        await postingRef.update({
          'applicants': FieldValue.arrayUnion([
            {
              'userId': application.candidateId,
              'name': application.candidateName ?? "Anonymous",
              'university': application.university ?? "",
              'department': application.department ?? "",
              'status': 'pending',
              'appliedAt': DateTime.now().toIso8601String(),
            }
          ]),
          'applicantCount': FieldValue.increment(1),
          'pending': FieldValue.increment(1),
        });
      } else {
        // Already exists - update the data without incrementing counters
        await docRef.update(application.toJson());
      }

      // 3. Update User's application list
      await userRef.update({
        'jobApplicationIds': FieldValue.arrayUnion([deterministicId]),
      });

    } catch (e) {
      print('JobApplicationService: Error submitting application: $e');
      rethrow;
    }
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status.name,
        'reviewedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('JobApplicationService: Error updating application status: $e');
    }
  }
}
