// ===================== File: hp_streak_card.dart =====================
// Purpose:
// Ultra clean / flat UI version (no container, floating icon)
// ======================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final Map<String, bool> history;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.history,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.textMuted,
    );

    late final List<bool> orderedDays;
    late final List<String> weekdayLabels;

    final bool showWeeklyView = currentStreak >= 7;

    if (showWeeklyView) {
      orderedDays = [];
      weekdayLabels = [];

      final today = DateTime.now();
      const daysInWindow = 7;

      final uiStart =
          today.subtract(Duration(days: (currentStreak - 1) % daysInWindow));

      final uiProgress = ((currentStreak - 1) % daysInWindow) + 1;

      for (int i = 0; i < daysInWindow; i++) {
        final date = uiStart.add(Duration(days: i));
        orderedDays.add(i < uiProgress);
        weekdayLabels.add(_getWeekdayShort(date.weekday));
      }
    } else {
      if (currentStreak <= 0) {
        orderedDays = List<bool>.filled(7, false);
        weekdayLabels = List<String>.generate(7, (i) => _weekdayLabelFor(i));
      } else {
        final int startOffset = currentStreak - 1;

        orderedDays = List<bool>.generate(7, (i) => i < currentStreak);

        weekdayLabels = List<String>.generate(
          7,
          (i) => _weekdayLabelFor(i - startOffset),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStreakIcon(currentStreak),

              const SizedBox(width: AppSpacing.md),

              // RIGHT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatDays(currentStreak)} streak',
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Longest: ${_formatDays(longestStreak)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // DAY DOTS
                    Row(
                      children: List.generate(7, (i) {
                        final done = orderedDays[i];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 6 ? 0 : 6.0),
                            child: _DayDot(
                              filled: done,
                              isToday: i == 6,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),

                    // DAY LABELS
                    Row(
                      children: List.generate(7, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 6 ? 0 : 6.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                weekdayLabels[i],
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: labelStyle,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FLOATING ICON
  Widget _buildStreakIcon(int streak) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔥 PHOSPHOR FIRE ICON
        Icon(
          PhosphorIcons.fire(PhosphorIconsStyle.fill),
          size: 50,
          color: AppColors.honeyBronze,
        ),

        const SizedBox(height: 6),

        // 🔢 SAYI
        Text(
          '$streak',
          style: AppTextStyles.bodyStrong.copyWith(
            fontSize: 16,
            color: AppColors.honeyBronze,
          ),
        ),
      ],
    );
  }

  String _formatDays(int value) {
    return "$value ${value == 1 ? 'day' : 'days'}";
  }

  static String _weekdayLabelFor(int offset) {
    final now = DateTime.now().add(Duration(days: offset));
    return _getWeekdayShort(now.weekday);
  }

  static String _getWeekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }
}

class _DayDot extends StatelessWidget {
  final bool filled;
  final bool isToday;

  const _DayDot({
    required this.filled,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.honeyBronze : AppColors.surfaceMuted,
        border: Border.all(
          width: 1.4,
          color: filled ? AppColors.honeyBronze : AppColors.border,
        ),
        boxShadow: isToday && filled
            ? [
                BoxShadow(
                  color: AppColors.honeyBronze.withOpacity(0.25),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: filled
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
