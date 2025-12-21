// lib/widgets/question_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import '../models/question.dart';

import '../pages/library/controllers/library_controller.dart';
import '../pages/library/widgets/confirm_remove_dialog.dart';
import '../pages/library/widgets/confirm_remove_from_collection_dialog.dart';

/// Soru kartı widget'ı.
/// - Kartın tamamına basınca [onTap] tetiklenir.
/// - Sağ üst köşedeki kaydetme ikonuna basınca [onSaveTap] tetiklenir.
/// - [isSaved] true olduğunda ikon dolu görünür.
///
/// Bu tasarım:
/// - Uygulamanın AppColors / AppTextStyles / AppSpacing sistemine uygun.
/// - Apple / Airbnb tarzı hafif shadow + clean card yapısı kullanır.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.onSaveTap,
    this.isSaved = false,
    this.isSelected = false,
    this.collectionId,
  });

  final Question question;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;
  final bool isSaved;
  final bool isSelected;
  final String? collectionId;

  @override
  Widget build(BuildContext context) {
    // ===================== MULTI-SELECT DURUMU =====================
    final c = Get.find<LibraryController>();
    final bool isSelecting = c.isSelecting.value;
    final bool isSelected = c.selectedQuestionIds.contains(question.id);

// Kart görünümü: seçiliyse mavi border + soft glow
    final Color cardBg = AppColors.surface;
    final BoxDecoration decoration = BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 2 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 14,
                spreadRadius: 1,
              )
            ]
          : AppShadows.medium,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs / 3,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            if (c.isSelecting.value) {
              c.toggleSelect(question.id);
            } else {
              onTap?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              // 🔥 Seçili görünüm – mavi border
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
              borderRadius: BorderRadius.circular(16),
              // 🔥 Glow efekti (isteğe bağlı)
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.18),
                        blurRadius: 16,
                        spreadRadius: 1,
                      )
                    ]
                  : AppShadows.medium,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol taraf: başlık, difficulty chip, topic vs.
                Expanded(
                  child: _CardBody(question: question),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Sağ üst: kaydetme (bookmark) ikonu
                _SaveIconButton(
                  questionId: question.id,
                  isSaved: isSaved,
                  onTap: onSaveTap,
                  collectionId: collectionId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartın içerik kısmı.
/// Başlık, zorluk etiketi, kategori vb. burada çiziliyor.
class _CardBody extends StatelessWidget {
  const _CardBody({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================
        //  Başlık
        // ===============================
        Text(
          question.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyStrong.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // ===============================
        //  Difficulty chip + Topic
        // ===============================
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (question.difficulty != null)
              _DifficultyPill(difficulty: question.difficulty!),

            if (question.difficulty != null)
              const SizedBox(width: AppSpacing.sm),

            // Topic / kategori (örn: "C / C++")
            if (question.topic != null && question.topic!.isNotEmpty)
              Text(
                question.topic!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),

        // İleride istersen description veya tagler için
        // buraya ek alanlar (tags row vs.) açabiliriz.
      ],
    );
  }
}

/// Sağ üstteki kaydetme (bookmark) ikonunu çizen widget.
class _SaveIconButton extends StatelessWidget {
  const _SaveIconButton({
    required this.questionId,
    required this.isSaved,
    required this.onTap,
    this.collectionId,
  });

  final String questionId;
  final String? collectionId;


  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () async {
          final c = Get.find<LibraryController>();

          // MULTI SELECT
          if (c.isSelecting.value) {
            c.toggleSelect(questionId);
            return;
          }

          // --- ZATEN KAYITLI İSE ---
          if (isSaved) {

            // ⭐ Case 1: All tab / practice → full remove
            if (collectionId == null) {
              Get.dialog<bool>(
                const ConfirmRemoveDialog(),
                barrierDismissible: true,
              ).then((ok) async {
                if (ok == true) {
                  await c.removeQuestionEverywhere(questionId);
                }
              });
              return;
            }

            // ⭐ Case 2: Collections tab → remove only from this collection
            Get.dialog<bool>(
              ConfirmRemoveFromThisCollectionDialog(),  // bu dialogu az sonra yazıyoruz
              barrierDismissible: true,
            ).then((ok) async {
              if (ok == true) {
                await c.removeFromCollection(collectionId!, questionId);
              }
            });

            return;
          }

          // --- ZATEN KAYITLI DEĞİLSE → normal flow ---
          c.openSaveSheetFor(questionId);
        },
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
          size: 20,
          color: isSaved ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Difficulty için küçük, renkli bir pill / chip.
///
/// Örnek:
///  [ EASY ]  [ MEDIUM ]  [ HARD ]
class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final Color color = _difficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        _difficultyLabel(difficulty),
        style: AppTextStyles.chip.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Difficulty → UI renk map'i
  Color _difficultyColor(Difficulty d) {
    final name = d.name.toLowerCase();
    if (name.contains('easy') && !name.contains('hard')) {
      return AppColors.difficultyEasy;
    }
    if (name.contains('easy') && name.contains('medium')) {
      return AppColors.difficultyEasyMedium;
    }
    if (name.contains('medium') &&
        !name.contains('easy') &&
        !name.contains('hard')) {
      return AppColors.difficultyMedium;
    }
    if (name.contains('medium') && name.contains('hard')) {
      return AppColors.difficultyMediumHard;
    }
    if (name.contains('hard') && !name.contains('easy')) {
      return AppColors.difficultyHard;
    }
    // Fallback
    return AppColors.primary;
  }

  /// Enum ismini kullanıcı dostu etikete çevirir.
  /// Örn:
  ///  easy_medium → EASY MEDIUM
  String _difficultyLabel(Difficulty d) {
    return d.name.toUpperCase().replaceAll('_', ' ');
  }
}
