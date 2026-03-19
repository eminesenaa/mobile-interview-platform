// lib/models/duel_player.dart

import 'package:flutter/material.dart';

/// Her oyuncuya userId'den türetilen sabit renk atar
Color avatarColorFromId(String userId) {
  const colors = [
    Color(0xFFE53935), // kırmızı
    Color(0xFF8E24AA), // mor
    Color(0xFF1E88E5), // mavi
    Color(0xFF00897B), // teal
    Color(0xFFF4511E), // turuncu
    Color(0xFF43A047), // yeşil
    Color(0xFFFFB300), // sarı
    Color(0xFF6D4C41), // kahve
  ];
  final idx = userId.codeUnits.fold(0, (a, b) => a + b) % colors.length;
  return colors[idx];
}

/// İsmin baş harfini döner (avatar için)
String avatarInitial(String username) {
  if (username.trim().isEmpty) return '?';
  return username.trim()[0].toUpperCase();
}

/// Bir düello içerisindeki oyuncu state modeli
class DuelPlayer {
  final String userId;
  final String username;
  final String? avatarUrl;

  /// userId'den türetilen sabit renk — her oturumda aynı
  late final Color avatarColor;

  int score;
  int correctCount;
  int totalXpGained;
  int comboCount; // arka arkaya doğru sayısı

  /// Mevcut soruya cevap verip vermediği
  bool answeredCurrentQuestion;

  /// Seçtiği şık (MCQ için)
  int? selectedOptionIndex;

  /// Soruyu kaç saniyede cevapladı (hız bonusu için)
  int? answerTimeSeconds;

  DuelPlayer({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.score = 0,
    this.correctCount = 0,
    this.totalXpGained = 0,
    this.comboCount = 0,
    this.answeredCurrentQuestion = false,
    this.selectedOptionIndex,
    this.answerTimeSeconds,
    Color? avatarColor,
  }) {
    this.avatarColor = avatarColor ?? avatarColorFromId(userId);
  }

  /// Yeni soru başladığında oyuncu state'ini sıfırlamak için
  void resetForNextQuestion() {
    answeredCurrentQuestion = false;
    selectedOptionIndex = null;
    answerTimeSeconds = null;
  }

  /// Reaktif güncelleme için snapshot kopyası
  DuelPlayer snapshot() => DuelPlayer(
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        score: score,
        correctCount: correctCount,
        totalXpGained: totalXpGained,
        comboCount: comboCount,
        answeredCurrentQuestion: answeredCurrentQuestion,
        selectedOptionIndex: selectedOptionIndex,
        answerTimeSeconds: answerTimeSeconds,
        avatarColor: avatarColor,
      );

  /// Firestore'a yazarken kullanılır
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'score': score,
        'correctCount': correctCount,
        'totalXpGained': totalXpGained,
        'comboCount': comboCount,
      };

  /// Firestore'dan okurken kullanılır
  factory DuelPlayer.fromFirestore(Map<String, dynamic> data) => DuelPlayer(
        userId: data['userId'] ?? '',
        username: data['username'] ?? data['displayName'] ?? 'Player',
        avatarUrl: data['avatarUrl'] ??
            data['photoUrl'] ??
            data['duelAvatar'] ??
            data['photoURL'],
        score: data['score'] ?? 0,
        correctCount: data['correctCount'] ?? 0,
        totalXpGained: data['totalXpGained'] ?? 0,
        comboCount: data['comboCount'] ?? 0,
      );
}
