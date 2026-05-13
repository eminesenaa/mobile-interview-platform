import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/interview.dart';
import '../../models/interview_result.dart';
import '../../models/interview_session.dart';
import 'interview_service.dart';

class FirebaseInterviewService implements InterviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Interview>> getUserInterviews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('interviews')
          .where('candidateIds', arrayContains: userId)
          .get();

      return snapshot.docs.map((doc) => Interview.fromJson(doc.data())).toList();
    } catch (e) {
      print('FirebaseInterviewService: Error getting user interviews: $e');
      return [];
    }
  }

  @override
  Future<Interview?> getInterviewById(String interviewId) async {
    try {
      final doc = await _firestore.collection('interviews').doc(interviewId).get();
      if (!doc.exists) return null;
      return Interview.fromJson(doc.data()!);
    } catch (e) {
      print('FirebaseInterviewService: Error getting interview by ID: $e');
      return null;
    }
  }

  @override
  Future<InterviewSession> startSession({
    required String interviewId,
    required String userId,
  }) async {
    try {
      final interview = await getInterviewById(interviewId);
      if (interview == null) throw Exception("Interview not found");

      final sessionDoc = _firestore.collection('interview_sessions').doc('${interviewId}_$userId');
      final snapshot = await sessionDoc.get();

      if (snapshot.exists) {
        return InterviewSession.fromJson(snapshot.data()!);
      }

      final session = InterviewSession(
        id: '${interviewId}_$userId',
        interviewId: interviewId,
        candidateId: userId,
        secondsLeft: interview.duration.inSeconds,
        isStarted: true,
        startedAt: DateTime.now(),
      );

      await sessionDoc.set(session.toJson());
      return session;
    } catch (e) {
      print('FirebaseInterviewService: Error starting session: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSession(InterviewSession session) async {
    try {
      await _firestore
          .collection('interview_sessions')
          .doc(session.id)
          .update(session.toJson());
    } catch (e) {
      print('FirebaseInterviewService: Error updating session: $e');
    }
  }

  @override
  Future<InterviewSession?> getSession(String interviewId, String userId) async {
    try {
      final doc = await _firestore
          .collection('interview_sessions')
          .doc('${interviewId}_$userId')
          .get();
      if (!doc.exists) return null;
      return InterviewSession.fromJson(doc.data()!);
    } catch (e) {
      print('FirebaseInterviewService: Error getting session: $e');
      return null;
    }
  }

  @override
  Future<void> saveInterviewResult({
    required String interviewId,
    required String userId,
    required Map<String, dynamic> answers,
    required dynamic aiResult,
  }) async {
    try {
      final resultId = '${interviewId}_$userId';
      
      final data = {
        'interviewId': interviewId,
        'candidateId': userId,
        'answers': answers,
        'aiResult': aiResult.toJson(), // Assuming AiInterviewResult has toJson()
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'completed',
        'starAnalysis': _extractStarAnalysis(aiResult), // Helper for easy filtering
      };

      await _firestore.collection('interview_results').doc(resultId).set(data);

      // Also update the interview status in the main collection if needed
      // (Optional based on how list screens query data)
      await _firestore.collection('interviews').doc(interviewId).update({
        'status': 'completed',
      });
      
    } catch (e) {
      print('FirebaseInterviewService: Error saving interview result: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _extractStarAnalysis(dynamic aiResult) {
    // Extract STAR metrics from AI result for easier dashboard reporting
    try {
      if (aiResult is! AiInterviewResult) return {};
      
      final starAggregator = <String, List<double>>{
        'S': [], 'T': [], 'A': [], 'R': []
      };

      for (final qResult in aiResult.questionResults) {
        final coverage = qResult.starCoverage;
        if (coverage != null) {
          coverage.forEach((k, v) {
            if (starAggregator.containsKey(k)) {
              starAggregator[k]!.add(v);
            }
          });
        }
      }

      // Calculate averages
      return starAggregator.map((k, scores) {
        if (scores.isEmpty) return MapEntry(k, 0.0);
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        return MapEntry(k, double.parse(avg.toStringAsFixed(1)));
      });
    } catch (e) {
      print('FirebaseInterviewService: Error extracting STAR analysis: $e');
      return {};
    }
  }

  @override
  Future<List<InterviewResult>> getUserResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('interview_results')
          .where('candidateId', valueEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => InterviewResult.fromJson(doc.data())).toList();
    } catch (e) {
      print('FirebaseInterviewService: Error getting user results: $e');
      return [];
    }
  }
}
