// core/theme/kaze_theme.dart
// Dark Theme con estética de productor musical.
// Colores primarios: morado profundo + acento neón cyan.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class KazeTheme {
  static const Color _primary       = Color(0xFF9C27B0); // Morado
  static const Color _primaryDark   = Color(0xFF6A0080); // Morado oscuro
  static const Color _accent        = Color(0xFF00E5FF); // Neón Cyan
  static const Color _accentGreen   = Color(0xFF69FF47); // Neón Verde (highlight)
  static const Color _surface       = Color(0xFF12121E); // Fondo profundo
  static const Color _surfaceVariant = Color(0xFF1E1E30); // Cards/panels
  static const Color _onSurface     = Color(0xFFE0E0E0); // Texto principal
  static const Color _onSurfaceSub  = Color(0xFF9E9E9E); // Texto secundario
  static const Color _error         = Color(0xFFFF5252); // Error neón rojo

  /// Acceso público para widgets que necesiten los colores directamente.
  static const Color neonCyan    = _accent;
  static const Color neonGreen   = _accentGreen;
  static const Color deepPurple  = _primary;
  static const Color cardSurface = _surfaceVariant;
  static const Color errorColor  = _error;
  static final ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary:           _primary,
    onPrimary:         Colors.white,
    primaryContainer:  _primaryDark,
    onPrimaryContainer: _accent,
    secondary:         _accent,
    onSecondary:       Colors.black,
    secondaryContainer: const Color(0xFF003C4A),
    onSecondaryContainer: _accent,
    tertiary:          _accentGreen,
    onTertiary:        Colors.black,
    error:             _error,
    onError:           Colors.black,
    surface:           _surface,
    onSurface:         _onSurface,
    surfaceContainerHighest: _surfaceVariant,
    outline:           const Color(0xFF3A3A5C),
    outlineVariant:    const Color(0xFF2A2A45),
    shadow:            Colors.black,
    scrim:             Colors.black87,
    inverseSurface:    _onSurface,
    onInverseSurface:  _surface,
    inversePrimary:    _primaryDark,
  );
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: _surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor:    _onSurface,
        displayColor: _onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _accent,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: _accent),
      ),
      cardTheme: CardThemeData(
        color: _surfaceVariant,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E2E50), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: _accent,
        textColor: _onSurface,
        subtitleTextStyle: TextStyle(color: _onSurfaceSub, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        labelStyle: const TextStyle(color: _onSurfaceSub),
        hintStyle: const TextStyle(color: Color(0xFF5C5C7A)),
        prefixIconColor: _accent,
        suffixIconColor: _accent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: _primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 1.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accent,
          side: const BorderSide(color: _accent),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _accent),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        selectedColor: _primaryDark,
        labelStyle: const TextStyle(color: _onSurface, fontSize: 12),
        side: const BorderSide(color: Color(0xFF3A3A5C)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A45),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceVariant,
        contentTextStyle: const TextStyle(color: _onSurface),
        actionTextColor: _accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
