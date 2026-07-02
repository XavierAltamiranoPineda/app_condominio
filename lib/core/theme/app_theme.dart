import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño Material 3 para CondoAdmin
/// Paleta: Azul pizarra + Blanco puro — Alto contraste, legibilidad garantizada
class AppTheme {
  // ─── Nueva Paleta de Colores (Alto Contraste / Dark Mode by default) ───
  static const Color primaryColor = Color(0xFFF59E0B);      // Ámbar (Botones/Activos)
  static const Color primaryLight = Color(0xFFFBBF24);      // Ámbar claro (Amber 400)
  static const Color primaryDark  = Color(0xFFD97706);      // Ámbar oscuro
  static const Color backgroundColor = Color(0xFF0B0F19);   // Fondo principal
  static const Color surfaceColor = Color(0xFF1E293B);      // Bloques / Cards / Inputs
  static const Color textPrimary  = Color(0xFFF8FAFC);      // Blanco azulado (Texto principal)
  static const Color textSecondary = Color(0xFF94A3B8);     // Gris azulado (Texto secundario)
  static const Color borderColor  = Color(0xFF334155);      // Bordes sutiles

  // ─── Colores de Estado (Semánticos) ──────────────────────────
  static const Color successColor = Color(0xFF10B981);      // Emerald 500
  static const Color errorColor   = Color(0xFFEF4444);      // Red 500
  static const Color warningColor = Color(0xFFF59E0B);      // Amber 500 (Alias de primary)
  static const Color infoColor    = Color(0xFF3B82F6);      // Blue 500
  static const Color accentColor  = Color(0xFF8B5CF6);      // Violet 500 (Para distinción visual)

  // ─── ColorScheme ──────────────────────────────────────────────
  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: primaryColor,
    onPrimary: backgroundColor, // Alto contraste solicitado
    secondary: primaryColor,
    surface: surfaceColor,
    onSurface: textPrimary,
    error: errorColor,
    onError: Colors.white,
  );

  // ─── Tema (Aplicado a toda la app) ─────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: backgroundColor,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Sin borde solicitado
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary.withOpacity(0.5)),
        floatingLabelStyle: GoogleFonts.inter(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor, // Texto en fondo oscuro
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: Colors.transparent, // Personalizado por iconos
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.inter(fontSize: 12, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor, size: 26);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
    );
  }

  // Alias para mantener compatibilidad si se usa lightTheme
  static ThemeData get lightTheme => darkTheme;
}
