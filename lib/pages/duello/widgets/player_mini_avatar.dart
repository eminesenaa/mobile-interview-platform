import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../utils/avatar_utils.dart';

class PlayerMiniAvatar extends StatelessWidget {
  final String username;
  final String? avatarAsset;
  final bool isMe;
  final bool isLeader;

  const PlayerMiniAvatar({
    super.key,
    required this.username,
    this.avatarAsset,
    this.isMe = false,
    this.isLeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isMe ? 42.0 : 36.0;

    return AnimatedScale(
      duration: AppDurations.normal,
      scale: isMe ? 1.08 : 1.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          /// ✨ CLEAN ME HIGHLIGHT (NO GLOW SPREAD)
          if (isMe)
            Container(
              width: size + 4,
              height: size + 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 2,
                ),
              ),
            ),
          /// 🟢 MAIN AVATAR
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                width: isMe ? 3 : 2,
              ),
            ),
            child: ClipOval(
              child: _buildAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarAsset != null && avatarAsset!.isNotEmpty) {
      if (avatarAsset!.startsWith('http')) {
        return Image.network(
          avatarAsset!,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          avatarAsset!,
          fit: BoxFit.cover,
        );
      }
    }

    return Container(
      color: AvatarUtils.getColor(username),
      alignment: Alignment.center,
      child: Text(
        AvatarUtils.getInitials(username),
        style: AppTextStyles.bodyStrong.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
