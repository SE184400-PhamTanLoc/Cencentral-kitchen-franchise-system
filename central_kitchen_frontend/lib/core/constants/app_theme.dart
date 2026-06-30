import 'package:flutter/material.dart';

/// Lớp cấu hình hệ thống giao diện (Theme, Màu sắc, Kiểu chữ) cho ứng dụng.
/// Được thiết kế dựa trên đặc tả trong file DESIGN.md và code.html của dự án.
class AppTheme {
  // --- BẢNG MÀU CHỦ ĐẠO (Brand Colors từ Google Stitch) ---
  static const Color primary = Color(0xFF001142);
  static const Color primaryContainer = Color(0xFF00236F);
  static const Color secondary = Color(0xFF085AC0);
  static const Color secondaryContainer = Color(0xFF5B94FD);
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEFEDF4);
  
  static const Color onSurface = Color(0xFF1A1B20);
  static const Color onSurfaceVariant = Color(0xFF444651);
  static const Color outline = Color(0xFF757682);
  static const Color outlineVariant = Color(0xFFC5C5D3);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // --- CẤU HÌNH THEME DATA CHO FLUTTER ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
      ),
      
      // Kiểu chữ mặc định (Font mặc định là Inter)
      fontFamily: 'Inter',
      
      // Định nghĩa AppBar Theme tối giản theo Stitch
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      ),

      // Định nghĩa Card Theme phẳng, bo góc 16px, viền 1px
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),

      
      // Định nghĩa Text Theme
      textTheme: const TextTheme(
        // display-lg
        displayLarge: TextStyle(
          fontSize: 48.0,
          fontWeight: FontWeight.w700,
          height: 56 / 48,
          letterSpacing: -0.02 * 48,
          color: primary,
        ),
        // headline-lg
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
          letterSpacing: -0.01 * 32,
          color: primary,
        ),
        // title-lg
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          height: 28 / 22,
          color: primary,
        ),
        // title-md
        titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          color: primary,
        ),
        // body-lg
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: onSurface,
        ),
        // body-md
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: onSurfaceVariant,
        ),
        // label-lg
        labelLarge: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: onSurfaceVariant,
        ),
        // label-sm
        labelSmall: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          height: 16 / 11,
          letterSpacing: 0.5,
          color: outline,
        ),
      ),
      
      // Cấu hình Input Decoration (Trang trí cho các TextField) - Bo góc 8px theo Stitch
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
        hintStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: outline,
        ),
      ),
      
      // Cấu hình cho Nút chính (ElevatedButton) - Bo góc 8px theo Stitch
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
