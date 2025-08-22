import 'package:flutter/material.dart';

/// StreakCard
/// - Solda alev ikonu ve büyük streak sayacı
/// - Sağda başlık ve son 7 gün için dolu/boş noktalar + gün etiketleri
/// - Dışarıdan streakCount ve last7Days (7 elemanlı bool) alır.
///   last7Days: [Mon..Sun] değil; "son 7 gün, bugün en sağda" sırasındadır.
///
/// Not: İleride UserController geldikten sonra:
///   final user = Get.find<UserController>().currentUser.value;
///   StreakCard(streakCount: user.streak.streakCount,
///              last7Days: user.streak.streakHistory.sublist(23, 30));
class StreakCard extends StatelessWidget {
  final int streakCount;
  /// Son 7 gün (bool), uzunluk 7 olmalı. true = check-in yapılmış.
  final List<bool> last7Days;
  final VoidCallback? onTap; // istersen karta basınca aksiyon

  const StreakCard({
    super.key,
    required this.streakCount,
    required this.last7Days,
    this.onTap,
  }) : assert(last7Days.length == 7, 'last7Days must be length 7');

  /// Hızlı önizleme için mock ctor
  const StreakCard.preview({super.key})
      : streakCount = 12,
        last7Days = const [true, true, true, true, true, false, false],
        onTap = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final labelStyle =
    theme.textTheme.labelSmall?.copyWith(color: theme.hintColor);

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
              // LEFT: fire icon + count overlay
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
                      bottom: -2, // sayı biraz aşağıda dursun istersen center yapabilirsin
                      child: Text(
                        '$streakCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white, // direkt ikonun üstüne
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // RIGHT: title + weekly dots + labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakCount days streak, you’re on fire!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Every day counts!',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(7, (i) {
                        final done = last7Days[i];
                        return Expanded(
                          child: Padding(
                            padding:
                            EdgeInsets.only(right: i == 6 ? 0 : 6.0),
                            child: _DayDot(
                              filled: done,
                              isToday: i == 6, // en sağ: bugün
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    // hafta etiketleri (Mon..Sun) — bugün en sağda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekdayLabels().map((e) {
                        return Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(right: 6.0),
                            child: Text(e,
                                textAlign: TextAlign.center,
                                style: labelStyle),
                          ),
                        );
                      }).toList()
                        ..removeLast(), // son elemana fazladan padding gitmesin
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

  /// Mon..Sun (bugün en sağda olacak şekilde)
  List<String> _weekdayLabels() {
    final now = DateTime.now();
    // Son 6 gün + bugün (soldan sağa)
    final days = List<DateTime>.generate(
        7, (i) => now.subtract(Duration(days: 6 - i)));
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => names[d.weekday - 1]).toList();
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
          ? const Icon(Icons.check,
          size: 16, color: Colors.white) // içi tik işareti
          : null,
    );
  }
}

