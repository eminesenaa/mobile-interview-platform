import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/question.dart';

class DifficultyPicker extends StatelessWidget {
  final RxSet<Difficulty> selected; // controller.difficulties

  const DifficultyPicker({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Difficulty.values.map((d) {
        final isSel = selected.contains(d);
        final c = _color(d, context);
        return FilterChip(
          label: Text(_label(d)),
          selected: isSel,
          onSelected: (_) =>
          isSel ? selected.remove(d) : selected.add(d),
          // seçiliyken renkli arka plan ve yazı
          selectedColor: c.withOpacity(.18),
          checkmarkColor: c,
          labelStyle: TextStyle(
            color: isSel ? c : null,
            fontWeight: isSel ? FontWeight.w600 : null,
          ),
          side: BorderSide(color: c.withOpacity(.35)),
        );
      }).toList(),
    ));
  }
}

String _label(Difficulty d) {
  switch (d) {
    case Difficulty.easy:         return 'EASY';
    case Difficulty.easy_medium:   return 'EASY - MEDIUM';
    case Difficulty.medium:       return 'MEDIUM';
    case Difficulty.medium_hard:   return 'MEDIUM - HARD';
    case Difficulty.hard:         return 'HARD';
  }
}
Color _color(Difficulty d, BuildContext context) {
  switch (d) {
    case Difficulty.easy:        return Colors.green;
    case Difficulty.easy_medium:  return Colors.lightGreen;
    case Difficulty.medium:      return Colors.orange;
    case Difficulty.medium_hard:  return Colors.deepOrange;
    case Difficulty.hard:        return Colors.red;
  }
}


