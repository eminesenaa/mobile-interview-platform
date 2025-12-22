import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class CodingEntryCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasDraft;

  const CodingEntryCard({
    super.key,
    required this.onTap,
    this.hasDraft = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = hasDraft ? 'Continue Coding' : 'Start Coding';
    final subtitle =
        hasDraft ? 'Pick up where you left off' : 'Open the code editor';

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
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ===================================================
              // MOCK CODE BACKGROUND (NO BLUR YET)
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
              // BLUR LAYER (ONLY AFFECTS BACKGROUND)
              // ===================================================
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true, // 🔥 TIKLAMALARI ALTTAKİ InkWell'A GEÇİRİR
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.26),
                    ),
                  ),
                ),
              ),

              // ===================================================
              // CTA (NO BLUR, FULLY VISIBLE)
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
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
/// STATIC MOCK CODE (UI ONLY)
/// --------------------------------------------------
final List<TextSpan> _mockCodeSpans = [
  const TextSpan(
    text: '// Write your solution here\n',
    style: TextStyle(
      color: AppColors.textMuted,
      fontStyle: FontStyle.italic,
    ),
  ),
  const TextSpan(
    text: '// Focus on correctness and efficiency\n\n',
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
    text: '    // TODO\n',
    style: TextStyle(
      color: Color(0xFF4CAF50),
      fontStyle: FontStyle.italic,
    ),
  ),
  const TextSpan(text: '}\n'),
];
