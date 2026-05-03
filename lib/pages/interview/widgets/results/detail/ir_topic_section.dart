// ===================== File: ir_topic_section.dart =====================
// Purpose:
// Wrapper for TopicCharts widget
// =====================================================================

import 'package:flutter/material.dart';

import '../../../../exam/result/widgets/topic_charts.dart';

class IrTopicSection extends StatelessWidget {
  final Map<String, double> topicRatios;

  const IrTopicSection({
    super.key,
    required this.topicRatios,
  });

  @override
  Widget build(BuildContext context) {
    return TopicCharts(topicRatios: topicRatios);
  }
}
