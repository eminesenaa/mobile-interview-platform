import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/constants.dart';
import 'controllers/signup_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_divider.dart';
import 'widgets/auth_social_buttons.dart';

/// Signup Page
/// - Same layout system as LoginPage
/// - Header on top
/// - Card pinned visually to bottom
/// - Back button (Signup only)
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // =========================
            // Main content
            // =========================
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xl,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // =========================
                                // Header
                                // =========================
                                const AuthHeader(
                                  title: "Create an account",
                                  subtitle: "Join MIPP and start practicing",
                                  size: AuthHeaderSize.tiny,
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                const Spacer(),

                                // =========================
                                // Signup Card
                                // =========================
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    boxShadow: AppShadows.medium,
                                  ),
                                  child: Column(
                                    children: [
                                      // =========================
// SIGNUP TYPE SWITCH (Candidate / HR)
// =========================
                                      Obx(
                                        () => Container(
                                          margin: const EdgeInsets.only(
                                              bottom: AppSpacing.md),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceMuted,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              // Candidate
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => controller
                                                      .setSignupMode(false),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: controller
                                                              .isHrSignup.value
                                                          ? Colors.transparent
                                                          : AppColors.surface,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Candidate",
                                                      style: AppTextStyles
                                                          .body
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // HR
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => controller
                                                      .setSignupMode(true),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: controller
                                                              .isHrSignup.value
                                                          ? AppColors.surface
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "HR Signup",
                                                      style: AppTextStyles
                                                          .body
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      AuthTextField(
                                        controller: controller.nameCtrl,
                                        hint: "First name",
                                        icon: PhosphorIcons.user(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      AuthTextField(
                                        controller: controller.surnameCtrl,
                                        hint: "Last name",
                                        icon: PhosphorIcons.user(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      AuthTextField(
                                        controller: controller.usernameCtrl,
                                        hint: "Username",
                                        icon: PhosphorIcons.at(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      AuthTextField(
                                        controller: controller.emailCtrl,
                                        hint: "Email",
                                        icon: PhosphorIcons.envelope(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      AuthTextField(
                                        controller: controller.passwordCtrl,
                                        hint: "Password",
                                        icon: PhosphorIcons.lock(),
                                        isPassword: true,
                                      ),

                                      const SizedBox(height: AppSpacing.sm),

                                      // =========================
                                      // Terms of Service
                                      // =========================
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Obx(
                                            () => Checkbox(
                                              value: controller
                                                  .acceptedTerms.value,
                                              onChanged: (v) => controller
                                                  .acceptedTerms
                                                  .value = v ?? false,
                                              activeColor: AppColors.primary,
                                              side: const BorderSide(
                                                color: AppColors.borderStrong,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "I agree to the Terms of Service",
                                              style: AppTextStyles.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: AppSpacing.md),

                                      // =========================
                                      // Create account button
                                      // =========================
                                      Obx(
                                        () => AuthPrimaryButton(
                                          label: controller.isHrSignup.value
                                              ? "Create HR Account"
                                              : "Create Account",
                                          isLoading: controller.isLoading.value,
                                          onPressed: controller.handleSignup,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.lg),

                                      const AuthDivider(),

                                      const SizedBox(height: AppSpacing.lg),

                                      // =========================
                                      // Social signup
                                      // =========================
                                      AuthSocialButtons(
                                        onGoogle: controller.signUpWithGoogle,
                                        onApple: controller.signUpWithApple,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // =========================
            // Back button (Signup only)
            // =========================
            Positioned(
              // ⬇️ SmartNest benzeri: biraz aşağı + biraz içeri
              top: AppSpacing.xl,
              left: AppSpacing.md,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.low,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16, // daha ince his
                    color: AppColors.textSecondary, // siyah değil
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
