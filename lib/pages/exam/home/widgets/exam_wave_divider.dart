// ===================== File: exam_wave_divider.dart =====================
// Purpose:
// Minimal angled divider (flat center, sloped edges)
//
// Features:
// - No gradient (solid color)
// - Angled edges (not rounded)
// - Clean modern look
// ======================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class ExamWaveDivider extends StatelessWidget {
  const ExamWaveDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(
        painter: _AngledDividerPainter(),
      ),
    );
  }
}

// ================= PAINTER =================

class _AngledDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.topicTurquoise
      ..style = PaintingStyle.fill;

    final path = Path();

    // 🔥 Sol eğimli başlangıç
    path.moveTo(0, size.height);

    // yukarı hafif eğim
    path.lineTo(16, 0);

    // düz çizgi
    path.lineTo(size.width - 16, 0);

    // sağ eğim
    path.lineTo(size.width, size.height);

    // alt kapama
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
