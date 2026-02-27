import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // UID kontrolü için eklendi
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/models/duel_enums.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';

class MCQQuestionWidget extends StatelessWidget {
  final Question question;
  final DuelGameController controller;
  final DuelQuestionPhase phase;

  const MCQQuestionWidget({
    super.key,
    required this.question,
    required this.controller,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================
        // QUESTION CARD (Beyaz Kutu)
        // =========================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.medium,
          ),
          child: Text(
            // 🔥 DÜZELTME: 'title' yerine veritabanındaki 'text' alanını (description) gösteriyoruz
            question.description ?? question.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title
                .copyWith(fontSize: 18), // Soru metni için daha uygun stil
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // =========================
        // OPTIONS (Şıklar)
        // =========================
        Expanded(
          child: ListView.builder(
            // Soru şıkları boşsa çökmemesi için koruma
            itemCount: question.options?.length ?? 0,
            itemBuilder: (context, index) {
              return _buildOption(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, int index) {
    final match = controller.match.value!;

    // 🔥 DÜZELTME: 'local_user' statik ID'si yerine gerçek Auth UID kullanılarak "No element" hatası önlenir
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final localPlayer = match.players.firstWhere(
      (p) => p.userId == currentUserId,
      orElse: () =>
          match.players.first, // Fallback: Hata yerine ilk oyuncuyu baz al
    );

    final selected = localPlayer.selectedOptionIndex == index;

    // Veritabanındaki correctAnswer hem "0" (index) hem de metin ("SYN") olabilir
    final int? correctAnswerIndex =
        _parseCorrectAnswer(question.correctAnswer, question.options);

    Color background = AppColors.surface;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.textPrimary;

    if (phase == DuelQuestionPhase.reveal) {
      if (index == correctAnswerIndex) {
        background = AppColors.primarySoftBackground;
        borderColor = AppColors.success;
        textColor = AppColors.success;
      } else if (selected) {
        background = AppColors.surfaceMuted;
        borderColor = AppColors.error;
        textColor = AppColors.error;
      }
    } else if (selected) {
      background = AppColors.primarySoftBackground;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: phase == DuelQuestionPhase.active
          ? () => controller.selectOption(index)
          : null,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            question.options![index],
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyStrong.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // Doğru cevabı hem index hem metin olarak kontrol eden yardımcı metod
  int? _parseCorrectAnswer(String? correct, List<String>? options) {
    if (correct == null || options == null) return null;

    // 1. Önce index mi diye bak (Örn: "0", "1")
    final idx = int.tryParse(correct);
    if (idx != null && idx < options.length) return idx;

    // 2. Metin eşleşmesi mi diye bak (Örn: "Always prints 2000")
    final cleanCorrect = correct.trim().toLowerCase();
    for (int i = 0; i < options.length; i++) {
      if (options[i].trim().toLowerCase() == cleanCorrect) return i;
    }
    return null;
  }
}
