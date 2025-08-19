import 'package:flutter/material.dart';
import '../models/question.dart';

class FilterPopup extends StatefulWidget {
  final List<String> topics;
  final List<Difficulty?> difficulties;
  final List<Status?> statuses;

  final String selectedTopic;
  final Difficulty? selectedDifficulty;
  final Status? selectedStatus;

  final void Function({
  required String topic,
  required Difficulty? difficulty,
  required Status? status,
  }) onApply;

  const FilterPopup({
    super.key,
    required this.topics,
    required this.difficulties,
    required this.statuses,
    required this.selectedTopic,
    required this.selectedDifficulty,
    required this.selectedStatus,
    required this.onApply,
  });

  @override
  State<FilterPopup> createState() => _FilterPopupState();
}

class _FilterPopupState extends State<FilterPopup> {
  late String topic;
  late Difficulty? difficulty;
  late Status? status;

  @override
  void initState() {
    super.initState();
    topic = widget.selectedTopic;
    difficulty = widget.selectedDifficulty;
    status = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopicDropdown("Topic", widget.topics, topic, (val) {
            setState(() => topic = val);
          }),
          _buildEnumDropdown<Difficulty>(
            label: "Difficulty",
            options: widget.difficulties,
            selected: difficulty,
            toText: (d) => d?.name ?? "All",
            onChanged: (val) => setState(() => difficulty = val),
          ),
          _buildEnumDropdown<Status>(
            label: "Status",
            options: widget.statuses,
            selected: status,
            toText: (s) => s?.name ?? "All",
            onChanged: (val) => setState(() => status = val),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onApply(
                topic: topic,
                difficulty: difficulty,
                status: status,
              );
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicDropdown(
      String label,
      List<String> options,
      String selected,
      ValueChanged<String> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selected,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (String? val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }

  Widget _buildEnumDropdown<T>({
    required String label,
    required List<T?> options,
    required T? selected,
    required String Function(T?) toText,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T?>(
        value: selected,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: options
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(toText(e)),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
