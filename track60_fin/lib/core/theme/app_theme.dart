import 'package:flutter/material.dart';

class AppColors {
  // Primarios Darnel Group
  static const Color azul = Color(0xFF002F6C);        // Azul corporativo principal
  static const Color azulOscuro = Color(0xFF001F47);  // Azul noche / fondo contrastes
  static const Color azulMedio = Color(0xFF0284C7);   // Cyan / Azul operativo planta
  static const Color azul2 = Color(0xFF0284C7);       // Alias compatible
  static const Color morado = Color(0xFF7C3AED);      // Púrpura Suite Ejecutiva Superadmin
  static const Color moradoOscuro = Color(0xFF4C1D95);
  static const Color moradoClaro = Color(0xFFF5F3FF);

  // Semánticos Operativos
  static const Color verde = Color(0xFF16A34A);       // Cumplido / Aprobado
  static const Color verdeClaro = Color(0xFFDCFCE7);
  static const Color rojo = Color(0xFFDC2626);        // Alerta / Vencido / Notificación
  static const Color rojoClaro = Color(0xFFFEE2E2);
  static const Color amarillo = Color(0xFFD97706);    // Pendiente / Requiere Corrección
  static const Color amarilloClaro = Color(0xFFFEF3C7);

  // Neutros y Estructura
  static const Color bg = Color(0xFFF8FAFC);          // Fondo claro general
  static const Color superficie = Color(0xFFFFFFFF);  // Tarjetas y modales
  static const Color borde = Color(0xFFE2E8F0);       // Separadores limpios
  static const Color txt = Color(0xFF0F172A);         // Texto principal (Slate 900)
  static const Color txtSec = Color(0xFF475569);      // Texto secundario (Slate 600)
  static const Color gris = Color(0xFF64748B);        // Texto tenue / íconos
  static const Color grisClaro = Color(0xFFF1F5F9);
}

/// Sombras y decoraciones 3D con relieve industrial
class App3D {
  static List<BoxShadow> cardShadow({Color? baseColor, double depth = 6}) {
    final c = baseColor ?? const Color(0xFF002F6C);
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.08),
        blurRadius: depth * 2.5,
        offset: Offset(0, depth),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.9),
        blurRadius: 1,
        offset: const Offset(0, -1),
      ),
    ];
  }

  static List<BoxShadow> buttonShadow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.25),
        blurRadius: 2,
        offset: const Offset(0, -1),
      ),
    ];
  }

  static BoxDecoration embossedCard({Color bgColor = Colors.white, Color borderColor = const Color(0xFFE2E8F0)}) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
      boxShadow: cardShadow(),
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azul,
        primary: AppColors.azul,
        secondary: AppColors.azulMedio,
        surface: AppColors.superficie,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borde),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.azul, width: 1.5),
        ),
      ),
    );
  }
}

