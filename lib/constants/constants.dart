// lib/constants/constants.dart

// Tüm constant dosyalarını tek yerden export ederek
// diğer dosyalarda import karmaşasını azaltıyoruz.
import 'package:flutter/material.dart';

export 'colors.dart';
export 'text_styles.dart';

/// Uygulamanın temel sabit değerleri.
/// Spacing, radius, durations gibi UI ile ilgili
/// her şeyi buradan yönetmek çok daha profesyonel bir yaklaşım.
///
/// Not:
/// Widget içinde 16, 20 gibi “magic number” kullanmamaya çalış.
/// Onların yerine AppSpacing.md, AppRadius.lg gibi değerleri kullan.
class AppConstants {
  AppConstants._();
}

// ===========================
//  Spacing System (8pt Grid)
// ===========================

/// UI tasarımlarında kullanılan 8px grid sistemine göre spacing değerleri.
/// Airbnb, Apple ve modern arayüzlerde bu sistem özellikle kullanılıyor.
///
/// sm  = 8
/// md  = 16
/// lg  = 24
/// xl  = 32
/// xxl = 40
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

// ===========================
//  Border Radius
// ===========================

/// Kart yapıları, butonlar ve container'lar için radius değerleri.
/// Airbnb tarzı için yuvarlatmalar genelde 12–16px arasıdır.
class AppRadius {
  AppRadius._();

  // Core radius scale
  static const double xs = 6.0;   // en küçük
  static const double sm = 8.0;   // küçük kart, input field
  static const double md = 12.0;  // standart kart
  static const double lg = 16.0;  // büyük kartlar
  static const double xl = 24.0;  // special components

  /// Chips, tags, pill shape
  static const double pill = 999.0;

  /// Çok yuvarlak öğeler (örneğin Solve Now butonu)
  static const double round = 40.0;
}

// ===========================
//  Shadows
// ===========================

/// Minimal gölge yapıları.
/// Apple tarzı çok hafif shadow kullanır.
/// Material design’daki gibi ağır gölge istemediğimiz için low/medium veriyoruz.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x11000000), // %7 black shadow
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000), // %10 black shadow
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

// ===========================
//  Durations (Animation Speeds)
// ===========================

/// Animasyon süresi sabitleri.
/// Apple ve Airbnb gibi “smooth” animasyon için ideal hızlar.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}

// ===========================
//  Icon Sizes
// ===========================

class AppIconSizes {
  AppIconSizes._();

  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 30.0;
}

// ===========================
//  Elevation / z-index
// ===========================

class AppZIndex {
  AppZIndex._();

  static const double card = 1;
  static const double floatingButton = 10;
  static const double modal = 20;
}
