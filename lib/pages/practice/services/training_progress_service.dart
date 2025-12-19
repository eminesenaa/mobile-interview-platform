import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_project/models/user_training_progress.dart';

class TrainingProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Kullanıcının tüm modül ilerlemelerini getir
  Future<List<UserTrainingModuleProgress>> getAllProgressForUser(String userId) async {
    try {
      final snapshot = await _db
          .collection('user_training_progress')
          .doc(userId)
          .collection('modules')
          .get();

      return snapshot.docs.map((doc) {
        return UserTrainingModuleProgress.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('Error fetching user progress: $e');
      return [];
    }
  }

  // 2. Bir soruyu "Completed" olarak işaretle
  Future<void> markQuestionSolved({
    required String userId,
    required String moduleId,
    required String questionId,
    required int totalQuestionsInModule,
  }) async {
    final moduleRef = _db
        .collection('user_training_progress')
        .doc(userId)
        .collection('modules')
        .doc(moduleId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(moduleRef);

      Map<String, dynamic> data;
      List<dynamic> questionsList = [];
      int completedCount = 0;

      // Eğer kayıt yoksa sıfırdan oluştur
      if (!snapshot.exists) {
        data = {
          'userId': userId,
          'moduleId': moduleId,
          'totalQuestions': totalQuestionsInModule,
          'completedQuestions': 0,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          'questions': [],
          'isCompleted': false, // 🔥 Varsayılan false
        };
      } else {
        data = snapshot.data()!;
        questionsList = List.from(data['questions'] ?? []);
        completedCount = data['completedQuestions'] ?? 0;
      }

      // Bu soru daha önce çözülmüş mü kontrol et
      final existingIndex = questionsList.indexWhere((q) => q['questionId'] == questionId);
      bool isStatusChanged = false;

      if (existingIndex != -1) {
        // Zaten listeye eklenmiş, statüsü completed değilse güncelle
        if (questionsList[existingIndex]['status'] != 'completed') {
          questionsList[existingIndex]['status'] = 'completed';
          completedCount++;
          isStatusChanged = true;
        }
      } else {
        // Yeni soru ekle
        questionsList.add({
          'userId': userId,
          'moduleId': moduleId,
          'questionId': questionId,
          'status': 'completed',
        });
        completedCount++;
        isStatusChanged = true;
      }

      // Eğer bir değişiklik yoksa (zaten çözülmüşse) işlemi bitir
      if (snapshot.exists && !isStatusChanged) return;

      // 🔥 MODÜL BİTTİ Mİ KONTROLÜ
      bool isCompleted = completedCount >= totalQuestionsInModule;

      transaction.set(moduleRef, {
        ...data,
        'questions': questionsList,
        'completedQuestions': completedCount,
        'totalQuestions': totalQuestionsInModule,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch, // Model ile uyumlu timestamp
        'isCompleted': isCompleted, // 🔥 YENİ ALAN GÜNCELLENDİ
      }, SetOptions(merge: true));
    });
  }
}