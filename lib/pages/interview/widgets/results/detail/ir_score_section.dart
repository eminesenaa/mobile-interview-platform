// ===================== File: ir_score_section.dart =====================
// Purpose:
// Displays score + interpretation (accepted / rejected)
//
// Notes:
// - Hidden for pending
// - Uses ScoreCircle (REUSE)
// =====================================================================

import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';

class IrOverallScoreSection extends StatelessWidget {
  final int score;
  final int? rank;
  final int? total;
  final String status;

  const IrOverallScoreSection({
    super.key,
    required this.score,
    required this.status,
    this.rank,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score / 100).clamp(0.0, 1.0);

    final isRejected = status == "rejected";

    final color = isRejected ? AppColors.error : AppColors.success;

    return Row(
      children: [
        /// ================= CIRCLE =================
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Background
              CustomPaint(
                size: const Size(90, 90),
                painter: _CirclePainter(
                  progress: 1,
                  color: AppColors.border.withOpacity(0.25),
                ),
              ),

              /// Progress
              CustomPaint(
                size: const Size(90, 90),
                painter: _CirclePainter(
                  progress: percent,
                  color: color,
                ),
              ),

              /// CENTER TEXT
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$score",
                    style: AppTextStyles.headline.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "/100",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.lg),

        /// ================= TEXT =================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getPerformanceText(score),
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: 16,
                  color: isRejected ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (rank != null && total != null)
                Text(
                  "Rank #$rank of $total candidates.",
                  style: AppTextStyles.bodySmall,
                )
              else
                Text(
                  isRejected
                      ? "Your score did not meet the required threshold."
                      : "You performed very well in this interview.",
                  style: AppTextStyles.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPerformanceText(int score) {
    if (score >= 90) return "Excellent Performance";
    if (score >= 75) return "Strong Performance";
    if (score >= 60) return "Good Performance";
    if (score >= 40) return "Average Performance";
    return "Needs Improvement";
  }
}

/// ================= PAINTER =================
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;

    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14 / 2;
    final sweepAngle = 3.14 * 2 * progress;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
