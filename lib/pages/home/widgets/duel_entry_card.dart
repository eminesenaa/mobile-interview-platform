// ===================== File: lib/pages/home/widgets/duel_entry_card.dart =====================
// Purpose: Home sayfasında Duel modülüne giriş kartı.
// Tasarım: Gradient arkaplan, solda metin, sağda büyük SVG ikon.
// ============================================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';

class DuelEntryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const DuelEntryCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        boxShadow: AppShadows.medium,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                /// LEFT SIDE – TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Başlık (oyunsu ama kontrollü)
                      Text(
                        "Duel Arena",
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 22,               // biraz küçülttük
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      /// Açıklama
                      Text(
                        "Challenge other players in real-time and prove your skills.",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textLightPrimary.withOpacity(0.9),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      /// Mini CTA
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Start Duel",
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: AppColors.textLightPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// RIGHT SIDE – SVG ICON
                SvgPicture.asset(
                  "assets/images/duel_sword.svg",
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}