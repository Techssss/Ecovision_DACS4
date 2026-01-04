import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Định nghĩa text styles cho toàn app
class AppTextStyles {
  static TextStyle get appBarTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get appBarSubtitle => GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white70,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white70,
      );

  static TextStyle get aqiNumber => GoogleFonts.inter(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get recommendationTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      );

  static TextStyle get recommendationTime => GoogleFonts.inter(
        fontSize: 12,
        color: Colors.black54,
      );

  static TextStyle get statusBadge => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}
