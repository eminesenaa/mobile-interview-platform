import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../utils/avatar_utils.dart';

class AppAvatar extends StatelessWidget {
  final String? avatarPath;
  final String name;
  final String surname;
  final double size;

  const AppAvatar({
    super.key,
    required this.avatarPath,
    required this.name,
    required this.surname,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final path = avatarPath ?? '';
    final isEmpty = path.isEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEmpty ? AvatarUtils.getColor(name) : null,
        image: !isEmpty
            ? DecorationImage(
                image: avatarPath!.startsWith('http')
                    ? NetworkImage(avatarPath!)
                    : AssetImage(avatarPath!) as ImageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: isEmpty ? _buildInitials() : null,
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        AvatarUtils.getInitials(name, surname),
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
