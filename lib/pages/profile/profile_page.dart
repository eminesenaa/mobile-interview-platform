// ===================== File: profile_page.dart =====================
// Modern, null-safe Profile Page – build() içinde Get.put()

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/interview/pages/interview_dashboard_page.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/constants.dart';

import 'controllers/profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/profile_tools_list.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      // backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.background,
            ],
            stops: [0.0, 0.55],
          ),
        ),
        child: Obx(() {
          final user = controller.user.value;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------
                  // HEADER (full width gradient)
                  // ---------------------------
                  ProfileHeader(
                    avatarUrl: user.avatar,
                    name: "${user.name} ${user.surname}",
                    role: user.role ?? "",
                    location: user.location ?? "",
                    onContactPressed: controller.openContactInfoModal,
                  ),

                  // ---------------------------
                  // BODY
                  // ---------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        ProfileStatsRow(
                          xp: user.totalXp,
                          streak: user.streak.streakCount,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          "Profile Tools",
                          style: AppTextStyles.headline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ProfileToolsList(
                          onOpenProgress: controller.openProgressPage,
                          onOpenInterviewResults:
                              controller.openInterviewResults,
                          onEditProfile: controller.openEditProfile,
                          onUploadCV: controller.uploadCV,
                          onViewCV: controller.openCVViewer,
                          hasCV: user.cvUrl != null,
                          onCVPressed:
                              () {}, // BURASI DOLACAK MI VS KONTROL EDİLMESİ LAZIM
                        ),
                        // ---------------------------
                        // INTERVIEW SECTION (TEMP ENTRY)
                        // ---------------------------
                        const SizedBox(height: AppSpacing.xxl),

                        Text(
                          "Interviews",
                          style: AppTextStyles.headline,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const Icon(
                              Icons.work_outline,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              "My Interviews",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "View and enter your interviews",
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // 👉 Navigate to Interview Main Page
                              Get.to(() => const InterviewDashboardPage());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
