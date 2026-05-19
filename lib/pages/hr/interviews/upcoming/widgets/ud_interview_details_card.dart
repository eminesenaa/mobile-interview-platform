import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

class UDInterviewDetailsCard extends StatelessWidget {
  final String title;
  final String position;
  final String date;
  final String timeRange;

  final VoidCallback onEditTitle;
  final VoidCallback onEditPosition;
  final VoidCallback onEditDate;
  final VoidCallback onEditTime;

  const UDInterviewDetailsCard({
    super.key,
    required this.title,
    required this.position,
    required this.date,
    required this.timeRange,
    required this.onEditTitle,
    required this.onEditPosition,
    required this.onEditDate,
    required this.onEditTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= LABEL =================
        Text(
          "INTERVIEW DETAILS",
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ================= CARD =================
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.low,
          ),
          child: Column(
            children: [
              _RowItem(
                icon: PhosphorIcons.textT(),
                label: title,
                onEdit: onEditTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              _Divider(),
              const SizedBox(height: AppSpacing.sm),
              _RowItem(
                icon: PhosphorIcons.briefcase(),
                label: position,
                onEdit: onEditPosition,
              ),
              const SizedBox(height: AppSpacing.sm),
              _Divider(),
              const SizedBox(height: AppSpacing.sm),
              _RowItem(
                icon: PhosphorIcons.calendar(),
                label: date,
                onEdit: onEditDate,
              ),
              const SizedBox(height: AppSpacing.sm),
              _Divider(),
              const SizedBox(height: AppSpacing.sm),
              _RowItem(
                icon: PhosphorIcons.clock(),
                label: timeRange,
                onEdit: onEditTime,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= ROW ITEM =================
class _RowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onEdit;

  const _RowItem({
    required this.icon,
    required this.label,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSizes.md,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyStrong,
          ),
        ),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Edit",
            style: AppTextStyles.textButton,
          ),
        )
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: AppColors.border.withOpacity(0.5),
    );
  }
}
