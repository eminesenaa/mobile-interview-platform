// ===================== File: lib/widgets/get_started_card.dart =====================
// Purpose: Practice sayfasının üst kısmında görünen "Get Started" kartını temsil eder.
//          İçinde bir görsel (assets/images/...), üstüne gradient/overlay ve
//          kısa bir yönlendirme mesajı barındırabilir.
//
// Kullanım:
// - PracticePage içinde:  GetStartedCard(imagePath: "assets/images/get_started_1.png")
// ================================================================================
import 'package:flutter/material.dart';

class GetStartedCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const GetStartedCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.3), // yazı okunurluğu için
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}