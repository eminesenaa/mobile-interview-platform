import 'package:flutter/material.dart';

class PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String valueText;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const PickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.valueText,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(valueText),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _openSheet(context),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: options.map((opt) {
          final selected = opt == valueText;
          return ListTile(
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
            title: Text(opt),
            onTap: () => Navigator.pop(context, opt),
          );
        }).toList(),
      ),
    );
    if (chosen != null && chosen != valueText) onSelected(chosen);
  }
}
