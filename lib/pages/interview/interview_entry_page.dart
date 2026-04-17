// ===================== File: interview_entry_page.dart =====================
// Purpose:
// Handles interview entry flow (Candidate side)
//
// Responsibilities:
// - Show different UI based on interview state
// - Too early → show info
// - Waiting → countdown
// - Active → allow start
// - Completed → navigate to result
//
// Notes:
// - Uses InterviewController (GetX)
// - Fully reactive UI (Obx)
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/colors.dart';
import 'controllers/interview_controller.dart';
import 'interview_result_page.dart';

class InterviewEntryPage extends StatelessWidget {
  const InterviewEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterviewController>();

    return Scaffold(
      body: Container(
        /// ===============================
        /// BACKGROUND
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
            final state = controller.flowState.value;
            final interview = controller.selectedInterview.value;

            /// Safety
            if (interview == null) {
              return const Center(
                child: Text(
                  "Interview not found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            /// ===============================
            /// TOO EARLY
            /// ===============================
            if (state == InterviewFlowState.tooEarly) {
              return _CenteredCard(
                icon: Icons.lock_outline,
                title: "Too Early",
                subtitle:
                "This interview will open at\n${_formatTime(interview.joinOpenTime)}",
              );
            }

            /// ===============================
            /// WAITING (LAST 5 MIN)
            /// ===============================
            if (state == InterviewFlowState.waiting) {
              final secondsLeft = interview.startTime
                  .difference(DateTime.now())
                  .inSeconds;

              return _CenteredCard(
                icon: Icons.access_time,
                title: "Starting Soon",
                subtitle: "Interview will start shortly",
                child: Text(
                  _formatCountdown(secondsLeft),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }

            /// ===============================
            /// ACTIVE (READY TO START)
            /// ===============================
            if (state == InterviewFlowState.active) {
              return _CenteredCard(
                icon: Icons.play_circle_fill,
                title: "Ready to Begin?",
                subtitle: interview.title,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    controller.startInterview();
                  },
                  child: const Text("Start Interview"),
                ),
              );
            }

            /// ===============================
            /// COMPLETED
            /// ===============================
            if (state == InterviewFlowState.completed) {
              /// Direct navigate to result
              Future.microtask(() {
                Get.off(() => const InterviewResultPage());
              });

              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            /// Default fallback
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }),
        ),
      ),
    );
  }
}

/// ===============================
/// COMMON CENTER CARD
/// ===============================
class _CenteredCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? child;

  const _CenteredCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            if (child != null) ...[
              const SizedBox(height: 20),
              child!,
            ]
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// TIME FORMATTERS
/// ===============================

String _formatTime(DateTime time) {
  return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
}

String _formatCountdown(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return "$minutes:$secs";
}