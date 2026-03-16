import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/text_styles.dart';
import '../../models/duel_enums.dart';

import 'controllers/private_room_controller.dart';
import 'widgets/duel_category_card.dart';
import 'widgets/duel_players_layout.dart';
import '../../utils/duel_category_style.dart';

class PrivateRoomLobbyPage extends StatelessWidget {
  const PrivateRoomLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller initialize
    final controller = Get.put(PrivateRoomController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            controller.onClose(); // Cleanup streams
            Get.back();
          },
        ),
        title: Text(
          'Private Room',
          style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final match = controller.match.value;
            // If already inside the lobby...
            if (match != null && match.status == DuelStatus.waiting) {
              return _buildWaitLobby(context, controller);
            }

            // Otherwise show Create / Join tabs
            return _buildTabsMenu(context, controller);
          }),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // 1. CREATE / JOIN MENU
  // ──────────────────────────────────────────────────────────
  Widget _buildTabsMenu(BuildContext context, PrivateRoomController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Tab bar substitute
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.switchTab(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.currentTab.value == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: controller.currentTab.value == 0
                            ? AppShadows.low
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Create',
                        style: AppTextStyles.button.copyWith(
                          color: controller.currentTab.value == 0
                              ? AppColors.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.switchTab(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.currentTab.value == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: controller.currentTab.value == 1
                            ? AppShadows.low
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Join',
                        style: AppTextStyles.button.copyWith(
                          color: controller.currentTab.value == 1
                              ? AppColors.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Content
          Expanded(
            child: controller.currentTab.value == 0
                ? _buildCreateTab(controller)
                : _buildJoinTab(controller),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // 2. CREATE TAB
  // ──────────────────────────────────────────────────────────
  Widget _buildCreateTab(PrivateRoomController controller) {
    final pageController = PageController(
      viewportFraction: 0.48,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Category',
          style: AppTextStyles.bodyStrong.copyWith(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: SizedBox(
            height: 170, // same as DuelConfigModal
            child: PageView.builder(
              controller: pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.macroCategories.length,
              onPageChanged: controller.selectCategory,
              itemBuilder: (context, index) {
                final title = controller.macroCategories[index];
                final color = DuelCategoryStyle.getColor(title);

                return Obx(() {
                  final isSelected = controller.selectedIndex.value == index;

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
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// CARD
                      AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: isSelected ? 1.0 : 0.85,
                        child: GestureDetector(
                          onTap: () => controller.selectCategory(index),
                          child: DuelCategoryCard(
                            title: title,
                            color: color,
                            isSelected: isSelected,
                          ),
                        ),
                      ),
                    ],
                  );
                });
              },
            ),
          ),
        ),
        ElevatedButton(
          onPressed: controller.isCreating.value ? null : () => controller.createRoom(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: controller.isCreating.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Create Room', style: AppTextStyles.button),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // 3. JOIN TAB
  // ──────────────────────────────────────────────────────────
  Widget _buildJoinTab(PrivateRoomController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Enter Room Code',
          style: AppTextStyles.bodyStrong.copyWith(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: TextField(
            onChanged: (val) => controller.joinPassword.value = val,
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 32, letterSpacing: 6),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'XXXXXX',
              hintStyle: AppTextStyles.displayLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 32,
                letterSpacing: 6,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isJoining.value ? null : () => controller.joinRoom(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: controller.isJoining.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Join Room', style: AppTextStyles.button),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // 4. WAIT LOBBY (Connected)
  // ──────────────────────────────────────────────────────────
  Widget _buildWaitLobby(BuildContext context, PrivateRoomController controller) {
    final match = controller.match.value!;
    final playerCount = match.players.length;
    final isHost = controller.isHost.value;
    final password = match.password ?? 'XXXXXX';

    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        // Access code card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text('ROOM CODE', style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    password,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: password));
                      Get.snackbar('Kopyalandı', 'Oda şifresi kopyalandı.', snackPosition: SnackPosition.BOTTOM);
                    },
                  )
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 50),
        
        // Players mapping
        DuelCategoryCard(
          title: match.category ?? 'Mixed',
          color: DuelCategoryStyle.getColor(match.category ?? 'Mixed'),
          isSelected: true,
          size: 60,
        ),
        
        const SizedBox(height: 40),
        
        DuelPlayersLayout(match: match),

        const Spacer(),
        
        Text(
          '$playerCount/5 Players Joined',
          style: AppTextStyles.bodyStrong.copyWith(color: Colors.white, fontSize: 20),
        ),

        const SizedBox(height: AppSpacing.xl),

        if (isHost)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: playerCount >= 2 ? () => controller.startGame() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.white54,
                  disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text('Start Game', style: AppTextStyles.button),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Text(
              'Waiting for host to start...',
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}
