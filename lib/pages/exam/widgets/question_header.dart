import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final int current;
  final int total;
  const QuestionHeader({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Question $current of $total',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
