import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_enums.dart';
import 'package:interview_project/models/duel_player.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';

class MCQQuestionWidget extends StatefulWidget {
  final Question question;
  final DuelGameController controller;
  final DuelQuestionPhase phase;
  final List<DuelPlayer> players;

  const MCQQuestionWidget({
    super.key,
    required this.question,
    required this.controller,
    required this.phase,
    required this.players,
  });

  @override
  State<MCQQuestionWidget> createState() => _MCQQuestionWidgetState();
}

class _MCQQuestionWidgetState extends State<MCQQuestionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  int? _localSelectedIndex;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MCQQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Yeni soru → sıfırla
    if (oldWidget.question.id != widget.question.id) {
      setState(() => _localSelectedIndex = null);
      _shakeController.reset();
    }

    // Reveal geldi + yanlış cevap → shake
    if (oldWidget.phase != DuelQuestionPhase.reveal &&
        widget.phase == DuelQuestionPhase.reveal &&
        _localSelectedIndex != null &&
        !_isCorrectOption(_localSelectedIndex!)) {
      _shakeController.forward(from: 0);
    }
  }

  bool _isCorrectOption(int index) {
    final q = widget.question;
    if (q.correctAnswer == null || q.options == null) return false;
    final correctStr = q.correctAnswer!.trim();
    final correctIndex = int.tryParse(correctStr);
    if (correctIndex != null) return index == correctIndex;
    if (index < q.options!.length) {
      return q.options![index].trim() == correctStr;
    }
    return false;
  }

  void _onTap(int index) {
    if (widget.phase != DuelQuestionPhase.active) return;
    if (_localSelectedIndex != null) return;
    setState(() => _localSelectedIndex = index);
    widget.controller.selectOption(index);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options ?? [];
    final isReveal = widget.phase == DuelQuestionPhase.reveal;
    final combo = widget.controller.comboCount.value;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SORU METNİ ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.low,
            ),
            child: Text(
              widget.question.description ?? widget.question.title,
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── ŞIKLAR ──
          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (context, child) {
              final t = _shakeAnim.value;
              final offset = t < 0.5 ? -10 * t * 2 : 10 * (t - 0.5) * 2;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Column(
              children: List.generate(options.length, (index) {
                final isSelected = _localSelectedIndex == index;
                final isCorrect = _isCorrectOption(index);

                // Renkler sadece reveal'da değişir
                Color bgColor = AppColors.surface;
                Color borderColor = AppColors.border;
                Color textColor = AppColors.textPrimary;

                if (isReveal) {
                  if (isCorrect) {
                    bgColor = const Color(0xFFE8F5E9);
                    borderColor = AppColors.success;
                    textColor = AppColors.success;
                  } else if (isSelected) {
                    bgColor = const Color(0xFFFFEBEE);
                    borderColor = Colors.red;
                    textColor = Colors.red;
                  }
                } else if (isSelected) {
                  // Active fazda sadece hafif highlight — renk değişimi yok
                  bgColor = AppColors.primarySoftBackground;
                  borderColor = AppColors.primary;
                  textColor = AppColors.textPrimary;
                }

                // Reveal'da bu şıkkı seçen oyuncuları bul
                final playersOnThisOption = isReveal
                    ? widget.players
                        .where((p) => p.selectedOptionIndex == index)
                        .toList()
                    : <DuelPlayer>[];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── ŞIK BUTONU ──
                      GestureDetector(
                        onTap: () => _onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: borderColor, width: 1.5),
                            boxShadow: AppShadows.low,
                          ),
                          child: Row(
                            children: [
                              // Harf balonu
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: borderColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: borderColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: AppTextStyles.body.copyWith(
                                    color: textColor,
                                    fontWeight:
                                        isSelected || (isReveal && isCorrect)
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              // Doğru/yanlış ikonu — sadece reveal + seçiliyse
                              if (isReveal && isSelected)
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: isCorrect
                                      ? AppColors.success
                                      : Colors.red,
                                  size: 20,
                                ),
                              // Doğru şık işareti — seçilmese bile reveal'da
                              if (isReveal && isCorrect && !isSelected)
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // ── AVATAR OVERLAY — reveal fazında seçilen şıkkın üstünde ──
                      if (isReveal && playersOnThisOption.isNotEmpty)
                        Positioned(
                          top: -10,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Wrap(
                              spacing: -6,
                              children: playersOnThisOption
                                  .map((p) => _MiniAvatar(player: p))
                                  .toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // ── FEEDBACK BANNER (sadece reveal) ──
          if (isReveal && _localSelectedIndex != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: _FeedbackBanner(
                isCorrect: _isCorrectOption(_localSelectedIndex!),
                combo: combo,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// MİNİ AVATAR
// ─────────────────────────────────────────
class _MiniAvatar extends StatelessWidget {
  final DuelPlayer player;
  const _MiniAvatar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: player.avatarColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        avatarInitial(player.username),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// COMBO BANNER
// ─────────────────────────────────────────
class _ComboBanner extends StatelessWidget {
  final int combo;
  const _ComboBanner({required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF9500)]),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$combo× Combo!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// FEEDBACK BANNER
// ─────────────────────────────────────────
class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final int combo;
  const _FeedbackBanner({required this.isCorrect, required this.combo});

  @override
  Widget build(BuildContext context) {
    final text = isCorrect
        ? (combo >= 3
            ? '🔥 On fire!'
            : combo >= 2
                ? '⚡ Nice combo!'
                : '✅ Correct!')
        : '❌ Wrong!';
    final color = isCorrect ? AppColors.success : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
