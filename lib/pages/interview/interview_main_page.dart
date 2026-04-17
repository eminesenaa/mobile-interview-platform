// ===================== File: interview_main_page.dart =====================
// Purpose:
// Main entry page for Interview feature (Candidate side)
//
// Responsibilities:
// - Fetch and display assigned interviews
// - Allow user to select an interview
// - Navigate to InterviewEntryPage
//
// Notes:
// - Uses InterviewController (GetX)
// - Uses FakeInterviewService for now (backend later)
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/colors.dart';
import 'controllers/interview_controller.dart';
import '../../models/interview.dart';
import 'interview_entry_page.dart';

class InterviewMainPage extends StatelessWidget {
  const InterviewMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// ===============================
    /// CONTROLLER INIT
    /// ===============================
    final controller = Get.put(
      InterviewController(),
      permanent: false,
    );

    return Scaffold(
      body: Container(
        /// ===============================
        /// BACKGROUND (same style as duel)
        /// ===============================
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
            /// ===============================
            /// LOADING STATE
            /// ===============================
            if (controller.flowState.value ==
                InterviewFlowState.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            /// ===============================
            /// EMPTY STATE
            /// ===============================
            if (controller.interviews.isEmpty) {
              return const Center(
                child: Text(
                  "No interviews found",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              );
            }

            /// ===============================
            /// INTERVIEW LIST
            /// ===============================
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.interviews.length,
              itemBuilder: (context, index) {
                final Interview interview =
                controller.interviews[index];

                return _InterviewCard(
                  interview: interview,
                  onTap: () {
                    /// Select interview
                    controller.selectInterview(interview);

                    /// Navigate WITHOUT routing system
                    Get.to(() => const InterviewEntryPage());
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}


/// ===============================
/// INTERVIEW CARD WIDGET
/// ===============================
class _InterviewCard extends StatelessWidget {
  final Interview interview;
  final VoidCallback onTap;

  const _InterviewCard({
    required this.interview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        /// ===============================
        /// TITLE
        /// ===============================
        title: Text(
          interview.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        /// ===============================
        /// SUBTITLE
        /// ===============================
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            interview.position,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),

        /// ===============================
        /// TRAILING ICON
        /// ===============================
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}