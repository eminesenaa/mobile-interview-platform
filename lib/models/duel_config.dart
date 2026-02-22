// lib/models/duel_config.dart

import 'duel_enums.dart';

/// Bir düello başlatılırken kullanılan konfigürasyon modeli
class DuelConfig {
  final DuelType duelType;
  final String category;
  final int totalQuestions;
  final int questionTimeLimitSeconds;

  DuelConfig({
    required this.duelType,
    required this.category,
    this.totalQuestions = 10,
    this.questionTimeLimitSeconds = 30,
  });

  /// Backend'e gönderilecek JSON formatı
  Map<String, dynamic> toJson() {
    return {
      'duelType': duelType.name,
      'category': category,
      'totalQuestions': totalQuestions,
      'questionTimeLimitSeconds': questionTimeLimitSeconds,
    };
  }

  /// Backend'den gelirse parse edebilmek için
  factory DuelConfig.fromJson(Map<String, dynamic> json) {
    return DuelConfig(
      duelType: DuelType.values.firstWhere(
            (e) => e.name == json['duelType'],
      ),
      category: json['category'],
      totalQuestions: json['totalQuestions'] ?? 10,
      questionTimeLimitSeconds:
      json['questionTimeLimitSeconds'] ?? 30,
    );
  }
}