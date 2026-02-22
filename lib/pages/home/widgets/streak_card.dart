import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

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

  const StreakCard.preview({super.key})
      : currentStreak = 12,
        longestStreak = 18,
        history = const {
          '1': true,
          '2': true,
          '3': true,
          '4': true,
          '5': true,
          '6': false,
          '7': false,
        },
        onTap = null;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.textMuted,
    );

    final today = DateTime.now();

    late final List<bool> orderedDays;
    late final List<String> weekdayLabels;

    final bool showWeeklyView = currentStreak >= 7;

    if (showWeeklyView) {
      orderedDays = [];
      weekdayLabels = [];

      final today = DateTime.now();
      const daysInWindow = 7;

      // 🔁 UI resetli streak başlangıcı
      final uiStart =
          today.subtract(Duration(days: (currentStreak - 1) % daysInWindow));

      // 🔥 resetten sonra kaç gün dolu olmalı
      final uiProgress = ((currentStreak - 1) % daysInWindow) + 1;

      for (int i = 0; i < daysInWindow; i++) {
        final date = uiStart.add(Duration(days: i));

        final isFilled = i < uiProgress;

        orderedDays.add(isFilled);
        weekdayLabels.add(_getWeekdayShort(date.weekday));
      }
    } else {
      // 0 streak → tüm noktalar boş, etiketler bugün → ileri
      if (currentStreak <= 0) {
        orderedDays = List<bool>.filled(7, false);
        weekdayLabels = List<String>.generate(7, (i) => _weekdayLabelFor(i));
      } else {
        // 1–6 streak
        final int startOffset = currentStreak - 1;

        orderedDays =
            List<bool>.generate(7, (i) => i < currentStreak); // İlk N dolu

        weekdayLabels = List<String>.generate(
          7,
          (i) => _weekdayLabelFor(i - startOffset),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primarySoftBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildStreakIcon(currentStreak),
                const SizedBox(width: AppSpacing.md),

                /// RIGHT SIDE
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

                      /// DAY DOTS
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

                      /// DAY LABELS
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
      ),
    );
  }

  Widget _buildStreakIcon(int streak) {
    return Container(
      width: 64,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryAccent,
          ],
        ),
      ),
      child: Stack(
        alignment: const Alignment(0, -0.15),
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.26),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/images/streak_fire.svg',
            width: 36,
            height: 36,
          ),
          Positioned(
            bottom: 2,
            child: Text(
              '$streak',
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
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
        color: filled
            ? AppColors.primary
            : AppColors.surface.withValues(alpha: 0.4),
        border: Border.all(
          width: 1.6,
          color: filled
              ? AppColors.primary
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: isToday && filled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8.0,
                ),
              ]
            : null,
      ),
      child: filled
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
