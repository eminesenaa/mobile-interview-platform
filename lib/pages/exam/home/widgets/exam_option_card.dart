// ===================== File: exam_option_card.dart =====================
// Purpose:
// Redesigned Exam Option Card (with decorative background)
//
// Improvements:
// - Decorative soft circles (like duel card)
// - Clean gradient
// - Horizontal layout preserved
// - Premium but not noisy
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class ExamOptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ExamOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<ExamOptionCard> createState() => _ExamOptionCardState();
}

class _ExamOptionCardState extends State<ExamOptionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.topicBrightTeal,
                AppColors.topicTurquoise,
                AppColors.topicFrostedBlue,
              ],
            ),
            boxShadow: AppShadows.low,
          ),

          // 🔥 CLIP for decorations
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              children: [
                // ================= DECORATIVE SHAPES =================
                Positioned(
                  top: -30,
                  right: -30,
                  child: _circle(100),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: _circle(70),
                ),

                // ================= CONTENT =================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xxl + AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ================= ICON =================
                      Icon(
                        widget.icon,
                        size: 26,
                        color: AppColors.textLightPrimary,
                      ),

                      const SizedBox(width: AppSpacing.md),

                      // ================= TEXT =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.textLightPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textLightPrimary.withOpacity(0.85),
                              ),
                            ),
                          ],
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

  // ================= DECORATIVE CIRCLE =================
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
