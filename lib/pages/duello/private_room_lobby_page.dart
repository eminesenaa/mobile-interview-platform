// lib/pages/duello/private_room_lobby_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/private_room_controller.dart';
import 'package:interview_project/pages/duello/widgets/lobby_tab_switch.dart';

import 'widgets/lobby_create_view.dart';
import 'widgets/lobby_join_view.dart';
import 'widgets/lobby_waiting_view.dart';

/// ===============================================================
/// 🏠 PRIVATE ROOM LOBBY PAGE (FINAL CLEAN - ALIGNED)
/// ===============================================================
///
/// ✔ Single horizontal padding system
/// ✔ All elements aligned to same grid
/// ✔ Clean top spacing
/// ✔ No overflow / no misalignment
///
class PrivateRoomLobbyPage extends StatelessWidget {
  const PrivateRoomLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivateRoomController());

    return Scaffold(
      body: Container(
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

            /// ===================================================
            /// 🎮 WAITING LOBBY
            /// ===================================================
            if (match != null) {
              return LobbyWaitingView(controller: controller);
            }

            /// ===================================================
            /// 🧭 CREATE / JOIN FLOW
            /// ===================================================
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  /// 🔙 BACK BUTTON (ARTIK GRID İÇİNDE)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        controller.onClose();
                        Get.back();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: AppColors.textLightPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  /// 🧭 TABS
                  LobbyTabSwitch(
                    currentTab: controller.currentTab,
                    onChanged: controller.switchTab,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// 📦 CONTENT
                  Expanded(
                    child: controller.currentTab.value == 0
                        ? LobbyCreateView(controller: controller)
                        : LobbyJoinView(controller: controller),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
