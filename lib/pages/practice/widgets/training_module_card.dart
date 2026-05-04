// ===================== File: training_module_card.dart =====================
// Purpose:
// Redesigned Training Module Card (UI ONLY)
//
// FIXES:
// - Removed right arrow
// - Fixed RenderFlex overflow
// - Improved vertical layout stability
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/training_module.dart';

class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;
  final double? progress;
  final VoidCallback? onTap;

  const TrainingModuleCard({
    super.key,
    required this.module,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 GRADIENT COLORS (edit burayı)
    final gradients = [
      // Turquoise → daha açık cyan
      const [AppColors.topicBrightTeal, Color(0xFF48CAE4)],

      // Cinnabar (kırmızı) → daha soft coral
      const [AppColors.cinnabar, Color(0xFFFF7F7A)],

      // Celadon (yeşil) → mint tonu
      const [AppColors.accentCeladon, Color(0xFFCFF4D2)],

      // Honey Bronze (sarı/turuncu) → açık amber
      const [AppColors.honeyBronze, Color(0xFFFFD166)],

      // Dark Magenta → mor-pembe geçiş
      const [AppColors.darkMagenta, Color(0xFFB65FCF)],

      // Pink Carnation → soft pink
      const [AppColors.pinkCarnation, Color(0xFFFFB3E6)],
    ];

    final colorIndex = module.id.hashCode.abs() % gradients.length;

    final gradient = gradients[colorIndex];

    final effectiveProgress = (progress ?? 0).clamp(0.0, 1.0).toDouble();

    return AspectRatio(
      aspectRatio: 2.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.medium,
            gradient: module.coverImageUrl == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  )
                : null,
            image: module.coverImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(module.coverImageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.45),
                      BlendMode.srcOver,
                    ),
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              children: [
                // 🔵 decorative circles
                Positioned(top: -30, right: -30, child: _circle(120)),
                Positioned(bottom: -20, left: -20, child: _circle(80)),

                // ================= CONTENT =================
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 LABEL
                      _FormatChip(format: module.format),

                      const SizedBox(height: AppSpacing.sm),

                      // 🔹 TITLE + DESCRIPTION (EXPANDED = overflow fix)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.textLightPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 2),

                            // 🔥 CRITICAL FIX
                            Flexible(
                              child: Text(
                                module.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textLightPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // 🔹 FOOTER
                      Text(
                        '${module.totalQuestions} questions',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textLightPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ================= FORMAT CHIP =================
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
        color: Colors.white.withOpacity(0.15),
      ),
      child: Text(
        _label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textLightPrimary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
