import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class RdOverallScoreSection extends StatelessWidget {
  final int score;
  final int rank;
  final int total;

  const RdOverallScoreSection({
    super.key,
    required this.score,
    required this.rank,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OVERALL SCORE",
          style: AppTextStyles.label.copyWith(fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            /// 🔥 PROGRESS CIRCLE
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// Background circle
                  CustomPaint(
                    size: const Size(90, 90),
                    painter: _CirclePainter(
                      progress: 1,
                      color: AppColors.border.withOpacity(0.25),
                    ),
                  ),

                  /// Foreground progress
                  CustomPaint(
                    size: const Size(90, 90),
                    painter: _CirclePainter(
                      progress: percent,
                      color: AppColors.success,
                    ),
                  ),

                  /// 🔥 CENTER TEXT
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$score",
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 22, // 🔥 büyük
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

            /// RIGHT TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPerformanceText(score),
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Top $rank of $total candidates in this interview round.",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔥 Dynamic performance text
  String _getPerformanceText(int score) {
    if (score >= 90) return "Excellent Performance";
    if (score >= 75) return "Strong Performance";
    if (score >= 60) return "Good Performance";
    if (score >= 40) return "Average Performance";
    return "Needs Improvement";
  }
}

/// ===============================================================
/// 🔥 CIRCLE PAINTER
/// ===============================================================
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 8.0;

    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -3.14 / 2;
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
