import 'package:interview_project/models/question.dart';
import '../../../services/ai/ai_service.dart';

/// Soruları AI servisine gönderip tahmini süre döndürür.
/// Şimdilik stub: tip ve zorluk katsayılarıyla yaklaşık süre hesaplar.
abstract class AiDurationService {
  Future<Duration> estimateFor(List<Question> questions);
}

class AiDurationServiceStub implements AiDurationService {
  final AiService aiService = AiService(); // AiService bağımlılığını ekleyin

  @override
  Future<Duration> estimateFor(List<Question> questions) async {
    if (questions.isEmpty) {
      return Duration.zero;
    }
    // AiService'teki findExamTime metodunu kullanın
    // final totalSeconds = await aiService.findExamTime(questions);
    // return Duration(seconds: totalSeconds);
    return const Duration(seconds: 300);
  }
}