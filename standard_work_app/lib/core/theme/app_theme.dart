import 'package:flutter/material.dart';

/// Paleta de colores oficial de Standard Work · Darnel Group
/// Extraída con precisión milimétrica del CSS de Mira.html
class AppColors {
  // Primarios corporativos
  static const Color azul = Color(0xFF002F6C);       // var(--azul)
  static const Color azul2 = Color(0xFF006DB2);      // var(--azul2)
  static const Color morado = Color(0xFF0095D9);     // var(--morado) - azul cian dinámico
  static const Color bg = Color(0xFFF3F5FA);         // var(--bg)
  static const Color phoneFrame = Color(0xFF0F172A); // Marco exterior simulador

  // Estados
  static const Color verde = Color(0xFF16A34A);      // var(--verde)
  static const Color verdeBg = Color(0xFFECFDF3);    // var(--verdeBg)
  static const Color rojo = Color(0xFFDC2626);       // var(--rojo)
  static const Color rojoBg = Color(0xFFFEF2F2);     // var(--rojoBg)

  // Grises y neutros
  static const Color gris = Color(0xFF64748B);       // var(--gris)
  static const Color borde = Color(0xFFE2E8F0);      // var(--borde)
  static const Color txt = Color(0xFF4A4A49);        // var(--txt)
  static const Color barraVerde = Color(0xFF4ADE80); // Color de la barra de progreso activa

  // Gradientes oficiales
  static const LinearGradient gradienteLogin = LinearGradient(
    begin: Alignment(-0.6, -1.0),
    end: Alignment(0.6, 1.0),
    colors: [azul, morado],
  );

  static const LinearGradient gradienteHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azul, morado],
  );

  static const LinearGradient gradienteFab = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azul2, morado],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azul,
        primary: AppColors.azul,
        secondary: AppColors.azul2,
        tertiary: AppColors.morado,
        surface: AppColors.bg,
        error: AppColors.rojo,
      ),
      fontFamily: 'Roboto', // Soporte estándar móvil fluido y limpio
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azul,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borde, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.azul2, width: 2.0),
        ),
      ),
    );
  }
}
