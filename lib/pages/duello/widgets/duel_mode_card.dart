import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';

enum CardPosition { top, middle, bottom }

class DuelModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final CardPosition position;

  const DuelModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: DiagonalCardClipper(position),
          child: Material(
            color: color,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 220,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: position == CardPosition.top
                          ? 24
                          : position == CardPosition.middle
                          ? 40
                          : 50,
                    ),
                    Text(
                      title,
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// BIG ICON (Artık clip dışında!)
        Positioned(
          right: 26,
          bottom: 50,
          child: Icon(
            icon,
            size: 126,
            color: Colors.white.withOpacity(0.10),
          ),
        ),
      ],
    );
  }
}

class DiagonalCardClipper extends CustomClipper<Path> {
  final CardPosition position;

  DiagonalCardClipper(this.position);

  @override
  Path getClip(Size size) {
    const cut = 50.0;
    final path = Path();

    switch (position) {
      case CardPosition.top:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - cut);
        path.lineTo(0, size.height);
        break;

      case CardPosition.middle:
        path.moveTo(0, cut);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - cut);
        path.lineTo(0, size.height);
        break;

      case CardPosition.bottom:
        path.moveTo(0, cut);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
