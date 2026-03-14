import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final display = GoogleFonts.sora(
    fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static final h1 = GoogleFonts.sora(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static final h2 = GoogleFonts.sora(
    fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  static final body = GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.6);

  static final label = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, letterSpacing: 0.5);

  static final button = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.0);

  static final mono = GoogleFonts.jetBrainsMono(
    fontSize: 14, color: AppColors.textPrimary);
}
