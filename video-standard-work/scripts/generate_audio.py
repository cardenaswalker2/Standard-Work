import asyncio
import os
import edge_tts

OUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "audio"))
os.makedirs(OUT_DIR, exist_ok=True)

VOICE = "es-CO-GonzaloNeural"  # Professional, natural Latin American / Colombian executive voice

SCENES_NARRATION = [
    {
        "id": "scene1",
        "text": "En el entorno industrial moderno, la excelencia operativa no ocurre por casualidad: se construye día a día en el piso de planta. Bienvenidos a la presentación de Standard Work, la solución tecnológica de Darnel Group diseñada para transformar la disciplina operativa de nuestros líderes y supervisores."
    },
    {
        "id": "scene2",
        "text": "Tradicionalmente, coordinar las rutinas de supervisión en áreas como extrusión, termoformado y calidad implicaba complejas hojas de cálculo y registros en papel. Los líderes dedicaban tiempo valioso a conciliar datos en oficina, en lugar de acompañar los procesos en el Gemba. Hacía falta una herramienta ágil, confiable y con movilidad total para asegurar que cada decisión se tome con datos verificados en tiempo real."
    },
    {
        "id": "scene3",
        "text": "Para responder a esta necesidad nace Standard Work. Una aplicación móvil construida con arquitectura offline first. Esto significa que funciona de manera ininterrumpida en cualquier punto de la planta, incluso sin cobertura de red. Con una interfaz limpia y moderna, cada supervisor inicia su turno con claridad absoluta de sus prioridades del día."
    },
    {
        "id": "scene4",
        "text": "El flujo de trabajo es directo y natural. Al ingresar, el dashboard presenta un tacómetro visual con el avance en tiempo real. Cada actividad está organizada por hora y código de color. El supervisor confirma la ejecución con un solo toque, añade notas de inspección y, si una urgencia requiere mover una tarea, registra el motivo formalmente garantizando una auditoría transparente."
    },
    {
        "id": "scene5",
        "text": "Standard Work articula todos los procesos en módulos especializados: el Planificador de Cuatro Semanas sincroniza la matriz operativa del mes; el Calendario Dinámico permite navegar entre turnos; el módulo de Calidad asegura el control de alertas y la revisión de material no conforme; y el Tablero de Indicadores mide la distribución del tiempo en las siete categorías estratégicas del negocio."
    },
    {
        "id": "scene6",
        "text": "El impacto en nuestra organización es directo: estandarizamos la gestión en todos los turnos, eliminamos la pérdida de información y garantizamos que el tiempo de los líderes se concentre en lo que genera verdadero valor: la seguridad de los colaboradores, la calidad del producto y la mejora continua de nuestras líneas de producción."
    },
    {
        "id": "scene7",
        "text": "Standard Work es más que una aplicación: es el estándar de excelencia operativa que impulsa el futuro de Darnel Group. Una herramienta lista, comprobada y en marcha para llevar nuestra gestión al siguiente nivel. Muchas gracias."
    }
]

async def generate():
    full_text = ""
    for scene in SCENES_NARRATION:
        out_path = os.path.join(OUT_DIR, f"{scene['id']}.mp3")
        print(f"Generating voice for {scene['id']}...")
        communicate = edge_tts.Communicate(scene['text'], VOICE, rate="+2%", pitch="+0Hz")
        await communicate.save(out_path)
        full_text += scene['text'] + " "
    
    full_out = os.path.join(OUT_DIR, "narration_full.mp3")
    print("Generating full narration track...")
    comm_full = edge_tts.Communicate(full_text.strip(), VOICE, rate="+2%", pitch="+0Hz")
    await comm_full.save(full_out)
    print("Voice generation complete!")

if __name__ == "__main__":
    asyncio.run(generate())

