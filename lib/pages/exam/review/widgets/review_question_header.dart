import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class ReviewQuestionHeader extends StatelessWidget {
  final int current;
  final int total;

  const ReviewQuestionHeader({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Question $current of $total',
          style: AppTextStyles.title,
        ),
      ],
    );
  }
}
