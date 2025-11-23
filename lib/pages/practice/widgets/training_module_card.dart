// ===================== File: lib/pages/practice/widgets/training_module_card.dart =====================

import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/training_module.dart';

/// Practice sayfasının en üstündeki training plan kartı.
/// Arkaplanda gradient / görsel, üstte format chip'i,
/// ortada başlık + kısa açıklama, altta toplam soru + mini progress bar.
class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;

  /// 0.0 – 1.0 arası ilerleme. Şimdilik null bırakılabilir.
  final double? progress;

  /// Kart tıklanınca çalışacak callback.
  final VoidCallback? onTap;

  const TrainingModuleCard({
    super.key,
    required this.module,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress =
    (progress ?? 0).clamp(0.0, 1.0).toDouble(); // 0–1 aralığına sabitle

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.medium,
          color: AppColors.primary,
          image: module.coverImageUrl != null
              ? DecorationImage(
            image: NetworkImage(module.coverImageUrl!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35),
              BlendMode.srcOver,
            ),
          )
              : null,
          // Eğer görsel yoksa gradient kullan.
          gradient: module.coverImageUrl == null
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryAccent,
            ],
          )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Üst kısım: format label
              _FormatChip(format: module.format),

              // Orta kısım: başlık + alt açıklama
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        module.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Alt kısım: toplam soru + progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${module.totalQuestions} questions',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: effectiveProgress,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final TrainingModuleFormat format;

  const _FormatChip({required this.format});

  String get _label {
    switch (format) {
      case TrainingModuleFormat.crashCourse:
        return 'Crash course';
      case TrainingModuleFormat.challenge:
        return 'Challenge';
      case TrainingModuleFormat.interviewPrep:
        return 'Interview prep';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: Colors.black.withOpacity(0.30),
      ),
      child: Text(
        _label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
