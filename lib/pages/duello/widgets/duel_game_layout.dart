import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/utils/duel_category_style.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DuelGameLayout extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final String category;
  final int remainingSeconds;
  final Widget child;

  const DuelGameLayout({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.category,
    required this.remainingSeconds,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        totalQuestions == 0 ? 0 : (currentQuestionIndex + 1) / totalQuestions;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // =============================
              // TOP BAR
              // =============================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Question Counter
                  SizedBox(
                    width: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.listBullets(PhosphorIconsStyle.bold),
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${currentQuestionIndex + 1}/$totalQuestions",
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Card (hazır widget)
                  Expanded(
                    child: Center(
                      child: DuelCategoryCard(
                        title: category,
                        color: DuelCategoryStyle.getColor(category),
                        isSelected: true,
                        size: 60,
                      ),
                    ),
                  ),

                  // Timer
                  SizedBox(
                    width: 90,
                    child: Center(
                      child: _PulsingTimer(
                        remainingSeconds: remainingSeconds,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // =============================
              // QUESTION AREA
              // =============================
              Expanded(child: child),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingTimer extends StatefulWidget {
  final int remainingSeconds;

  const _PulsingTimer({required this.remainingSeconds});

  @override
  State<_PulsingTimer> createState() => _PulsingTimerState();
}

class _PulsingTimerState extends State<_PulsingTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.9,
      upperBound: 1.15,
    );

    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.remainingSeconds > 3) {
      _controller.stop();
      _controller.value = 1.0;
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDanger = widget.remainingSeconds <= 3;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: isDanger ? _controller.value : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: isDanger
                    ? Offset(
                        (_controller.value - 1) * 10,
                        0,
                      )
                    : Offset.zero,
                child: Icon(
                  PhosphorIcons.timer(PhosphorIconsStyle.bold),
                  size: 18,
                  color: isDanger ? Colors.redAccent : Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "${widget.remainingSeconds}s",
                style: AppTextStyles.bodyStrong.copyWith(
                  color: isDanger ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
