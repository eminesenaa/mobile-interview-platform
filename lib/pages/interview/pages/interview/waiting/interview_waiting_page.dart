// ===================== File: interview_waiting_page.dart =====================
// Purpose:
// Waiting screen before interview starts
//
// Features:
// - Live badge (top-right)
// - Pulse animation (center)
// - Title + subtitle
// - Date & time chips
// - Waiting card with loader
//
// IMPORTANT:
// - Uses InterviewSessionController
// - Auto redirects to ExamPage
//
// TODO (Backend):
// - Replace timer with real-time session listener
// - Pass real session data (date, time, code)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';

// ================= CONTROLLER =================
import '../../../controllers/interview_session_controller.dart';

// ================= WIDGETS =================
import '../../../widgets/interview/waiting/iw_info_chips_row.dart';
import '../../../widgets/interview/waiting/iw_pulse_animation.dart';
import '../../../widgets/interview/waiting/iw_title_section.dart';
import '../../../widgets/interview/waiting/iw_waiting_card.dart';


class InterviewWaitingPage extends StatelessWidget {
  const InterviewWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewSessionController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= BODY =================
      body: SafeArea(
        child: Stack(
          children: [

            // ================= MAIN CONTENT =================
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ================= PULSE ANIMATION =================
                    const IwPulseAnimation(),

                    const SizedBox(height: AppSpacing.xl),

                    // ================= TITLE =================
                    const IwTitleSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // ================= DATE & TIME =================
                    Obx(() => IwInfoChipsRow(
                          date: controller.date.value,
                          time: controller.time.value,
                        )),

                    const SizedBox(height: AppSpacing.xl),

                    // ================= WAITING CARD =================
                    Obx(() => IwWaitingCard(
                          sessionId: controller.sessionCode.value,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
