import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';

import '../../../models/duel_config.dart';
import '../../../models/duel_enums.dart';
import '../../../utils/duel_category_style.dart';
import 'duel_category_card.dart';
import '../controllers/duel_config_controller.dart';
import '../matchmaking_page.dart';

/// ===============================================================
/// DuelConfigModal
/// ---------------------------------------------------------------
/// Category selection modal for starting a duel.
///
/// Responsibilities:
/// - Allows user to pick a category
/// - Creates duel configuration
/// - Navigates to matchmaking
///
/// Notes:
/// - Uses blur background + centered modal
/// - Gradient animated CTA button
/// - Fully aligned with design system (spacing, colors, typography)
/// ===============================================================
class DuelConfigModal extends StatefulWidget {
  final String modeTitle;

  const DuelConfigModal({super.key, required this.modeTitle});

  @override
  State<DuelConfigModal> createState() => _DuelConfigModalState();
}

class _DuelConfigModalState extends State<DuelConfigModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();

    /// Controls animated gradient movement
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuelConfigController(widget.modeTitle));

    final pageController = PageController(
      viewportFraction: 0.48,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// =======================
          /// Blur Background Layer
          /// =======================
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          /// =======================
          /// Center Modal
          /// =======================
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// =======================
                  /// HEADER (TITLE + CLOSE)
                  /// =======================
                  Row(
                    children: [
                      const SizedBox(width: AppSpacing.xl),

                      /// Title (centered)
                      Expanded(
                        child: Center(
                          child: Text(
                            "Select Category",
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),

                      /// Close Button (X)
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            PhosphorIcons.x(PhosphorIconsStyle.bold),
                            color: AppColors.textPrimary,
                            size: AppIconSizes.md,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// =======================
                  /// CATEGORY SLIDER
                  /// =======================
                  SizedBox(
                    height: 170,
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
                              /// Category Title
                              Text(
                                title,
                                style: isSelected
                                    ? AppTextStyles.bodyStrong.copyWith(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      )
                                    : AppTextStyles.body.copyWith(
                                        fontSize: 16,
                                        color: AppColors.textMuted,
                                      ),
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              /// Category Card
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

                  const SizedBox(height: AppSpacing.xl),

                  /// =======================
                  /// START DUEL BUTTON
                  /// =======================
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _gradientController,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: () {
                            final selectedCategory = controller.selectedMacro;

                            final duelType = widget.modeTitle == "1vs1"
                                ? DuelType.oneVsOne
                                : DuelType.multi;

                            final config = DuelConfig(
                              duelType: duelType,
                              category: selectedCategory,
                              totalQuestions: 10,
                              questionTimeLimitSeconds: 30,
                            );

                            /// Close modal then navigate
                            Get.back();
                            Get.to(() => MatchmakingPage(config: config));
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(
                                  -1 + 2 * _gradientController.value,
                                  0,
                                ),
                                end: Alignment(
                                  1 + 2 * _gradientController.value,
                                  0,
                                ),
                                colors: const [
                                  AppColors.primary,
                                  AppColors.primaryAccent,
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,

                            /// Button Content
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Start Duel",
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  PhosphorIcons.play(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  color: Colors.white,
                                  size: AppIconSizes.sm,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
