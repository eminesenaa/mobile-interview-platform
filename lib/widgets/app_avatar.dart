import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

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
        color: isEmpty ? _avatarColor(name) : null,
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
    final n = name.isNotEmpty ? name[0] : '';
    final s = surname.isNotEmpty ? surname[0] : '';

    return Center(
      child: Text(
        (n + s).toUpperCase(),
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _avatarColor(String seed) {
    final colors = [
      AppColors.cinnabar,
      AppColors.accentWinePlum,
      AppColors.accentRoyalPlum,
      AppColors.stormyTeal,
      AppColors.accentCeladon,
      AppColors.accentSpicyOrange,
      AppColors.honeyBronze,
    ];

    final index = seed.codeUnits.fold(0, (a, b) => a + b) % colors.length;

    return colors[index];
  }
}
