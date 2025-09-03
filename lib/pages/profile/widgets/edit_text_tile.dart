import 'package:flutter/material.dart';

typedef SubmitText = Future<void> Function(String value);

class EditTextTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String valueText;          // mevcut değer (kısaltılmış gösterilir)
  final String dialogLabel;        // dialog başlığı/label
  final String initialValue;       // dialog içindeki başlangıç metni
  final String? Function(String?)? validator;
  final SubmitText onSubmit;

  const EditTextTile({
    super.key,
    required this.icon,
    required this.title,
    required this.valueText,
    required this.dialogLabel,
    required this.initialValue,
    required this.onSubmit,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          valueText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _openDialog(context),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update $dialogLabel'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: dialogLabel,
              prefixIcon: Icon(icon),
            ),
            validator: validator,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, ctrl.text.trim());
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null && result != initialValue) {
      await onSubmit(result);
    }
  }
}
