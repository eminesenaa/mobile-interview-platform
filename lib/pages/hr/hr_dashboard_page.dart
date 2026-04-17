// ===================== File: hr_dashboard_page.dart =====================
// Purpose:
// Main landing page for HR users after login
//
// Responsibilities:
// - Show basic company info
// - Quick actions (Create Interview, View Interviews)
// - Entry point for HR flows
//
// Notes:
// - Temporary UI (functional > visual)
// - Will be expanded later
// =======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/constants.dart';
import 'create_interview_page.dart';
import 'hr_results_page.dart';

class HRDashboardPage extends StatelessWidget {
  const HRDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// ===============================
        /// BACKGROUND
        /// ===============================
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===============================
                /// HEADER
                /// ===============================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome back",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "TechCorp Inc.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    /// Avatar (placeholder)
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text("HR"),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                /// ===============================
                /// STATS (TEMP)
                /// ===============================
                Row(
                  children: [
                    _StatCard(title: "Interviews", value: "5"),
                    const SizedBox(width: AppSpacing.md),
                    _StatCard(title: "Candidates", value: "34"),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                /// ===============================
                /// QUICK ACTIONS
                /// ===============================
                Text(
                  "Quick Actions",
                  style: AppTextStyles.headline,
                ),

                const SizedBox(height: AppSpacing.md),

                _ActionCard(
                  title: "Create Interview",
                  subtitle: "Set up a new interview session",
                  icon: Icons.add,
                  onTap: () {
                    Get.to(() => const CreateInterviewPage());
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                _ActionCard(
                  title: "View Interviews",
                  subtitle: "Manage scheduled sessions",
                  icon: Icons.monitor,
                  onTap: () {
                    Get.to(() => const HRResultsPage());
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                _ActionCard(
                  title: "Candidates",
                  subtitle: "Browse & manage applicants",
                  icon: Icons.people,
                  onTap: () {
                    Get.snackbar("TODO", "Candidates Page");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// ===============================
/// STAT CARD
/// ===============================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}


/// ===============================
/// ACTION CARD
/// ===============================
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),

        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}