import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/constants.dart';
import 'controllers/login_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_divider.dart';
import 'widgets/auth_social_buttons.dart';
import 'signup_page.dart';

/// Login Page
/// - Soft background
/// - Header on top (logo + title)
/// - White card pinned to bottom
/// - Signup moved INSIDE the card
/// - Design-system compliant
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
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
                            // Header (TOP)
                            // =========================
                            const AuthHeader(
                              title: "Welcome to MIPP",
                              subtitle: "Login to continue",
                              size: AuthHeaderSize.large,
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Push card to bottom
                            const Spacer(),

                            // =========================
                            // Login Card
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
                                  // Email / Username
                                  AuthTextField(
                                    controller: controller.emailOrUsernameCtrl,
                                    hint: "Email or username",
                                    icon: PhosphorIcons.user(),
                                  ),

                                  const SizedBox(height: AppSpacing.md),

                                  // Password
                                  AuthTextField(
                                    controller: controller.passwordCtrl,
                                    hint: "Password",
                                    icon: PhosphorIcons.lock(),
                                    isPassword: true,
                                  ),

                                  const SizedBox(height: AppSpacing.sm),

                                  // Remember me + Forgot password
                                  Row(
                                    children: [
                                      Obx(
                                        () => Checkbox(
                                          value: controller.rememberMe.value,
                                          onChanged: (v) => controller
                                              .toggleRememberMe(v ?? false),
                                          activeColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.borderStrong,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Remember me",
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          // 🔹 GÜNCELLENEN KISIM BURASI
                                          controller.showForgotPasswordDialog();
                                        },
                                        child: Text(
                                          "Forgot password?",
                                          style: AppTextStyles.textButton,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: AppSpacing.md),

                                  // Login button
                                  Obx(
                                    () => AuthPrimaryButton(
                                      label: "Login",
                                      isLoading: controller.isLoading.value,
                                      onPressed: controller.login,
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.lg),

                                  const AuthDivider(),

                                  const SizedBox(height: AppSpacing.lg),

                                  // Social login
                                  AuthSocialButtons(
                                    onGoogle: controller.loginWithGoogle,
                                    onApple: controller.loginWithApple,
                                  ),

                                  const SizedBox(height: AppSpacing.lg),

                                  // =========================
                                  // Signup redirect (INSIDE CARD)
                                  // =========================
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don’t have an account? ",
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      GestureDetector(
                                        onTap: () => Get.to(
                                          () => const SignUpPage(),
                                        ),
                                        child: Text(
                                          "Sign up",
                                          style: AppTextStyles.textButton,
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }
}
