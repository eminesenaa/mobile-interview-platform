import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final labelStyle =
        theme.textTheme.labelSmall?.copyWith(color: theme.hintColor);

    // 🔹 Bugün ilk olacak şekilde sıralama
    final today = DateTime.now().weekday; // 1=Mon ... 7=Sun
    final orderedDays = List.generate(7, (i) {
      // i=0 → bugün, i=1 → dün ...
      final dayIndex = ((today - i - 1) % 7) + 1;
      final key = '$dayIndex';
      return history[key] ?? false;
    });

    return Card(
      elevation: 0.6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // LEFT: fire icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(.95),
                      theme.colorScheme.primary.withOpacity(.65),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                    Positioned(
                      bottom: -2,
                      child: Text(
                        '$currentStreak',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // RIGHT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak day streak',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Longest: $longestStreak days',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 10),

                    // 🔥 Bugün ilk (solda)
                    Row(
                      children: List.generate(7, (i) {
                        final done = orderedDays[i];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 6 ? 0 : 6.0),
                            child: _DayDot(
                              filled: done,
                              isToday: i == 0, // bugün solda
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),

                    // 🔹 Label sırası: Today, -1d, -2d ...
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 6 ? 0 : 6.0),
                            child: Text(
                              _weekdayLabelFor(i),
                              textAlign: TextAlign.center,
                              style: labelStyle,
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

  /// 🔹 i=0 → bugün, i=1 → dün ... haftanın ismini döndürür
  static String _weekdayLabelFor(int offset) {
    final now = DateTime.now().subtract(Duration(days: offset));
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[now.weekday - 1];
  }
}

class _DayDot extends StatelessWidget {
  final bool filled;
  final bool isToday;
  const _DayDot({required this.filled, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? base.withOpacity(.95) : Colors.transparent,
        border: Border.all(
          width: 2.0,
          color: filled
              ? base.withOpacity(.95)
              : theme.colorScheme.outline.withOpacity(.35),
        ),
        boxShadow: isToday && filled
            ? [
                BoxShadow(
                  color: base.withOpacity(.45),
                  blurRadius: 8.0,
                )
              ]
            : null,
      ),
      child: filled
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
