import asyncio
import os
import subprocess
import edge_tts

OUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "audio"))
os.makedirs(OUT_DIR, exist_ok=True)

# Colombian Neural executive voice, configured faster (+14%) and deeper (-4Hz)
VOICE = "es-CO-GonzaloNeural"
RATE = "+14%"
PITCH = "-4Hz"

SCENES_NARRATION = [
    {
        "id": "scene1",
        "title": "Apertura e Identidad TRACK60",
        "text": "En la industria moderna de empaques, la excelencia operativa se construye día a día en el piso de planta. Bienvenidos a TRACK60, la plataforma corporativa de Darnel Group diseñada para estandarizar, asignar y supervisar la disciplina operativa de nuestros supervisores y líderes de producción."
    },
    {
        "id": "scene2",
        "title": "El Desafío Operativo en Gemba",
        "text": "Tradicionalmente, coordinar las rutinas en áreas como extrusión, termoformado, calidad y logística dependía de planillas de papel y hojas de cálculo dispersas. Los líderes invertían tiempo valioso cuadrando datos en oficina en vez de acompañar el Gemba. Hacía falta un sistema digital único, con movilidad total y datos verificados en tiempo real."
    },
    {
        "id": "scene3",
        "title": "Arquitectura y Acceso Seguro",
        "text": "Así nace TRACK60. Una plataforma con arquitectura 100% local sobre SQLite, garantizando funcionamiento continuo en planta sin depender de conexión a internet. Su acceso es ágil y seguro: los colaboradores ingresan directamente con su número de cédula o huella digital, mientras la supervisión cuenta con un acceso administrativo protegido por PIN."
    },
    {
        "id": "scene4",
        "title": "Flujo Operativo del Colaborador",
        "text": "Usar TRACK60 es intuitivo. Cada colaborador inicia su turno con diez actividades estándar asignadas. Al ejecutar una tarea, la marca con un toque y su avance se refleja en vivo. Si ocurre una eventualidad en línea, puede reprogramar la actividad justificando el motivo, manteniendo el balance operativo semanal de nueve y once tareas. Además, cuenta con una campanita de notificaciones que avisa en rojo cada nueva asignación del administrador."
    },
    {
        "id": "scene5",
        "title": "Suite Administrativa y Planificación Real",
        "text": "Para la gestión gerencial, el panel administrativo ofrece control total: asignación masiva de actividades por área y categoría, supervisión de justificaciones, consulta de la matriz oficial de cuatro semanas con sus doscientas setenta actividades reales, e historial de auditoría inmutable para máxima transparencia."
    },
    {
        "id": "scene6",
        "title": "Impacto y Valor Organizacional",
        "text": "El impacto de TRACK60 en Darnel Group es directo: eliminamos la pérdida de información, aseguramos el cumplimiento de estándares de seguridad, OEE y control de scrap, y generamos reportes oficiales en PDF y CSV listos para auditorías gerenciales."
    },
    {
        "id": "scene7",
        "title": "Cierre Institucional",
        "text": "TRACK60 es el nuevo estándar de excelencia operativa de Darnel Group. Una plataforma robusta, probada y lista para instalar en Android. Muchas gracias por acompañarnos en esta transformación digital."
    }
]

async def generate():
    full_text = ""
    durations = {}

    for scene in SCENES_NARRATION:
        out_path = os.path.join(OUT_DIR, f"{scene['id']}.mp3")
        print(f"Generating voice for {scene['id']} ({scene['title']})...")
        communicate = edge_tts.Communicate(scene['text'], VOICE, rate=RATE, pitch=PITCH)
        await communicate.save(out_path)

        cmd = [
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            out_path
        ]
        dur = float(subprocess.check_output(cmd).decode().strip())
        # Provide clean padding (approx 1.2s padding per scene for smooth transitions)
        frames = int(dur * 30) + 36
        durations[scene['id']] = {"seconds": dur, "frames": frames}
        print(f"  -> {scene['id']}: {dur:.2f}s | {frames} frames")
        full_text += scene['text'] + " "

    full_out = os.path.join(OUT_DIR, "narration_full.mp3")
    print("\nGenerating full consolidated narration track...")
    comm_full = edge_tts.Communicate(full_text.strip(), VOICE, rate=RATE, pitch=PITCH)
    await comm_full.save(full_out)

    print("\n=== DURATIONS SUMMARY FOR REMOTION THEME ===")
    total_frames = 0
    for sid, info in durations.items():
        print(f"  {sid}: {info['frames']}, // {info['seconds']:.2f}s")
        total_frames += info['frames']
    print(f"Total Frames: {total_frames} ({total_frames / 30:.2f}s)\n")

if __name__ == "__main__":
    asyncio.run(generate())

