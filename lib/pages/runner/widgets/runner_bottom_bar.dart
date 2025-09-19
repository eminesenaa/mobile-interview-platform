import 'package:flutter/material.dart';

class RunnerBottomBar extends StatelessWidget {
  const RunnerBottomBar({
    super.key,
    required this.hasPrev,
    required this.hasNext,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onPrev,
    required this.onSubmit,
    required this.onNext,
    required this.onFinish,
    this.submitLabel = 'Send',
  });

  final bool hasPrev;
  final bool hasNext;
  final bool isSubmitting;
  final bool canSubmit;

  final VoidCallback onPrev;
  final VoidCallback onSubmit;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --------- Üst satır: Previous | Next ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: (hasPrev && !isSubmitting) ? onPrev : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                ),
                TextButton.icon(
                  onPressed: !isSubmitting
                      ? (hasNext ? onNext : onFinish)
                      : null,
                  icon: Icon(hasNext ? Icons.chevron_right : Icons.check),
                  label: Text(hasNext ? 'Next' : 'Finish'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --------- Alttaki tam genişlik Submit ----------
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (canSubmit && !isSubmitting) ? onSubmit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSubmitting
                      ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Text(
                    submitLabel,
                    key: const ValueKey('label'),
                  ),
                ),
              ),
            ),

            // Eğer ActionBar widget'ını kullanmak istersen, üstteki FilledButton'ı
            // yorum satırına alıp bunu aç:
            //
            // ActionBar(
            //   label: submitLabel,
            //   onPressed: (canSubmit && !isSubmitting) ? onSubmit : null,
            //   // loading/enabled prop'ları varsa burada eşle
            // ),
          ],
        ),
      ),
    );
  }
}
