import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/private_room_controller.dart';
import 'package:interview_project/pages/duello/widgets/duel_category_card.dart';
import 'package:interview_project/utils/duel_category_style.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ===============================================================
/// 🧠 LOBBY CREATE VIEW
/// ===============================================================
///
/// ✔ Inline category selector (modal yerine)
/// ✔ Animated PageView
/// ✔ Create room button
/// ✔ CENTERED LAYOUT (üst & alt sabit, orta tam ortada)
///
class LobbyCreateView extends StatelessWidget {
  final PrivateRoomController controller;

  const LobbyCreateView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(
      viewportFraction: 0.5,
    );

    return Column(
      children: [
        /// ===========================================================
        /// 🎯 CENTER AREA (TITLE + CATEGORY)
        /// ===========================================================
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔥 ÜST BOŞLUK (kontrollü)
              const SizedBox(height: AppSpacing.md),

              /// 🧠 HEADER (FLOW EXPLANATION)

              Obx(() {
                return Transform.scale(
                  scale: controller.lockScale.value,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.lg),

              Text(
                "Create a Private Room",
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 22,
                  color: AppColors.textLightPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                "Invite friends and start a custom duel.",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textLightPrimary.withOpacity(0.65),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl + AppSpacing.md),

              /// 🧩 STEP TITLE
              Text(
                "Select Category",
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: 16,
                  color: AppColors.textLightPrimary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              /// CATEGORY SLIDER
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.macroCategories.length,
                  onPageChanged: controller.selectCategory,
                  itemBuilder: (context, index) {
                    final title = controller.macroCategories[index];
                    final color = DuelCategoryStyle.getColor(title);

                    return Obx(() {
                      final isSelected =
                          controller.selectedIndex.value == index;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// CATEGORY TITLE
                          AnimatedOpacity(
                            duration: AppDurations.normal,
                            opacity: isSelected ? 1 : 0.4,
                            child: Text(
                              title,
                              style: AppTextStyles.bodyStrong.copyWith(
                                fontSize: 16,
                                color: AppColors.textLightPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          /// CARD
                          AnimatedScale(
                            duration: AppDurations.normal,
                            scale: isSelected ? 1.0 : 0.85,
                            child: DuelCategoryCard(
                              title: title,
                              color: color,
                              isSelected: isSelected,
                            ),
                          ),
                        ],
                      );
                    });
                  },
                ),
              ),

              /// 🔥 ALT BOŞLUĞU ESNEK YAP
              const Spacer(),
            ],
          ),
        ),

        /// ===========================================================
        /// 🔘 CREATE BUTTON (FIXED BOTTOM)
        /// ===========================================================
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTapDown: (_) => controller.isCreating.value = true,
            onTapUp: (_) => controller.isCreating.value = false,
            onTapCancel: () => controller.isCreating.value = false,
            onTap: controller.isCreating.value
                ? null
                : () => controller.createRoom(),
            child: Obx(() {
              final pressed = controller.isCreating.value;

              return AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: pressed ? 0.96 : 1.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: pressed ? 0.85 : 1.0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: controller.isCreating.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Create Room",
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
