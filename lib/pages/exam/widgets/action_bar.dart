import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final VoidCallback onNavigator;

  const ActionBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
    required this.onNavigator,
  });

  @override
  Widget build(BuildContext context) {
    // Küçük ekranlarda taşmayı önlemek için Wrap + runSpacing kullanıyoruz
    final ButtonStyle outline =
    OutlinedButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 12));
    final ButtonStyle filled =
    FilledButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Wrap(
                spacing: 8,          // yatay boşluk
                runSpacing: 8,       // alt satıra inince dikey boşluk
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton(onPressed: onPrev, style: outline, child: const Text('Prev')),
                  OutlinedButton(onPressed: onNavigator, style: outline, child: const Text('Questions')),
                  OutlinedButton(onPressed: onNext, style: outline, child: const Text('Next')),
                  FilledButton(onPressed: onSubmit, style: filled, child: const Text('Submit')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
