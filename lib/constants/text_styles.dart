import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  static final TextStyle headline = GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: indigoDye,
  );

  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: indigoDye,
  );

  static final TextStyle body = GoogleFonts.nunito(
    fontSize: 14,
    color: Colors.black87,
  );

  static final TextStyle link = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );
}
