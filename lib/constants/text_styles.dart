// lib/constants/text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Uygulamanın tipografi sistemi.
/// Her yerde doğrudan TextStyle tanımlamak yerine
/// buradaki stilleri kullanmaya çalış.
class AppTextStyles {
  AppTextStyles._();

  // =====================
  //  Display / Headings
  // =====================

  /// Ana sayfa başlıkları (ör: "Practice", "Dashboard" vb.)
  /// Manrope ile biraz karakter katıyoruz.
  static final TextStyle displayLarge = GoogleFonts.manrope(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Bölüm başlıkları (ör: "Today’s question", "Topics", "Progress")
  static final TextStyle headline = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Kart başlıkları, list item title'lar
  static final TextStyle title = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // =====================
  //  Body Text
  // =====================

  /// Ana gövde metni – açıklamalar, paragraflar.
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Bir tık daha vurgulu gövde metni (ör: kısa özetler).
  static final TextStyle bodyStrong = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Daha küçük açıklama / helper text (ör: input altı açıklama).
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textMuted,
  );

  /// Soru açıklaması (question text)
  static final TextStyle questionText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );


  // =====================
  //  Buttons & Chips
  // =====================

  /// Primary buton yazısı (CTA).
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: Colors.white,
  );

  /// İkincil buton / text button (mavi yazılı, arka planı şeffaf).
  static final TextStyle textButton = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.primary,
  );

  /// Tag / chip üzerindeki yazılar.
  static final TextStyle chip = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.primary,
  );

  // =====================
  //  Labels & Misc
  // =====================

  /// Küçük, ikincil metin (örneğin metadata, tarih, alt açıklama)
  static final caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Küçük badge/rozet yazıları (ör: difficulty chip)
  static final TextStyle badgeLabel = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  /// Küçük label'lar (ör: "Difficulty", "Topic", section üstü minik text).
  static final TextStyle label = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  /// Link benzeri metinler (ör: "See all", "View details").
  static final TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
    color: AppColors.primary,
  );

  /// Hata mesajı text'i.
  static final TextStyle error = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.error,
  );

  // =====================
  //  Flutter Theme ile kullanmak için helper
  // =====================

  /// İstersen ThemeData.textTheme içine geçmek için kullanabilirsin.
  static TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      headlineSmall: headline,
      titleMedium: title,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: button,
      labelSmall: label,
    );
  }
}
