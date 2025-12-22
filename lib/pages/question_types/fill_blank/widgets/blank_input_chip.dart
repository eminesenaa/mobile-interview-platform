import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class BlankInputChip extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const BlankInputChip({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<BlankInputChip> createState() => _BlankInputChipState();
}

class _BlankInputChipState extends State<BlankInputChip> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _focused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant BlankInputChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80, maxHeight: 26), // ⬅ daha geniş
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 0.1,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: _focused
              ? AppColors.textPrimary
              : AppColors.textSecondary.withOpacity(0.5),
          width: _focused ? 1.6 : 1.4,
        ),
      ),
      child: IntrinsicWidth(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          showCursor: true,
          cursorHeight: 18,      // ⬅ cursor kısaldı
          cursorWidth: 1.6,
          textAlign: TextAlign.center, // ⬅ ortadan başlasın
          onChanged: widget.onChanged,
          style: AppTextStyles.questionText,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
