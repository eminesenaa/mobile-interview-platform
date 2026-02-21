import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/duel_config_controller.dart';

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

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // subtle flow
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

    final categoryColors = [
      AppColors.cinnabar,
      AppColors.accentWinePlum,
      AppColors.stormyTeal,
      AppColors.accentCeladon,
      AppColors.accentSpicyOrange,
      AppColors.honeyBronze,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// Blur background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          /// Center modal
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// TITLE
                  Text(
                    "Select Category",
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// CATEGORY SLIDER
                  SizedBox(
                    height: 170,
                    child: PageView.builder(
                      controller: pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.macroCategories.length,
                      onPageChanged: controller.selectCategory,
                      itemBuilder: (context, index) {
                        final color =
                            categoryColors[index % categoryColors.length];

                        return Obx(() {
                          final isSelected =
                              controller.selectedIndex.value == index;

                          final title = controller.macroCategories[index];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// TITLE
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isSelected ? 1 : 0.4,
                                child: Text(
                                  title,
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// CARD
                              AnimatedScale(
                                duration: const Duration(milliseconds: 250),
                                scale: isSelected ? 1.0 : 0.85,
                                child: _CategoryCard(
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

                  /// ANIMATED GRADIENT FLOW BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _gradientController,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: () {
                            final macro = controller.selectedMacro;
                            final topics = controller.getMappedTopics();

                            Get.back();
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
                                const SizedBox(width: 8),
                                Icon(
                                  PhosphorIcons.play(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  color: Colors.white,
                                  size: 16,
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

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;

  const _CategoryCard({
    required this.title,
    required this.color,
    required this.isSelected,
  });

  IconData _getIcon() {
    switch (title) {
      case "Mixed":
        return PhosphorIcons.shuffle();
      case "Programming":
        return PhosphorIcons.code();
      case "Algorithms":
        return PhosphorIcons.treeStructure();
      case "Data & AI":
        return PhosphorIcons.brain();
      case "Systems":
        return PhosphorIcons.network();
      case "Soft Skills":
        return PhosphorIcons.users();
      default:
        return PhosphorIcons.question();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? color : color.withOpacity(0.18);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Icon(
        _getIcon(),
        size: 40,
        color: isSelected ? Colors.white : color,
      ),
    );
  }
}
