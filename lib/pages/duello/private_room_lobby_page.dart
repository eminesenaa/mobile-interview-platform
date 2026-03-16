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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            controller.onClose(); // Cleanup streams
            Get.back();
          },
        ),
        title: Text(
          'Private Room',
          style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
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
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
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
                        border: controller.currentTab.value == 0
                            ? const Border(bottom: BorderSide(color: AppColors.primary, width: 3))
                            : const Border(bottom: BorderSide(color: Colors.transparent, width: 3)),
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
                              : AppColors.textSecondary,
                          fontWeight: controller.currentTab.value == 0 ? FontWeight.bold : FontWeight.normal,
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
                        border: controller.currentTab.value == 1
                            ? const Border(bottom: BorderSide(color: AppColors.primary, width: 3))
                            : const Border(bottom: BorderSide(color: Colors.transparent, width: 3)),
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
                              : AppColors.textSecondary,
                          fontWeight: controller.currentTab.value == 1 ? FontWeight.bold : FontWeight.normal,
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
          style: AppTextStyles.bodyStrong.copyWith(color: AppColors.textPrimary, fontSize: 20),
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
                            color: AppColors.textPrimary,
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
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))] : null,
                            ),
                            child: DuelCategoryCard(
                              title: title,
                              color: color,
                              isSelected: isSelected,
                            ),
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
            backgroundColor: AppColors.topicBrightTeal, // Primary brand color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: controller.isCreating.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text('Create Room', style: AppTextStyles.button.copyWith(color: Colors.white)),
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
          style: AppTextStyles.bodyStrong.copyWith(color: AppColors.textPrimary, fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (val) => controller.joinPassword.value = val,
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary, fontSize: 32, letterSpacing: 6),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.borderStrong, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              hintText: 'XXXXXX',
              hintStyle: AppTextStyles.displayLarge.copyWith(
                color: AppColors.textMuted,
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
              backgroundColor: AppColors.topicBrightTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: controller.isJoining.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Join Room', style: AppTextStyles.button.copyWith(color: Colors.white)),
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
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: Column(
              children: [
                Text('ROOM CODE', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      password,
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: password));
                        Get.snackbar('Copied', 'Oda şifresi kopyalandı.', snackPosition: SnackPosition.BOTTOM);
                      },
                    )
                  ],
                ),
              ],
            ),
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
        
        DuelPlayersLayout(
          match: match,
          hostUserId: match.players.isNotEmpty ? match.players.first.userId : null,
          textColor: AppColors.textPrimary,
        ),

        const Spacer(),
        
        Text(
          '$playerCount/5 Players Joined',
          style: AppTextStyles.bodyStrong.copyWith(color: AppColors.textPrimary, fontSize: 20),
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
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text('Start Game', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18)),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Text(
              'Waiting for host to start...',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
