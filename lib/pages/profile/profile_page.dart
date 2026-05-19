// ===================== File: profile_page.dart =====================
// Purpose:
// Modern Profile Page (UI Refactored)
//
// Features:
// - Clean centered header
// - XP & Streak cards
// - Account actions (Edit / Results / Settings)
// - Interview entry card
//
// IMPORTANT:
// - Backend & controller logic is NOT changed
// - Only UI is refactored
//
// TODO (Future):
// - Replace mock counts (interview stats) with real backend data
// ==================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/profile/settings_page.dart';

import '../../constants/constants.dart';

// ================= CONTROLLER =================
import 'controllers/profile_controller.dart';
import 'controllers/profile_edit_controller.dart';
import '../interview/controllers/interview_dashboard_controller.dart';

// ================= NEW WIDGETS =================
import 'widgets/profile/np_header_section.dart';
import 'widgets/profile/np_stats_section.dart';
import 'widgets/profile/np_account_section.dart';
import 'widgets/profile/np_interview_card.dart';

// ================= NAVIGATION =================
import '../interview/pages/interview_dashboard_page.dart';
import 'edit_profile_page.dart';
import '../interview/pages/results/interview_results_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ================= INIT CONTROLLER =================
    final controller = Get.put(ProfileController());
    Get.lazyPut(() => ProfileEditController());
    final dashboardController = Get.put(InterviewDashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = controller.user.value;

        // ================= LOADING =================
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, // left
              AppSpacing.xxl, // top
              AppSpacing.lg, // right
              AppSpacing.md, // bottom
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =====================================================
                // HEADER SECTION
                // =====================================================
                NpHeaderSection(
                  name: "${user.name} ${user.surname}",
                  role: user.role ?? "User",
                  location: user.location,
                ),

                const SizedBox(height: AppSpacing.xl),

                // =====================================================
                // STATS SECTION (XP + STREAK)
                // =====================================================
                NpStatsSection(
                  xp: user.totalXp,
                  streak: user.streak.streakCount,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // =====================================================
                // ACCOUNT SECTION
                // =====================================================
                NpAccountSection(
                  onEdit: () {
                    Get.to(() => const EditProfilePage());
                  },
                  onResults: () {
                    Get.to(() => const InterviewResultsPage());
                  },
                  onSettings: () {
                    Get.to(() => const SettingsPage());
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // =====================================================
                // INTERVIEW ENTRY CARD
                // =====================================================
                Obx(() {
                  return NpInterviewCard(
                    upcoming: dashboardController.readyInterviewsCount,
                    completed: dashboardController.results.length,
                    onTap: () {
                      Get.to(() => const InterviewDashboardPage());
                    },
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
