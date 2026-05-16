import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../constants/constants.dart';
import 'controllers/exam_controller.dart';

/// Full-screen loading shown while exam is being evaluated.
/// Logic is unchanged – only UI is improved.
class ResultLoadingPage extends StatefulWidget {
  final String controllerTag;
  final bool autoSubmit;

  const ResultLoadingPage({
    super.key,
    required this.controllerTag,
    this.autoSubmit = false,
  });

  @override
  State<ResultLoadingPage> createState() => _ResultLoadingPageState();
}

class _ResultLoadingPageState extends State<ResultLoadingPage> {
  late final ExamController c;
  Object? _error;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    c = Get.find<ExamController>(tag: widget.controllerTag);

    WidgetsBinding.instance.addPostFrameCallback((_) => _kickoff());
  }

  Future<void> _kickoff() async {
    if (_started) return;
    _started = true;

    try {
      await Future.wait<void>([
        c.submit(auto: widget.autoSubmit),
        Future.delayed(const Duration(milliseconds: 650)),
      ]);
    } catch (e) {
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _error == null ? _buildLoading() : _buildError(_error),
        ),
      ),
    );
  }

  // ===================================================
  // LOADING UI (DiscreteCircular)
  // ===================================================
  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔄 Discrete Circular Loader
            LoadingAnimationWidget.discreteCircle(
              color: AppColors.primary,
              size: 56,
              secondRingColor: AppColors.primaryAccent,
              thirdRingColor: AppColors.primarySoftBackground,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              c.exam.title == "Interview"
                  ? 'Submitting your interview.'
                  : 'Analyzing your answers.',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              c.exam.title == "Interview"
                  ? 'Your answers are being sent to HR.\nPlease wait a moment.'
                  : 'This may take a few seconds.\nPlease keep the app open.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // ERROR UI (unchanged logic)
  // ===================================================
  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              c.exam.title == "Interview"
                  ? 'We couldn’t submit your interview.'
                  : 'We couldn’t finish evaluating your exam.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _started = false;
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _kickoff());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
