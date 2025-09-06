import 'package:interview_project/models/question.dart';

/// Soruları AI servisine gönderip tahmini süre döndürür.
/// Şimdilik stub: tip ve zorluk katsayılarıyla yaklaşık süre hesaplar.
abstract class AiDurationService {
  Future<Duration> estimateFor(List<Question> questions);
}

class AiDurationServiceStub implements AiDurationService {
  @override
  Future<Duration> estimateFor(List<Question> questions) async {
    double minutes = 0;

    for (final q in questions) {
      final type = q.type;         // QuestionType?
      final diff = q.difficulty;   // Difficulty?

      final base = switch (type) {
        QuestionType.mcq        => 1.2,
        QuestionType.shortAnswer=> 2.0,
        QuestionType.coding     => 6.0,
        QuestionType.fillBlank  => 1.5,
        QuestionType.debugging  => 4.0,
        null                    => 1.5, // varsayılan
      };

      final k = switch (diff) {
        Difficulty.easy         => 0.9,
        Difficulty.easy_medium   => 1.0,
        Difficulty.medium       => 1.2,
        Difficulty.medium_hard   => 1.4,
        Difficulty.hard         => 1.6,
        null                    => 1.1,
      };

      minutes += base * k;
    }

    // en az 1 dk olsun
    final m = minutes.ceil().clamp(1, 24 * 60);
    return Duration(minutes: m);
  }
}
