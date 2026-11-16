class DateUtilsHelper {
  static const List<String> diasSemana = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE'];
  static const List<String> diasCompletos = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  static const List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  /// Retorna 1..5 para Lunes..Viernes (o 1 si es fin de semana)
  static int getWorkDayNumber([DateTime? dt]) {
    final now = dt ?? DateTime.now();
    final weekday = now.weekday; // 1 = Lunes, 7 = Domingo
    if (weekday >= 1 && weekday <= 5) return weekday;
    return 1; // Fallback a lunes en fin de semana
  }

  static String getDayName(int dayNumber) {
    if (dayNumber >= 1 && dayNumber <= 5) {
      return diasCompletos[dayNumber - 1];
    }
    return 'Lunes';
  }

  static String formatTime(String timeStr) {
    return timeStr.trim();
  }
}

