import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';

class HrCandidateEvaluationSuccessPage extends StatelessWidget {
  final String candidateName;
  final Map<String, dynamic> interview;

  const HrCandidateEvaluationSuccessPage({
    super.key,
    required this.candidateName,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            /// ================= CENTER CONTENT =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// ICON
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// TITLE
                    Text(
                      "Evaluation Completed",
                      style: AppTextStyles.headline,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    /// MESSAGE
                    Text(
                      "You have evaluated $candidateName.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),

            /// ================= BOTTOM BUTTON =================
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    "Continue Reviewing Candidates",
                    style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.textLightPrimary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
