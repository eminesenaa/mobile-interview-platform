// lib/constants/colors.dart
import 'package:flutter/material.dart';

/// Uygulamanın renk sistemi.
/// Lütfen widgets içinde doğrudan Color(0xFF...) kullanma,
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
  // Text (Light variants for dark backgrounds)
  // =========
  static const Color textLightPrimary = Color(0xFFF4F6FA);

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

  static const Color difficultyEasy = Color(0xFF4CAF50);
  static const Color difficultyEasyMedium = Color(0xFFFFD54F);
  static const Color difficultyMedium = Color(0xFFFF9800);
  static const Color difficultyMediumHard = Color(0xFFFF5722);
  static const Color difficultyHard = Color(0xFFF44336);

  // =========
  // Subtle helpers (chip bg, overlay vb.)
  // =========

  /// Mavi tonlu çok yumuşak arkaplan – seçili kart, info banner vb.
  static const Color primarySoftBackground = Color(0xFFE4EDF7);

  /// Tag / chip arkaplanı için yumuşak gri.
  static const Color chipBackground = Color(0xFFE5E7EB);

  /// Hafif gölge efekti için kullanılabilecek siyah (10% opacity).
  static const Color shadow = Color(0x1A000000);

  // =========
  // Topic Chart Colors (Result Analytics – Blue/Turquoise Palette)
  // =========
  // Used ONLY for exam result topic charts.
  // Chosen to be fresh, readable, and non-distracting.
  // Ordered from deep → light for visual balance.

  /// Deep Twilight – strong, high-focus topics
  static const Color topicDeepTwilight = Color(0xFF03045E);

  /// Bright Teal Blue – primary analytical topics
  static const Color topicBrightTeal = Color(0xFF0077B6);

  /// Turquoise Surf – secondary topics
  static const Color topicTurquoise = Color(0xFF00B4D8);

  /// Frosted Blue – low activity / partial topics
  static const Color topicFrostedBlue = Color(0xFF90E0EF);

  /// Light Cyan – background / minimal contribution topics
  static const Color topicLightCyan = Color(0xFFCAF0F8);

  // =========
  // Extended Accent Palette (UI Cards, Charts, Gamification)
  // =========
  // Bu renkler:
  // - Duel kategori kartları
  // - Skor chart'ları
  // - Gamification badge'leri
  // - Topic görselleştirmeleri
  // için kullanılabilir.
  // Ama brand primary'nin önüne geçmemeli.

  /// Baltic Blue – güçlü ama sakin mavi
  static const Color cinnabar = Color(0xFFf0544f);

  /// Wine Plum – koyu mor/bordo ton (rekabet hissi için ideal)
  static const Color accentWinePlum = Color(0xFF5B2333);

  /// Royal Plum
  static const Color accentRoyalPlum = Color(0xFF8c1a6a);

  /// White Smoke – açık nötr arka plan
  static const Color stormyTeal = Color(0xFF0d5d56);

  /// Celadon – soft yeşil (denge, başarı, growth)
  static const Color accentCeladon = Color(0xFFA6D49F);

  /// Spicy Orange – enerjik vurgu rengi
  static const Color accentSpicyOrange = Color(0xFFD34E24);

  static const Color honeyBronze = Color(0xFFf6ae2d);

  /// Evergreen – derin koyu yeşil (advanced / system temaları için)
  static const Color accentEvergreen = Color(0xFF14342B);

  /// Chery Blossom
  static const Color cherryBlossom = Color(0xFFfcb0b3);

  /// Strawberry Red
  static const Color strawberryRed = Color(0xFFf93943);

  /// Sky Reflection
  static const Color skyReflection = Color(0xFF445e93);

  /// Dark Cyan
  static const Color darkCyan = Color(0xFF129490);






}
