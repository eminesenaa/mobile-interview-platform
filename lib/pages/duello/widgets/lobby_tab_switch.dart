import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// 🔀 LOBBY TAB SWITCH (CREATE / JOIN)
/// ===============================================================
///
/// ✔ Smooth sliding indicator (iOS style)
/// ✔ Glass UI
/// ✔ No duplicate decoration (no weird lines)
/// ✔ Clean & minimal
///
class LobbyTabSwitch extends StatelessWidget {
  final RxInt currentTab;
  final Function(int) onChanged;

  const LobbyTabSwitch({
    super.key,
    required this.currentTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: Colors.white.withOpacity(0.12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 6) / 2;

          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;

              if (details.primaryVelocity! < 0) {
                if (currentTab.value == 0) onChanged(1);
              } else {
                if (currentTab.value == 1) onChanged(0);
              }
            },
            child: Stack(
              children: [
                /// 🔵 SLIDING INDICATOR
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    left: currentTab.value == 0 ? 0 : tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: tabWidth,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🧠 TEXT LAYER
                Row(
                  children: [
                    _buildTab("Create", 0),
                    _buildTab("Join", 1),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===============================================================
  /// SINGLE TAB (TEXT ONLY)
  /// ===============================================================
  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Obx(() {
          final isSelected = currentTab.value == index;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppTextStyles.bodyStrong.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.textLightPrimary.withOpacity(0.7),
              ),
            ),
          );
        }),
      ),
    );
  }
}
