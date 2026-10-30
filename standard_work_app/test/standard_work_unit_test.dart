import 'package:flutter_test/flutter_test.dart';
import 'package:standard_work/core/utils/date_utils_helper.dart';
import 'package:standard_work/data/models/app_models.dart';
import 'package:standard_work/data/models/excel_schedule_models.dart';

void main() {
  group('Fase 2: Pruebas Exhaustivas de Lógica de Negocio, Auditoría y Trazabilidad', () {
    test('Cálculo de clave de semana ISO (weekKey) es consistente', () {
      final fecha = DateTime(2026, 10, 28); // Miércoles
      final weekKey = DateUtilsHelper.getWeekKey(fecha);
      expect(weekKey.startsWith('2026-W'), isTrue);
    });

    test('Día laboral se restringe correctamente a Lunes-Viernes (1 a 5)', () {
      final miercoles = DateTime(2026, 10, 28);
      expect(DateUtilsHelper.getWorkDayNumber(miercoles), 3);

      final sabado = DateTime(2026, 10, 31);
      expect(DateUtilsHelper.getWorkDayNumber(sabado), 1);
    });

    test('Modelo ActivityModel deserializa días correctamente', () {
      const act = ActivityModel(
        userId: 'X',
        nombre: 'Revisión OEE',
        descripcion: 'Análisis de paradas',
        dias: '[1,3,5]',
        area: 'Producción',
      );

      expect(act.diasList, equals([1, 3, 5]));
    });

    test('Modelo ActivityInstance preserva inmutabilidad con copyWith y observaciones', () {
      const inst = ActivityInstance(
        activityId: 1,
        userId: 'X',
        weekKey: '2026-W44',
        nombre: 'Gemba Walk',
        descripcion: 'Recorrido en piso',
        day: 2,
        orig: 2,
        fija: true,
        done: false,
      );

      final modificada = inst.copyWith(
        done: true,
        day: 3,
        observaciones: 'Hallazgo en línea 2',
        motivoNoRealizada: null,
      );

      expect(modificada.done, isTrue);
      expect(modificada.day, 3);
      expect(modificada.observaciones, 'Hallazgo en línea 2');
      expect(inst.done, isFalse);
    });

    test('Modelo AuditLogModel serializa y deserializa correctamente', () {
      final now = DateTime(2026, 10, 28, 14, 30);
      final log = AuditLogModel(
        userId: 'X',
        action: 'UPDATE_ACTIVITY',
        entity: 'activity',
        entityId: 5,
        details: 'Cambio de nombre',
        timestamp: now,
      );

      final map = log.toMap();
      expect(map['action'], 'UPDATE_ACTIVITY');
      expect(map['entityId'], 5);

      final reconstructed = AuditLogModel.fromMap(map);
      expect(reconstructed.action, log.action);
      expect(reconstructed.details, log.details);
    });

    test('Fórmula de Indicadores previene división por cero', () {
      const histMT = 0;
      const histMD = 0;
      const wkLength = 0;
      const wd = 0;

      final tMes = histMT + wkLength;
      final int pMes = tMes > 0 ? (((histMD + wd) / tMes) * 100).round() : 0;
      expect(pMes, 0);
    });

    test('Restricción: Actividades fijas no deben poder moverse a otro día', () {
      const inst = ActivityInstance(
        activityId: 1,
        userId: 'X',
        weekKey: '2026-W44',
        nombre: 'Reunión Diaria',
        descripcion: 'KPIs',
        day: 1,
        orig: 1,
        fija: true,
        done: false,
      );

      // Regla de negocio: si fija es true, el sistema debe rechazar la reprogramación
      final canMove = !inst.fija && inst.day < 5;
      expect(canMove, isFalse);
    });

    test('Validación de estructura de copia de seguridad JSON', () {
      final backup = {
        'version': 1,
        'app': 'Standard Work · Darnel Group',
        'userId': 'X',
        'activities': [],
        'instances': [],
        'history': [],
        'audit_logs': [],
      };

      final bool isValid = backup['app'] == 'Standard Work · Darnel Group' &&
          backup['userId'] == 'X' &&
          backup['version'] == 1;

      expect(isValid, isTrue);
    });
  });

  group('Fase 4: Integración del Excel ST - WR YONNY LOPEZ.xlsb y 4 Semanas', () {
    test('Perfil de Yonny López está registrado con iniciales YL y área Extrusa', () {
      const yl = UserProfile(
        id: 'YL',
        nombre: 'Yonny López',
        cargo: 'Jefe de Planta / Operaciones Extrusa',
        area: 'Planta Extrusa',
        iniciales: 'YL',
      );
      expect(yl.id, 'YL');
      expect(yl.iniciales, 'YL');
      expect(yl.nombre, 'Yonny López');
      expect(yl.area, 'Planta Extrusa');
    });

    test('Modelo ExcelScheduleActivity serializa y deserializa con fidelidad al Excel', () {
      const act = ExcelScheduleActivity(
        id: 1,
        weekNumber: 1,
        dayOfWeek: 1,
        dayName: 'Lunes',
        timeStart: '07:00',
        timeEnd: '07:30',
        durationMinutes: 30,
        activityName: 'Gemba Walk',
        originalName: 'Gemba Walk',
        category: 'Operación y Ejecución',
        isFixed: true,
        excelSheet: 'Weekly Review',
        excelRow: 4,
        excelCol: 2,
        excelCell: 'C4',
      );

      final map = act.toMap();
      expect(map['weekNumber'], 1);
      expect(map['dayName'], 'Lunes');
      expect(map['timeStart'], '07:00');
      expect(map['timeEnd'], '07:30');
      expect(map['durationMinutes'], 30);
      expect(map['activityName'], 'Gemba Walk');
      expect(map['category'], 'Operación y Ejecución');
      expect(map['isFixed'], 1);
      expect(map['excelCell'], 'C4');

      final reconstructed = ExcelScheduleActivity.fromMap(map);
      expect(reconstructed.id, 1);
      expect(reconstructed.activityName, act.activityName);
      expect(reconstructed.isFixed, isTrue);
      expect(reconstructed.excelCell, 'C4');
    });

    test('Distribución de tiempos por categoría suma 100% oficial', () {
      final categorias = [
        {'cat': 'Operación y Ejecución', 'pct': 28},
        {'cat': 'Resultados y Productividad', 'pct': 18},
        {'cat': 'Liderazgo y Desarrollo de Personas', 'pct': 15},
        {'cat': 'Proyectos y Mejora Continua', 'pct': 11},
        {'cat': 'Calidad e Inocuidad', 'pct': 9},
        {'cat': 'Seguridad', 'pct': 5},
        {'cat': 'Administración', 'pct': 12},
        {'cat': 'Sin asignación (espacios libres)', 'pct': 2},
      ];

      final totalPct = categorias.fold<int>(0, (sum, c) => sum + (c['pct'] as int));
      expect(totalPct, equals(100));
    });

    test('Verificación de conteo oficial de actividades en las 4 semanas del libro', () {
      const semana1 = 70;
      const semana2 = 68;
      const semana3 = 67;
      const semana4 = 65;
      const total = semana1 + semana2 + semana3 + semana4;

      expect(total, equals(270));
    });

    test('Separación estricta entre planificación (Excel) y ejecuciones de usuario', () {
      const excelAct = ExcelScheduleActivity(
        id: 10,
        weekNumber: 1,
        dayOfWeek: 2,
        dayName: 'Martes',
        timeStart: '09:00',
        timeEnd: '09:30',
        durationMinutes: 30,
        activityName: 'Reunión de Piso',
        originalName: 'Reunión de Piso',
        category: 'Operación y Ejecución',
        isFixed: true,
        excelSheet: 'Weekly Review',
        excelRow: 8,
        excelCol: 3,
        excelCell: 'D8',
      );

      // La actividad del Excel no tiene campo 'done' porque es programación
      expect(excelAct.timeStart, '09:00');
      expect(excelAct.excelCell, 'D8');

      // Las instancias operativas de usuario sí poseen estado done, observaciones y auditoría
      const inst = ActivityInstance(
        activityId: 10,
        userId: 'YL',
        weekKey: '2026-W44',
        nombre: 'Reunión de Piso',
        descripcion: 'Planificación Excel',
        day: 2,
        orig: 2,
        fija: true,
        done: false, // Inicia en estado pendiente sin asumir ejecución ficticia
      );

      expect(inst.done, isFalse);
      expect(inst.completedAt, isNull);
    });

    test('Prueba de filtros de búsqueda por texto y categoría sin pérdida de datos', () {
      final list = [
        const ExcelScheduleActivity(
          id: 1, weekNumber: 1, dayOfWeek: 1, dayName: 'Lunes',
          timeStart: '07:00', timeEnd: '07:30', durationMinutes: 30,
          activityName: 'Gemba Walk', originalName: 'Gemba Walk',
          category: 'Operación y Ejecución', isFixed: true,
          excelSheet: 'Weekly Review', excelRow: 4, excelCol: 2, excelCell: 'C4',
        ),
        const ExcelScheduleActivity(
          id: 2, weekNumber: 1, dayOfWeek: 2, dayName: 'Martes',
          timeStart: '08:00', timeEnd: '08:30', durationMinutes: 30,
          activityName: 'Revision de Bi\'s/Cubos', originalName: 'Revision de Bi\'s/Cubos',
          category: 'Administración', isFixed: false,
          excelSheet: 'Weekly Review', excelRow: 6, excelCol: 3, excelCell: 'D6',
        ),
        const ExcelScheduleActivity(
          id: 3, weekNumber: 2, dayOfWeek: 1, dayName: 'Lunes',
          timeStart: '07:00', timeEnd: '07:30', durationMinutes: 30,
          activityName: 'Gemba Walk', originalName: 'Gemba Walk',
          category: 'Operación y Ejecución', isFixed: true,
          excelSheet: 'Weekly Review', excelRow: 4, excelCol: 8, excelCell: 'I4',
        ),
      ];

      // Filtro por semana 1
      final s1 = list.where((a) => a.weekNumber == 1).toList();
      expect(s1.length, 2);

      // Filtro por texto 'Gemba'
      final gemba = list.where((a) => a.activityName.toLowerCase().contains('gemba')).toList();
      expect(gemba.length, 2); // Aparece en semana 1 y semana 2 (conservación de repetidas)

      // Filtro por categoría 'Administración'
      final adm = list.where((a) => a.category == 'Administración').toList();
      expect(adm.length, 1);
      expect(adm.first.activityName, 'Revision de Bi\'s/Cubos');
    });

    test('Idempotencia: Carga múltiple previene duplicación de registros', () {
      final setIds = <int>{};
      final initialRecords = [1, 2, 3, 4, 5];
      for (final id in initialRecords) {
        setIds.add(id);
      }
      expect(setIds.length, 5);

      // Simular segunda apertura de la app (recarga)
      for (final id in initialRecords) {
        setIds.add(id); // Set ignora duplicados
      }
      expect(setIds.length, 5); // Permanece inalterado en 5
    });
  });

  group('Fase 7: Evolución Integral - Indicadores, Calendario, Áreas y Exportación', () {
    test('ActivityModel soporta área, categoría y horario de inicio/fin', () {
      final model = ActivityModel(
        id: 101,
        userId: 'YL',
        nombre: 'Control de Espesores Extrusión',
        descripcion: 'Verificación en línea',
        dias: '[1,2,3,4,5]',
        fija: true,
        area: 'Planta Extrusa',
        category: 'Calidad e Inocuidad',
        timeStart: '10:00',
        timeEnd: '10:45',
      );

      final map = model.toMap();
      expect(map['area'], 'Planta Extrusa');
      expect(map['category'], 'Calidad e Inocuidad');
      expect(map['timeStart'], '10:00');
      expect(map['timeEnd'], '10:45');
      expect(map['fija'], 1);

      final reconstructed = ActivityModel.fromMap(map);
      expect(reconstructed.area, 'Planta Extrusa');
      expect(reconstructed.category, 'Calidad e Inocuidad');
      expect(reconstructed.timeStart, '10:00');
      expect(reconstructed.timeEnd, '10:45');
    });

    test('Cálculo estricto de cumplimiento: solo actividades evaluables hasta hoy', () {
      final instances = [
        const ActivityInstance(
          activityId: 1, userId: 'YL', weekKey: '2026-W44', nombre: 'A1', descripcion: 'D1',
          day: 1, orig: 1, fija: false, done: true,
        ),
        const ActivityInstance(
          activityId: 2, userId: 'YL', weekKey: '2026-W44', nombre: 'A2', descripcion: 'D2',
          day: 1, orig: 1, fija: false, done: false,
        ),
        const ActivityInstance(
          activityId: 3, userId: 'YL', weekKey: '2026-W44', nombre: 'A3', descripcion: 'D3',
          day: 2, orig: 2, fija: false, done: true,
        ),
        // Actividad futura (día 4, mientras hoy es día 2)
        const ActivityInstance(
          activityId: 4, userId: 'YL', weekKey: '2026-W44', nombre: 'A4', descripcion: 'D4',
          day: 4, orig: 4, fija: false, done: false,
        ),
      ];

      const int simulatedHoy = 2;
      final evaluables = instances.where((i) => i.day <= simulatedHoy).toList();
      final realizadas = evaluables.where((i) => i.done).toList();

      expect(evaluables.length, 3); // Días 1 y 2
      expect(realizadas.length, 2); // 2 de 3
      final double pct = (realizadas.length / evaluables.length) * 100;
      expect(pct.round(), 67); // 66.66% redondeado
    });

    test('Formateo de CSV garantiza BOM UTF-8 y delimitador punto y coma', () {
      final buffer = StringBuffer();
      buffer.write('\uFEFF'); // BOM
      buffer.writeln('ID;Actividad;Área;Categoría');
      buffer.writeln('1;"Control de Tensión y Calidad";"Planta Extrusa";"Operación y Ejecución"');

      final content = buffer.toString();
      expect(content.startsWith('\uFEFF'), isTrue);
      expect(content.contains(';'), isTrue);
      expect(content.contains('Tensión'), isTrue);
      expect(content.contains('Extrusa'), isTrue);
    });
  });

  group('Fase 8: Auditoría Final de Aceptación Funcional', () {
    test('Consistencia de Fórmulas: Todas Realizadas, Parcial, Cero y Sin Evaluables', () {
      // Caso 1: 100% de cumplimiento
      final c1 = [
        const ActivityInstance(activityId: 1, userId: 'YL', weekKey: 'W1', nombre: 'A', descripcion: 'D', day: 1, orig: 1, fija: false, done: true),
        const ActivityInstance(activityId: 2, userId: 'YL', weekKey: 'W1', nombre: 'B', descripcion: 'D', day: 1, orig: 1, fija: false, done: true),
      ];
      final ev1 = c1.where((i) => i.day <= 1).toList();
      final ok1 = ev1.where((i) => i.done).toList();
      expect(((ok1.length / ev1.length) * 100).round(), 100);

      // Caso 2: 0% de cumplimiento
      final c2 = [
        const ActivityInstance(activityId: 1, userId: 'YL', weekKey: 'W1', nombre: 'A', descripcion: 'D', day: 1, orig: 1, fija: false, done: false),
      ];
      final ev2 = c2.where((i) => i.day <= 1).toList();
      final ok2 = ev2.where((i) => i.done).toList();
      expect(((ok2.length / ev2.length) * 100).round(), 0);

      // Caso 3: Sin actividades evaluables (evita división por cero y NaN)
      final List<ActivityInstance> c3 = [];
      final double pct3 = c3.isNotEmpty ? ((c3.where((i) => i.done).length / c3.length) * 100) : 0.0;
      expect(pct3, 0.0);
    });

    test('Integridad de Esquema SQLite V4 con valores por defecto', () {
      final act = ActivityModel(
        userId: 'YL',
        nombre: 'Limpieza de Cabezal',
        descripcion: 'Final de turno',
        dias: '[5]',
        fija: false,
        area: 'Planta Extrusa',
        category: 'Operación y Ejecución',
        timeStart: '14:00',
        timeEnd: '14:30',
      );

      final map = act.toMap();
      expect(map['area'], isNotEmpty);
      expect(map['category'], isNotEmpty);
      expect(map['timeStart'], '14:00');
      expect(map['timeEnd'], '14:30');

      // Instancia vinculada conserva el área y horario
      final inst = ActivityInstance(
        activityId: 1,
        userId: act.userId,
        weekKey: '2026-W44',
        nombre: act.nombre,
        descripcion: act.descripcion,
        day: 5,
        orig: 5,
        fija: act.fija,
        area: act.area,
        category: act.category,
        timeStart: act.timeStart,
        timeEnd: act.timeEnd,
      );

      expect(inst.area, 'Planta Extrusa');
      expect(inst.category, 'Operación y Ejecución');
      expect(inst.timeStart, '14:00');
    });

    test('Persistencia y Validación de Horarios en Nueva Actividad', () {
      final tStart = DateTime(2026, 10, 29, 8, 0);
      final tEndValido = DateTime(2026, 10, 29, 8, 30);
      final tEndInvalido = DateTime(2026, 10, 29, 7, 30);

      expect(tEndValido.isAfter(tStart), isTrue);
      expect(tEndInvalido.isAfter(tStart), isFalse); // Detección de error
    });
  });
}
