import 'package:flutter/material.dart';

/// A read-only card to display the user's short answer in Review mode.
/// - Shows a title ("Your Answer") and an optional verdict chip (e.g. Correct / Partially Correct / Wrong)
/// - Colored border & subtle fill to reflect verdict
/// - Expand/Collapse for long text
class UserAnswerCard extends StatefulWidget {
  final String answer;

  /// Optional verdict label shown as a Chip on the right (e.g. "Correct", "Partially Correct", "Wrong")
  final String? verdictLabel;

  /// Colors to style verdict visuals. If null, will fall back to theme/greys.
  final Color? borderColor;
  final Color? fillColor;
  final Color? labelColor;

  /// Max lines to show when collapsed.
  final int collapsedMaxLines;

  const UserAnswerCard({
    super.key,
    required this.answer,
    this.verdictLabel,
    this.borderColor,
    this.fillColor,
    this.labelColor,
    this.collapsedMaxLines = 5,
  });

  @override
  State<UserAnswerCard> createState() => _UserAnswerCardState();
}

class _UserAnswerCardState extends State<UserAnswerCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final border = widget.borderColor ?? cs.outlineVariant;
    final fill = widget.fillColor; // null => transparent

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.4),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (title + verdict chip)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Answer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.verdictLabel != null) ...[
                _buildVerdictIcon(widget.verdictLabel!, widget.labelColor),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Answer text (read-only)
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: SelectableText(
              widget.answer.isEmpty ? '' : widget.answer,
              maxLines: _expanded ? null : widget.collapsedMaxLines,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),

          // Expand/Collapse
          if (_needsCollapse(widget.answer, widget.collapsedMaxLines, context))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Show less' : 'Show more'),
              ),
            ),
        ],
      ),
    );
  }

  /// Heuristic: if text will likely overflow collapsed lines, show the toggle.
  bool _needsCollapse(String text, int lines, BuildContext context) {
    if (text.trim().isEmpty) return false;
    final span = TextSpan(
      text: text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: lines,
    )..layout(
        maxWidth: MediaQuery.of(context).size.width - 64); // padding guess
    return tp.didExceedMaxLines;
  }

  /// Small verdict icon on the top-right corner
  Widget _buildVerdictIcon(String label, Color? color) {
    IconData icon;
    Color effectiveColor = color ?? Colors.grey;

    switch (label.toLowerCase()) {
      case 'correct':
        icon = Icons.check_circle_rounded;
        effectiveColor = Colors.green;
        break;
      case 'wrong':
        icon = Icons.cancel_rounded;
        effectiveColor = Colors.red;
        break;
      case 'unanswered':
        icon = Icons.remove_circle_outline;
        effectiveColor = Colors.grey;
        break;
      default:
        icon = Icons.help_outline_rounded;
    }

    return Icon(
      icon,
      color: effectiveColor,
      size: 20,
    );
  }
}
