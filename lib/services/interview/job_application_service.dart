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

  @override
  Future<void> submitApplication(JobApplication application) async {
    try {
      final docRef = _firestore.collection('applications').doc();
      final id = docRef.id;
      final appWithId = application.copyWith(id: id);

      // 1. Save application document
      await docRef.set(appWithId.toJson());

      // 2. Update Job Posting's applicant list & count
      final postingRef = _firestore.collection('job_postings').doc(application.jobPostingId);
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

      // 3. Update User's application list (Profile Sync)
      final userRef = _firestore.collection('users').doc(application.candidateId);
      await userRef.update({
        'jobApplicationIds': FieldValue.arrayUnion([id]),
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
