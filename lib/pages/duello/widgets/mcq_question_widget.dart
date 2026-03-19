import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_enums.dart';
import 'package:interview_project/models/duel_player.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/duello/controllers/duel_game_controller.dart';
import 'package:interview_project/pages/duello/widgets/player_mini_avatar.dart';

import '../../../utils/code_language_utils.dart';
import '../../question_types/widgets/read_only_code_block.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DESCRIPTION
                if ((widget.question.description ?? '').isNotEmpty)
                  Text(
                    widget.question.description!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),

                /// CODE BLOCK (🔥 EN ÖNEMLİ KISIM)
                if ((widget.question.codeTemplate ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  ReadOnlyCodeBlock(
                    code: widget.question.codeTemplate!,
                    language: CodeLanguageUtils.resolveLanguageFromTopic(
                      widget.question.topic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── ŞIKLAR ──
          Column(
            children: List.generate(options.length, (index) {
              final isSelected = _localSelectedIndex == index;
              final isCorrect = _isCorrectOption(index);

              // Renkler sadece reveal'da değişir
              /// ✅ Default state artık net ve okunur
              Color bgColor =
                  AppColors.surface.withOpacity(0.95); // daha net zemin
              Color borderColor = Colors.white.withOpacity(0.6); // hafif border
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
                // 🔥 Seçildiğinde hafif koyulaşma + net border
                bgColor = AppColors.primarySoftBackground.withOpacity(0.85);
                borderColor = AppColors.primary.withOpacity(0.7);
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
                                color: isReveal
                                    ? (isCorrect
                                        ? AppColors.success
                                        : (isSelected
                                            ? AppColors.error
                                            : AppColors.paleSlate
                                                .withOpacity(0.45)))
                                    : (isSelected
                                        ? AppColors.primarySoftBackground
                                        : AppColors.paleSlate
                                            .withOpacity(0.45)),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isReveal
                                      ? Colors.white
                                      : (isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary),
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
                          ],
                        ),
                      ),
                    ),

                    // ── AVATAR OVERLAY — reveal fazında seçilen şıkkın üstünde ──
                    if (isReveal && playersOnThisOption.isNotEmpty)
                      Positioned(
                        top: -12,
                        right: -4,
                        child: Container(
                          padding: EdgeInsets.zero,
                          decoration: const BoxDecoration(),
                          child: Wrap(
                            spacing: -8,
                            children: playersOnThisOption
                                .map((p) => PlayerMiniAvatar(
                                      username: p.username,
                                      avatarAsset: p.avatarUrl,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
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
