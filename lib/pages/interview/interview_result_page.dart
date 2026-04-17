// ===================== File: interview_result_page.dart =====================
// Purpose:
// Displays interview result AFTER submission
//
// Responsibilities:
// - Show score
// - Show correct / wrong
// - Show hr decision (accepted / rejected)
// - Show hr message (if exists)
//
// Notes:
// - Uses InterviewController
// - Fully reactive UI (Obx)
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/colors.dart';
import 'controllers/interview_controller.dart';
import '../../../models/interview_result.dart';

class InterviewResultPage extends StatelessWidget {
  const InterviewResultPage({super.key});

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
            final result = controller.currentResult.value;

            /// Safety
            if (result == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ===============================
                /// STATUS ICON
                /// ===============================
                _buildStatusIcon(result),

                const SizedBox(height: 20),

                /// ===============================
                /// TITLE
                /// ===============================
                Text(
                  _getTitle(result),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                /// ===============================
                /// SCORE
                /// ===============================
                _ScoreCard(result: result),

                const SizedBox(height: 20),

                /// ===============================
                /// HR MESSAGE
                /// ===============================
                if (result.hrMessage != null)
                  _MessageCard(message: result.hrMessage!),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// ===============================
  /// STATUS ICON
  /// ===============================
  Widget _buildStatusIcon(InterviewResult result) {
    if (result.decision == InterviewDecisionStatus.accepted) {
      return const Icon(Icons.check_circle,
          size: 80, color: Colors.greenAccent);
    } else if (result.decision == InterviewDecisionStatus.rejected) {
      return const Icon(Icons.cancel, size: 80, color: Colors.redAccent);
    }

    return const Icon(Icons.hourglass_top,
        size: 80, color: Colors.orangeAccent);
  }

  /// ===============================
  /// TITLE
  /// ===============================
  String _getTitle(InterviewResult result) {
    if (result.decision == InterviewDecisionStatus.accepted) {
      return "Accepted 🎉";
    } else if (result.decision == InterviewDecisionStatus.rejected) {
      return "Rejected";
    }
    return "Pending Review";
  }
}

/// ===============================
/// SCORE CARD
/// ===============================
class _ScoreCard extends StatelessWidget {
  final InterviewResult result;

  const _ScoreCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          /// SCORE
          Text(
            "${result.score}",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 10),

          const Text("Score"),

          const SizedBox(height: 20),

          /// STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: "Correct",
                value: result.correctCount,
                color: Colors.green,
              ),
              _StatItem(
                label: "Wrong",
                value: result.wrongCount,
                color: Colors.red,
              ),
              _StatItem(
                label: "Empty",
                value: result.unansweredCount,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// STAT ITEM
/// ===============================
class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

/// ===============================
/// MESSAGE CARD
/// ===============================
class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
