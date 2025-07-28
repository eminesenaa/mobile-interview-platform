import 'package:flutter/material.dart';

class TopicChipScroll extends StatelessWidget {
  final List<String> topics;
  final String selectedTopic;
  final ValueChanged<String> onTopicSelected;

  const TopicChipScroll({
    super.key,
    required this.topics,
    required this.selectedTopic,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = topic == selectedTopic;

          return ChoiceChip(
            label: Text(topic),
            selected: isSelected,
            onSelected: (_) => onTopicSelected(topic),
            selectedColor: Colors.blue.shade100,
            labelStyle: TextStyle(
              color: isSelected ? Colors.blue.shade900 : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.grey.shade200,
          );
        },
      ),
    );
  }
}
