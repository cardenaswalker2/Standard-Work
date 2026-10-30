import csv
import io

def escape_dart(val):
    if val is None:
        return '""'
    s = str(val).replace('"', '""')
    return f'"{s}"'

def test_csv_validation():
    buffer = io.StringIO()
    # Escribir BOM UTF-8
    buffer.write('\ufeff')

    # Generar contenido tal como lo hace reports_screen.dart
    header = 'ID;Día Num;Día Nombre;Actividad;Área;Categoría;Horario;Tipo;Estado;Fecha Ejecución;Observaciones;Motivo Incumplimiento'
    buffer.write(header + '\n')

    # Fila 1: Acentos y caracteres especiales españoles
    buffer.write(f'1;1;{escape_dart("Lunes")};{escape_dart("Reunión de Coordinación Operativa")};{escape_dart("Planta Extrusa")};{escape_dart("Operación y Ejecución")};{escape_dart("08:00 - 08:30")};{escape_dart("Fija Obligatoria")};{escape_dart("Realizada")};{escape_dart("2026-10-29 08:30:00")};{escape_dart("Sin observación")};{escape_dart("")}\n')

    # Fila 2: Texto con comas y comillas dobles
    buffer.write(f'2;2;{escape_dart("Martes")};{escape_dart("Inspección de Tolvas, Extrusora \"A\"")};{escape_dart("Producción")};{escape_dart("Resultados y Productividad")};{escape_dart("09:00 - 09:45")};{escape_dart("Ordinaria")};{escape_dart("Realizada")};{escape_dart("2026-10-29 09:45:00")};{escape_dart("Parada menor de 5 min, resuelta")};{escape_dart("")}\n')

    # Fila 3: Texto con saltos de línea y punto y coma en observaciones
    buffer.write(f'3;3;{escape_dart("Miércoles")};{escape_dart("Control de Variables de Proceso")};{escape_dart("Calidad")};{escape_dart("Calidad e Inocuidad")};{escape_dart("10:00 - 11:00")};{escape_dart("Ordinaria")};{escape_dart("Pendiente")};{escape_dart("No completada")};{escape_dart("Línea detenida por mantenimiento;\nse reprogramará para el turno 2")};{escape_dart("Falla en sensor de temperatura")}\n')

    content = buffer.getvalue()
    raw_bytes = content.encode('utf-8')

    assert raw_bytes.startswith(b'\xef\xbb\xbf'), "Falta el BOM UTF-8"

    # Leer con csv.reader utilizando utf-8-sig
    stream = io.StringIO(raw_bytes.decode('utf-8-sig'))
    reader = csv.reader(stream, delimiter=';')
    rows = list(reader)

    assert len(rows) == 4, f"Se esperaban 4 filas pero se obtuvieron {len(rows)}"
    for idx, r in enumerate(rows):
        assert len(r) == 12, f"La fila {idx} tiene {len(r)} columnas, se esperaban 12"

    assert rows[1][3] == "Reunión de Coordinación Operativa"
    assert rows[2][3] == 'Inspección de Tolvas, Extrusora "A"'
    assert "Línea detenida por mantenimiento;\nse reprogramará para el turno 2" in rows[3][10]
    assert rows[3][11] == "Falla en sensor de temperatura"

    with open('csv_audit_evidence.txt', 'w', encoding='utf-8') as f:
        f.write("VALIDACION EXITOSA DE MATRIZ CSV (EXCEL RFC 4180):\n")
        f.write(f"Bytes generados: {len(raw_bytes)}\n")
        f.write("BOM UTF-8 verificado: \\xef\\xbb\\xbf\n")
        f.write("Separador verificado: ;\n")
        f.write(f"Total filas validadas: {len(rows)}\n")
        for idx, r in enumerate(rows):
            f.write(f"Fila {idx} ({len(r)} cols): {r[0]} | {r[3]} | {r[4]} | {r[8]}\n")

if __name__ == '__main__':
    test_csv_validation()
