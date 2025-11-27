// ===================== File: lib/pages/practice/widgets/daily_challenge_card.dart =====================

import 'package:flutter/material.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';

import 'package:interview_project/models/question.dart';

/// Practice sayfasındaki "Challenge Yourself Today" kartı.
/// Orta / zor günlük meydan okuma sorusunu gösterir.
class DailyChallengeCard extends StatelessWidget {
  final Question question;

  /// Butona basıldığında çalışacak aksiyon (soru çözüm ekranına gitmek için).
  final VoidCallback? onSolveTap;

  const DailyChallengeCard({
    super.key,
    required this.question,
    this.onSolveTap,
  });

  @override
  Widget build(BuildContext context) {
    final dv = _difficultyVisuals(question);
    final metaText = _buildMetaText(question);

    return GestureDetector(
      onTap: onSolveTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================
            // Üst satır: küçük label + difficulty chip
            // =======================
            Row(
              children: [
                Text(
                  'Challenge yourself today',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),

                // ------- DIFFICULTY BADGE -------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    border: Border.all(
                      color: dv.color,
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: dv.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dv.label,
                        style: AppTextStyles.caption.copyWith(
                          color: dv.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // =======================
            // Başlık
            // =======================
            Text(
              question.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // =======================
            // Kısa açıklama
            // =======================
            if (_shortDescription(question).isNotEmpty) ...[
              Text(
                _shortDescription(question),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ] else
              const SizedBox(height: AppSpacing.sm),

            // =======================
            // Meta info + Solve Now
            // =======================
            Row(
              children: [
                Expanded(
                  child: Text(
                    metaText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                  ),
                  onPressed: onSolveTap,
                  child: const Text('Solve Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // Difficulty renk ve label logic — Sadece data taşır!
  // ===========================================================
  _DifficultyVisual _difficultyVisuals(Question q) {
    String raw = '';
    try {
      final dynamic v = (q as dynamic).difficulty;
      if (v != null) raw = v.toString().toUpperCase();
    } catch (_) {}

    final cleaned = raw.replaceAll('DIFFICULTY.', '');

    if (cleaned.contains('HARD')) {
      return _DifficultyVisual(
        label: 'HARD',
        color: AppColors.difficultyHard,
      );
    } else if (cleaned.contains('MEDIUM')) {
      return _DifficultyVisual(
        label: 'MEDIUM',
        color: AppColors.difficultyMedium,
      );
    } else if (cleaned.contains('EASY')) {
      return _DifficultyVisual(
        label: 'EASY',
        color: AppColors.difficultyEasy,
      );
    }

    return _DifficultyVisual(
      label: 'MEDIUM',
      color: AppColors.difficultyMedium,
    );
  }

  // Summary text
  String _shortDescription(Question q) {
    try {
      final dynamic v = (q as dynamic).shortDescription;
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    } catch (_) {}

    try {
      final dynamic v = (q as dynamic).description;
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    } catch (_) {}

    return '';
  }

  // "C++ • Data Structures"
  String _buildMetaText(Question q) {
    String? lang;
    String? topic;

    try {
      final dynamic v = (q as dynamic).language;
      if (v != null && v.toString().trim().isNotEmpty) lang = v.toString();
    } catch (_) {}

    try {
      final dynamic v = (q as dynamic).topic;
      if (v != null && v.toString().trim().isNotEmpty) topic = v.toString();
    } catch (_) {}

    final parts = <String>[];
    if (lang != null) parts.add(lang);
    if (topic != null) parts.add(topic);

    return parts.isEmpty ? '' : parts.join(' • ');
  }
}

/// Sadece DATA taşır — UI çizmez!
/// UI state DailyChallengeCard içinde çiziliyor.
class _DifficultyVisual {
  final String label;
  final Color color;

  _DifficultyVisual({
    required this.label,
    required this.color,
  });
}
