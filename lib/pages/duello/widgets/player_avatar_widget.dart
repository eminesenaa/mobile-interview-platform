import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ===============================================================
/// PlayerAvatarWidget
/// ---------------------------------------------------------------
/// - Sadece avatar + username gösterir.
/// - Layout bilgisi içermez.
/// - Minimal ama hafif animasyonlu.
/// ===============================================================
class PlayerAvatarWidget extends StatelessWidget {
  final String username;
  final String? avatarAsset;
  final bool highlight;
  final bool isHost;
  final bool isMe;
  final Color textColor;

  const PlayerAvatarWidget({
    super.key,
    required this.username,
    this.avatarAsset,
    this.highlight = false,
    this.isHost = false,
    this.isMe = false,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: AppDurations.normal,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlight ? Colors.white : null,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _buildAvatarImage(),
              ),
            ),
            if (isHost)
              Positioned(
                top: -AppSpacing.xl,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    PhosphorIcons.crown(PhosphorIconsStyle.fill),
                    color: Colors.white,
                    size: AppSpacing.lg,
                  ),
                ),
              ),
            if (isMe)
              Positioned(
                top: - AppSpacing.xl,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    PhosphorIcons.caretDoubleDown(PhosphorIconsStyle.bold),
                    color: Colors.white,
                    size: AppSpacing.lg,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            username.trim().isNotEmpty ? username : 'Player',
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    final bool hasAvatar =
        avatarAsset != null && avatarAsset!.trim().isNotEmpty;
    if (!hasAvatar) {
      return _buildFallback();
    }

    final isNetwork = avatarAsset!.startsWith('http');
    if (isNetwork) {
      return Image.network(
        avatarAsset!,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      return Image.asset(
        avatarAsset!,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
  }

  Widget _buildFallback() {
    final String initial = (username.trim().isNotEmpty)
        ? username.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 76,
      height: 76,
      color: Colors.white.withOpacity(0.9),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.title.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
