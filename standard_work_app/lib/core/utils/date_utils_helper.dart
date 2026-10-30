import 'package:intl/intl.dart';

class DateUtilsHelper {
  static const List<String> diasCompletos = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes'
  ];

  static const List<String> diasCortos = [
    'L',
    'M',
    'X',
    'J',
    'V'
  ];

  /// Calcula la llave de semana ISO (ejemplo: 2026-W44)
  /// Coincide con la fórmula weekKey de Mira.html
  static String getWeekKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    // Ajuste ISO-8601
    final dayOfWeek = d.weekday; // 1: Lun, 7: Dom
    final thursday = d.add(Duration(days: 4 - dayOfWeek));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    final weekNumber = ((thursday.difference(firstDayOfYear).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Retorna el día de la semana laboral (1 = Lunes, 5 = Viernes)
  /// Si es sábado o domingo, devuelve 1 (Lunes) por defecto tal como en Mira.html
  static int getWorkDayNumber([DateTime? date]) {
    final d = date ?? DateTime.now();
    final wd = d.weekday;
    if (wd >= 1 && wd <= 5) {
      return wd;
    }
    return 1;
  }

  static String formatFechaCompleta(DateTime date) {
    try {
      return DateFormat("d 'de' MMMM 'de' y", 'es_CO').format(date);
    } catch (_) {
      // Fallback si no está inicializado locale
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String getNombreMes(DateTime date) {
    try {
      return DateFormat("MMMM", 'es_CO').format(date);
    } catch (_) {
      const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
      return meses[date.month - 1];
    }
  }
}
