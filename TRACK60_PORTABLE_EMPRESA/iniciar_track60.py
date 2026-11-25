"""
========================================================================================
TRACK60 - SERVIDOR Y LANZADOR CORPORATIVO MULTIPLATAFORMA
Grupo Darnel - Standard Work & Control Operativo Multiplanta
========================================================================================
Diseñado para demostraciones empresariales en computadores corporativos sin permisos
de administrador (TI). Detecta automáticamente la IP de la Zona Wi-Fi / Red móvil,
genera código QR para celular, y abre la aplicación con un solo clic.
========================================================================================
"""

import os
import sys
import socket
import threading
import functools
import http.server
import socketserver
import webbrowser
import tkinter as tk
from tkinter import ttk, messagebox

# Añadir carpeta 'vendor' local al path de Python para garantizar disponibilidad de qrcode
vendor_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "vendor")
if os.path.exists(vendor_dir) and vendor_dir not in sys.path:
    sys.path.insert(0, vendor_dir)

# Soporte de QR autónomo (sin requerir Pillow ni librerías compiladas)
HAS_QR = False
try:
    import qrcode
    HAS_QR = True
except Exception:
    HAS_QR = False

# Habilitar nitidez High-DPI en Windows si es posible
try:
    import ctypes
    ctypes.windll.shcore.SetProcessDpiAwareness(1)
except Exception:
    pass


class QuietHTTPHandler(http.server.SimpleHTTPRequestHandler):
    """Manejador HTTP silencioso que añade encabezados MIME correctos para PWA."""
    def log_message(self, format, *args):
        # Evitar inundar la consola con peticiones estáticas
        pass

    def end_headers(self):
        # Desactivar caché agresiva para evitar problemas en demos
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        # Soporte para PWA en navegadores corporativos
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

    def guess_type(self, path):
        # Asegurar tipos MIME para Flutter Web
        if path.endswith('.wasm'):
            return 'application/wasm'
        if path.endswith('.json'):
            return 'application/json'
        if path.endswith('.js'):
            return 'application/javascript'
        return super().guess_type(path)


class Track60ServerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("TRACK60 - Lanzador Corporativo Darnel")
        self.root.geometry("640x790")
        self.root.minsize(580, 720)
        self.root.configure(bg="#0B132B")

        # Determinar directorio raíz de la aplicación web
        base_dir = os.path.dirname(os.path.abspath(__file__))

        # Configurar icono oficial corporativo si existe
        ico_path = os.path.join(base_dir, "presentacion_assets", "app_icon.ico")
        if os.path.exists(ico_path):
            try:
                self.root.iconbitmap(ico_path)
            except Exception:
                pass
        candidates = [
            os.path.join(base_dir, "app_web"),
            os.path.join(base_dir, "build", "web"),
            os.path.join(base_dir, "..", "track60_fin", "build", "web"),
            os.path.join(base_dir, "track60_fin", "build", "web"),
            base_dir,
        ]
        self.web_dir = None
        for c in candidates:
            if os.path.exists(os.path.join(c, "index.html")):
                self.web_dir = os.path.abspath(c)
                break
        if not self.web_dir:
            self.web_dir = base_dir

        self.port = 8080
        self.httpd = None
        self.server_thread = None
        self.is_running = False

        # Detección de IPs disponibles
        self.ip_list = self.detect_all_ips()
        self.selected_ip = tk.StringVar(value=self.ip_list[0] if self.ip_list else "localhost")

        # Construir Interfaz Gráfica
        self.build_ui()

        # Iniciar Servidor Automáticamente
        self.start_server()

    def detect_all_ips(self):
        """Detecta las direcciones IP locales de la máquina (Hotspot, Wi-Fi, Ethernet)."""
        ips = []
        # Método 1: Ruta activa hacia internet (detecta la IP del hotspot móvil)
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            best_ip = s.getsockname()[0]
            s.close()
            if best_ip and not best_ip.startswith("127."):
                ips.append(best_ip)
        except Exception:
            pass

        # Método 2: Hostname local
        try:
            hostname = socket.gethostname()
            for ip in socket.gethostbyname_ex(hostname)[2]:
                if not ip.startswith("127.") and ip not in ips:
                    ips.append(ip)
        except Exception:
            pass

        if not ips:
            ips.append("127.0.0.1")
        return ips

    def build_ui(self):
        # Header Corporativo
        header = tk.Frame(self.root, bg="#002F6C", pady=14, padx=20)
        header.pack(fill="x")

        header_top = tk.Frame(header, bg="#002F6C")
        header_top.pack(fill="x")

        title_lbl = tk.Label(
            header_top,
            text="TRACK60  |  Grupo Darnel",
            font=("Segoe UI", 16, "bold"),
            fg="#FFFFFF",
            bg="#002F6C"
        )
        title_lbl.pack(side="left")

        header_actions = tk.Frame(header_top, bg="#002F6C")
        header_actions.pack(side="right")

        btn_pres = tk.Button(
            header_actions,
            text="📊 Diapositivas",
            command=self.open_presentation,
            font=("Segoe UI", 9, "bold"),
            bg="#F59E0B",
            fg="#0F172A",
            activebackground="#D97706",
            activeforeground="#FFFFFF",
            relief="flat",
            padx=8,
            pady=3,
            cursor="hand2"
        )
        btn_pres.pack(side="left", padx=(0, 6))

        btn_ti = tk.Button(
            header_actions,
            text="📄 Dossier TI",
            command=self.open_ti_proposal,
            font=("Segoe UI", 9, "bold"),
            bg="#0284C7",
            fg="#FFFFFF",
            activebackground="#0369A1",
            activeforeground="#FFFFFF",
            relief="flat",
            padx=8,
            pady=3,
            cursor="hand2"
        )
        btn_ti.pack(side="left")

        sub_lbl = tk.Label(
            header,
            text="Servidor Corporativo Portátil para Demostraciones Multiplanta",
            font=("Segoe UI", 9),
            fg="#93C5FD",
            bg="#002F6C"
        )
        sub_lbl.pack(anchor="w", pady=(2, 0))

        # Contenedor con Scroll o Canvas Principal
        main_frame = tk.Frame(self.root, bg="#0B132B", padx=20, pady=12)
        main_frame.pack(fill="both", expand=True)

        # 1. Tarjeta de Estado del Servidor
        status_card = tk.Frame(main_frame, bg="#1C2541", padx=16, pady=12, highlightthickness=1, highlightbackground="#3A506B")
        status_card.pack(fill="x", pady=(0, 10))

        status_row = tk.Frame(status_card, bg="#1C2541")
        status_row.pack(fill="x")

        self.status_dot = tk.Label(status_row, text="●", font=("Segoe UI", 16, "bold"), fg="#10B981", bg="#1C2541")
        self.status_dot.pack(side="left", padx=(0, 6))

        self.status_text = tk.Label(status_row, text="SERVIDOR EN LÍNEA", font=("Segoe UI", 11, "bold"), fg="#10B981", bg="#1C2541")
        self.status_text.pack(side="left")

        self.port_label = tk.Label(status_row, text=f"Puerto: {self.port}", font=("Segoe UI", 9), fg="#94A3B8", bg="#1C2541")
        self.port_label.pack(side="right")

        # 2. Tarjeta Enlace en este Portátil
        pc_card = tk.Frame(main_frame, bg="#1C2541", padx=16, pady=12, highlightthickness=1, highlightbackground="#3A506B")
        pc_card.pack(fill="x", pady=(0, 10))

        tk.Label(pc_card, text="💻 ACCESO EN ESTE COMPUTADOR (Local):", font=("Segoe UI", 9, "bold"), fg="#38BDF8", bg="#1C2541").pack(anchor="w")
        self.local_url_lbl = tk.Label(pc_card, text=f"http://localhost:{self.port}", font=("Consolas", 12, "bold"), fg="#FFFFFF", bg="#1C2541")
        self.local_url_lbl.pack(anchor="w", pady=(4, 8))

        btn_row_pc = tk.Frame(pc_card, bg="#1C2541")
        btn_row_pc.pack(fill="x")

        btn_open = tk.Button(
            btn_row_pc,
            text="🚀 Abrir en mi Navegador",
            command=self.open_local_browser,
            font=("Segoe UI", 9, "bold"),
            bg="#0284C7",
            fg="#FFFFFF",
            activebackground="#0369A1",
            activeforeground="#FFFFFF",
            relief="flat",
            padx=12,
            pady=6,
            cursor="hand2"
        )
        btn_open.pack(side="left", padx=(0, 8))

        btn_copy_local = tk.Button(
            btn_row_pc,
            text="📋 Copiar",
            command=lambda: self.copy_to_clipboard(f"http://localhost:{self.port}"),
            font=("Segoe UI", 9),
            bg="#334155",
            fg="#FFFFFF",
            relief="flat",
            padx=10,
            pady=6,
            cursor="hand2"
        )
        btn_copy_local.pack(side="left")

        # 3. Tarjeta Enlace para Celular / Jefe
        mobile_card = tk.Frame(main_frame, bg="#1C2541", padx=16, pady=12, highlightthickness=1, highlightbackground="#3A506B")
        mobile_card.pack(fill="x", pady=(0, 10))

        tk.Label(mobile_card, text="📱 ACCESO PARA EL CELULAR DEL JEFE (Zona Wi-Fi / Red):", font=("Segoe UI", 9, "bold"), fg="#4ADE80", bg="#1C2541").pack(anchor="w")

        # Selector de IP si hay más de una
        ip_row = tk.Frame(mobile_card, bg="#1C2541")
        ip_row.pack(fill="x", pady=(4, 6))

        tk.Label(ip_row, text="IP activa:", font=("Segoe UI", 9), fg="#94A3B8", bg="#1C2541").pack(side="left", padx=(0, 6))
        self.ip_combo = ttk.Combobox(ip_row, textvariable=self.selected_ip, values=self.ip_list, state="readonly", width=16)
        self.ip_combo.pack(side="left", padx=(0, 6))
        self.ip_combo.bind("<<ComboboxSelected>>", self.on_ip_changed)

        btn_refresh_ip = tk.Button(
            ip_row,
            text="🔄 Refrescar Red",
            command=self.refresh_network_ips,
            font=("Segoe UI", 8, "bold"),
            bg="#334155",
            fg="#F1F5F9",
            relief="flat",
            padx=8,
            pady=2,
            cursor="hand2"
        )
        btn_refresh_ip.pack(side="left")

        self.network_url_lbl = tk.Label(mobile_card, text=self.get_network_url(), font=("Consolas", 12, "bold"), fg="#FFFFFF", bg="#1C2541")
        self.network_url_lbl.pack(anchor="w", pady=(2, 8))

        btn_row_mob = tk.Frame(mobile_card, bg="#1C2541")
        btn_row_mob.pack(fill="x")

        btn_copy_mob = tk.Button(
            btn_row_mob,
            text="📋 Copiar Enlace para el Jefe",
            command=lambda: self.copy_to_clipboard(self.get_network_url()),
            font=("Segoe UI", 9, "bold"),
            bg="#10B981",
            fg="#FFFFFF",
            activebackground="#059669",
            activeforeground="#FFFFFF",
            relief="flat",
            padx=12,
            pady=6,
            cursor="hand2"
        )
        btn_copy_mob.pack(side="left", padx=(0, 8))

        btn_copy_msg = tk.Button(
            btn_row_mob,
            text="💬 Copiar Texto para WhatsApp",
            command=self.copy_whatsapp_message,
            font=("Segoe UI", 9),
            bg="#334155",
            fg="#FFFFFF",
            relief="flat",
            padx=10,
            pady=6,
            cursor="hand2"
        )
        btn_copy_msg.pack(side="left")

        # 4. Sección Código QR Dinámico
        qr_card = tk.Frame(main_frame, bg="#1C2541", padx=16, pady=12, highlightthickness=1, highlightbackground="#3A506B")
        qr_card.pack(fill="both", expand=True, pady=(0, 10))

        tk.Label(qr_card, text="📸 ESCANEA CON EL CELULAR (iPhone o Android):", font=("Segoe UI", 9, "bold"), fg="#FCD34D", bg="#1C2541").pack(anchor="w")

        self.qr_container = tk.Frame(qr_card, bg="#FFFFFF", padx=6, pady=6)
        self.qr_container.pack(pady=6)

        # Canvas nativo para dibujo vectorial sin requerir dependencias de imagen (Pillow)
        self.qr_canvas = tk.Canvas(self.qr_container, bg="#FFFFFF", highlightthickness=0, width=210, height=210)
        self.qr_canvas.pack()

        # Botón para abrir vista QR ampliada en navegador
        btn_open_qr_browser = tk.Button(
            qr_card,
            text="🔍 Ver QR en Pantalla Completa (Navegador)",
            command=self.open_qr_in_browser,
            font=("Segoe UI", 8, "bold"),
            bg="#2563EB",
            fg="#FFFFFF",
            relief="flat",
            padx=10,
            pady=4,
            cursor="hand2"
        )
        btn_open_qr_browser.pack(pady=(4, 0))

        self.render_qr()

        # 5. Directorio Rápido de Credenciales de Prueba
        cred_card = tk.Frame(main_frame, bg="#1C2541", padx=14, pady=10, highlightthickness=1, highlightbackground="#3A506B")
        cred_card.pack(fill="x", pady=(0, 10))

        tk.Label(cred_card, text="🔑 CREDENCIALES RÁPIDAS PARA LA DEMOSTRACIÓN (Clic para copiar):", font=("Segoe UI", 9, "bold"), fg="#38BDF8", bg="#1C2541").pack(anchor="w", pady=(0, 6))

        cred_grid = tk.Frame(cred_card, bg="#1C2541")
        cred_grid.pack(fill="x")

        users_demo = [
            ("👑 Javier Julio (Superadmin)", "1428", "PIN"),
            ("🏭 Yonny López (Admin Planta)", "1234", "PIN"),
            ("🔍 Carlos Méndez (Supervisor)", "3344", "PIN"),
            ("👷 Laura Pérez (Operaria)", "1023456789", "Cédula"),
        ]

        for i, (name, val, t) in enumerate(users_demo):
            r = i // 2
            c = i % 2
            f = tk.Frame(cred_grid, bg="#111827", padx=8, pady=6, relief="flat", highlightthickness=1, highlightbackground="#374151")
            f.grid(row=r, column=c, padx=4, pady=4, sticky="ew")
            cred_grid.grid_columnconfigure(c, weight=1)

            lbl_txt = f"{name}\n{t}: {val}"
            tk.Label(f, text=lbl_txt, font=("Segoe UI", 8), fg="#F3F4F6", bg="#111827", justify="left").pack(side="left")

            btn_cp = tk.Button(
                f,
                text="📋 Copiar",
                command=lambda v=val: self.copy_to_clipboard(v),
                font=("Segoe UI", 7, "bold"),
                bg="#2563EB",
                fg="#FFFFFF",
                relief="flat",
                padx=6,
                pady=2,
                cursor="hand2"
            )
            btn_cp.pack(side="right")

        # 6. Pasos Rápidos de Conexión
        steps_lbl = tk.Label(
            main_frame,
            text="💡 PASO 1: Enciende 'Zona Wi-Fi' en tu celular. | PASO 2: Conecta este portátil.\n"
                 "💡 PASO 3: Conecta el celular del jefe a tu misma red y haz que escanee el código QR.",
            font=("Segoe UI", 8),
            fg="#94A3B8",
            bg="#0B132B",
            justify="center"
        )
        steps_lbl.pack(pady=(0, 6))

    def get_network_url(self):
        ip = self.selected_ip.get() if self.selected_ip.get() else "localhost"
        return f"http://{ip}:{self.port}"

    def open_qr_in_browser(self):
        """Abre la pantalla de enlace QR en el navegador corporativo."""
        ip = self.selected_ip.get() if self.selected_ip.get() else "localhost"
        qr_web_url = f"http://localhost:{self.port}/conectar.html?ip={ip}&port={self.port}"
        webbrowser.open(qr_web_url)

    def on_ip_changed(self, event=None):
        url = self.get_network_url()
        self.network_url_lbl.config(text=url)
        self.render_qr()

    def render_qr(self):
        url = self.get_network_url()
        if HAS_QR:
            try:
                # Guardar tambien version SVG para navegadores locales
                try:
                    import qrcode.image.svg
                    svg_factory = qrcode.image.svg.SvgPathImage
                    svg_img = qrcode.make(url, image_factory=svg_factory)
                    if self.web_dir and os.path.exists(self.web_dir):
                        svg_path = os.path.join(self.web_dir, "qr_code.svg")
                        svg_img.save(svg_path)
                except Exception:
                    pass

                qr = qrcode.QRCode(
                    version=1,
                    error_correction=qrcode.constants.ERROR_CORRECT_M,
                    box_size=1,
                    border=2,
                )
                qr.add_data(url)
                qr.make(fit=True)
                matrix = qr.get_matrix()

                # Dibujo 100% nativo en Tkinter Canvas (Cero dependencias externas)
                rows = len(matrix)
                cols = len(matrix[0])
                cell_size = max(4, 210 // max(rows, cols))
                canvas_w = cols * cell_size
                canvas_h = rows * cell_size

                self.qr_canvas.config(width=canvas_w, height=canvas_h)
                self.qr_canvas.delete("all")
                self.qr_canvas.create_rectangle(0, 0, canvas_w, canvas_h, fill="#FFFFFF", outline="")

                for r in range(rows):
                    for c in range(cols):
                        if matrix[r][c]:
                            self.qr_canvas.create_rectangle(
                                c * cell_size, r * cell_size,
                                (c + 1) * cell_size, (r + 1) * cell_size,
                                fill="#002F6C", outline=""
                            )
                return
            except Exception as e:
                pass

        # Fallback sin librería qrcode: texto limpio en canvas
        self.qr_canvas.delete("all")
        self.qr_canvas.config(width=220, height=100)
        self.qr_canvas.create_text(
            110, 50,
            text=f"Abre en el celular:\n\n{url}\n\n(No requiere apps adicionales)",
            font=("Segoe UI", 9, "bold"),
            fill="#002F6C",
            justify="center"
        )

    def find_available_port(self, start_port=8080):
        """Encuentra automáticamente un puerto libre si el 8080 está ocupado."""
        for p in [start_port, 8081, 8082, 8888, 5000, 3000, 8000]:
            try:
                with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    s.bind(("", p))
                    return p
            except OSError:
                continue
        return start_port

    def start_server(self):
        """Inicia el servidor HTTP en un hilo independiente con puerto dinámico."""
        if self.is_running:
            return

        self.port = self.find_available_port(self.port)
        self.port_label.config(text=f"Puerto: {self.port}")
        self.local_url_lbl.config(text=f"http://localhost:{self.port}")
        self.network_url_lbl.config(text=self.get_network_url())
        self.render_qr()

        def run():
            class ReusableTCPServer(socketserver.TCPServer):
                allow_reuse_address = True

            handler = functools.partial(QuietHTTPHandler, directory=self.web_dir)
            try:
                with ReusableTCPServer(("", self.port), handler) as httpd:
                    self.httpd = httpd
                    self.is_running = True
                    httpd.serve_forever()
            except Exception as e:
                print(f"Error en servidor: {e}")

        self.server_thread = threading.Thread(target=run, daemon=True)
        self.server_thread.start()

    def open_local_browser(self):
        webbrowser.open(f"http://localhost:{self.port}")

    def open_presentation(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        pres_path = os.path.join(base_dir, "PRESENTACION_EJECUTIVA_TRACK60.html")
        if os.path.exists(pres_path):
            webbrowser.open(f"file:///{pres_path.replace(os.sep, '/')}")
        else:
            messagebox.showinfo("Presentación", "Archivo de presentación listo en la carpeta principal.")

    def open_ti_proposal(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        ti_path = os.path.join(base_dir, "PROPUESTA_TECNICA_TI_DARNEL.html")
        if not os.path.exists(ti_path):
            ti_path = os.path.join(base_dir, "PROPUESTA_TECNICA_TI_DARNEL.md")
        if os.path.exists(ti_path):
            webbrowser.open(f"file:///{ti_path.replace(os.sep, '/')}")
        else:
            messagebox.showinfo("Dossier TI", "Propuesta técnica lista en la carpeta principal.")

    def refresh_network_ips(self):
        """Re-escanea las interfaces de red para detectar la IP de la Zona Wi-Fi."""
        new_ips = self.detect_all_ips()
        self.ip_list = new_ips
        self.ip_combo["values"] = self.ip_list
        if self.ip_list:
            self.selected_ip.set(self.ip_list[0])
            self.on_ip_changed()
            messagebox.showinfo("Red Actualizada", f"Se detectó la IP activa:\n\n{self.ip_list[0]}\n\nCódigo QR y enlace actualizados.")

    def copy_to_clipboard(self, text):
        self.root.clipboard_clear()
        self.root.clipboard_append(text)
        self.root.update()
        messagebox.showinfo("Copiado con Éxito", f"Enlace copiado al portapapeles:\n\n{text}\n\nPégalo en WhatsApp o envíaselo a tu jefe.")

    def copy_whatsapp_message(self):
        url = self.get_network_url()
        msg = (
            f"Buenas tardes, te comparto el enlace de acceso directo a la plataforma TRACK60:\n\n"
            f"{url}\n\n"
            f"Puedes abrirlo desde tu celular (iPhone o Android) o computador conectado a la red.\n"
            f"Credenciales de prueba:\n"
            f"- Javier Julio (Superadmin General): PIN 1428\n"
            f"- Yonny López (Jefe de Planta Extrusa): PIN 1234\n"
            f"- Carlos Méndez (Supervisor de Producción): PIN 3344"
        )
        self.copy_to_clipboard(msg)


def main():
    root = tk.Tk()
    app = Track60ServerApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
