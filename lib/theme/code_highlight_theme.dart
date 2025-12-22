import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CodeHighlightTheme {
  CodeHighlightTheme._();

  /// flutter_highlight için ortak tema
  static const Map<String, TextStyle> theme = {
    'root': TextStyle(
      backgroundColor: AppColors.surfaceMuted,
      color: AppColors.textPrimary,
    ),
    'text': TextStyle(color: AppColors.textPrimary),
    'name': TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    'title': TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    'built_in': TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    'keyword': TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
    'string': TextStyle(
      color: AppColors.success,
    ),
    'number': TextStyle(
      color: AppColors.accentOrange,
    ),
    'comment': TextStyle(
      color: AppColors.textMuted,
      fontStyle: FontStyle.italic,
    ),
    'operator': TextStyle(
      color: AppColors.textPrimary,
    ),
  };
}
