// lib/constants/colors.dart
import 'package:flutter/material.dart';

/// Uygulamanın renk sistemi.
/// Lütfen widget içinde doğrudan Color(0xFF...) kullanma,
/// bunun yerine AppColors içindeki isimleri kullan.
class AppColors {
  AppColors._();

  // =========
  // Brand
  // =========

  /// Ana marka mavisi – butonlar, önemli iconlar, linkler.
  static const Color primary = Color(0xFF336699);

  /// Daha canlı mavi – highlight, küçük accent alanları için.
  /// Örnek: küçük chip arkaplanı, seçili durum ikonları.
  static const Color primaryAccent = Color(0xFF66C7F4);

  /// Çok yumuşak mavi-gri – hafif yüzeyler, kart arkaplanları için.
  static const Color paleSlate = Color(0xFFC1CAD6);

  /// Öne çıkan aksiyonlar veya hata ile ilgili CTA’lar için sıcak vurgu rengi.
  /// Uygulamada çok sık kullanmamaya dikkat et.
  static const Color accentOrange = Color(0xFFD34E24);

  // =========
  // Neutrals / Backgrounds
  // =========

  /// Ana sayfa arkaplanı – Airbnb / Apple tarzı temiz gri.
  static const Color background = Color(0xFFF9FAFB);

  /// Kartlar, sheet’ler, panel yüzeyleri.
  static const Color surface = Color(0xFFFFFFFF);

  /// İkincil yüzey – input arkaplanı, disabled kartlar vb.
  static const Color surfaceMuted = Color(0xFFF3F4F6);

  /// İnce border’lar, card outline, divider’lar.
  static const Color border = Color(0xFFE5E7EB);

  /// Biraz daha koyu border / ayrım gerektiğinde.
  static const Color borderStrong = Color(0xFFD1D5DB);

  // =========
  // Text
  // =========

  /// Ana metin rengi (title ve önemli textler).
  static const Color textPrimary = Color(0xFF111827);

  /// İkincil metin (açıklama, body text).
  static const Color textSecondary = Color(0xFF4B5563);

  /// Placeholder, hint veya disabled textler.
  static const Color textMuted = Color(0xFF9CA3AF);

  // =========
  // States
  // =========

  /// Başarılı durumlar, pozitif geri bildirimler.
  static const Color success = Color(0xFF10B981);

  /// Uyarı, dikkat edilmesi gereken ama kritik olmayan durumlar.
  static const Color warning = Color(0xFFF59E0B);

  /// Hatalı state, error mesajları – istersen accentOrange ile de kullanabilirsin.
  static const Color error = Color(0xFFEF4444);

  // =========
  // Difficulty Colors
  // =========

  static const Color difficultyEasy = Colors.green;
  static const Color difficultyEasyMedium = Colors.lightGreen;
  static const Color difficultyMedium = Colors.orange;
  static const Color difficultyMediumHard = Colors.deepOrange;
  static const Color difficultyHard = Colors.red;


  // =========
  // Subtle helpers (chip bg, overlay vb.)
  // =========

  /// Mavi tonlu çok yumuşak arkaplan – seçili kart, info banner vb.
  static const Color primarySoftBackground = Color(0xFFE4EDF7);

  /// Tag / chip arkaplanı için yumuşak gri.
  static const Color chipBackground = Color(0xFFE5E7EB);

  /// Hafif gölge efekti için kullanılabilecek siyah (10% opacity).
  static const Color shadow = Color(0x1A000000);
}

// SİLİNECEK BU ALTTAKİ RENKLER ŞİMDİLİK HATA ÇIKMASIN DİYE DURUYORLAR
const Color primaryColor = Color(0xFF004BA8);
const Color secondaryColor = Color(0xFFC6E7FF);

const Color headlineColor = Color(0xFFFBFBFB);

const Color pastelBlue = Color(0xFFC6E7FF);
const Color pastelBlue2 = Color(0xFFD4F6FF);


const Color prussianBlue = Color(0xFF004BA8);
const Color indigoDye = Color(0xFF284B63);
const Color ashGrey = Color(0xFFB4B8AB);
const Color ivory = Color(0xFFF4F9E9);
const Color alabaster = Color(0xFFEEF0EB);



