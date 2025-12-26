import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class ReviewCodingEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const ReviewCodingEntryCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.border,
              width: 1.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ===================================================
              // MOCK CODE BACKGROUND (UI ONLY)
              // ===================================================
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      children: _mockCodeSpans,
                    ),
                  ),
                ),
              ),

              // ===================================================
              // BLUR LAYER (BACKGROUND ONLY)
              // ===================================================
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 1.5,
                      sigmaY: 1.5,
                    ),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.26),
                    ),
                  ),
                ),
              ),

              // ===================================================
              // CTA (REVIEW MODE)
              // ===================================================
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.code(PhosphorIconsStyle.bold),
                      size: 30,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'View Your Code',
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See what you wrote during the exam.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------------------------------------
/// STATIC MOCK CODE (UI ONLY – SAME AS PRACTICE)
/// --------------------------------------------------
final List<TextSpan> _mockCodeSpans = [
  const TextSpan(
    text: '// Your solution\n',
    style: TextStyle(
      color: AppColors.textMuted,
      fontStyle: FontStyle.italic,
    ),
  ),
  const TextSpan(
    text: '// Submitted during the exam\n\n',
    style: TextStyle(
      color: AppColors.textMuted,
      fontStyle: FontStyle.italic,
    ),
  ),
  const TextSpan(
    text: 'int ',
    style: TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
  ),
  const TextSpan(
    text: 'solve',
    style: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
  ),
  const TextSpan(text: '(...) {\n'),
  const TextSpan(
    text: '    // review only\n',
    style: TextStyle(
      color: Color(0xFF4CAF50),
      fontStyle: FontStyle.italic,
    ),
  ),
  const TextSpan(text: '}\n'),
];
