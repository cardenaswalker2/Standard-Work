import os
import time
from playwright.sync_api import sync_playwright

WORKSPACE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "screenshots"))
SHOWCASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "showcase"))
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(SHOWCASE_DIR, exist_ok=True)

def run():
    with sync_playwright() as p:
        browser = p.chromium.launch(channel="chrome", headless=True)
        
        # 1. Capture landing page (index.html)
        print("Capturing index.html...")
        page = browser.new_page(viewport={"width": 1920, "height": 1080}, device_scale_factor=2)
        landing_url = f"file:///{WORKSPACE}/index.html".replace("\\", "/")
        page.goto(landing_url)
        page.wait_for_timeout(1000)
        
        page.screenshot(path=os.path.join(OUT_DIR, "landing_hero.png"), clip={"x": 0, "y": 0, "width": 1920, "height": 1080})
        page.evaluate("window.scrollTo(0, 950)")
        page.wait_for_timeout(500)
        page.screenshot(path=os.path.join(OUT_DIR, "landing_features.png"), clip={"x": 0, "y": 0, "width": 1920, "height": 1080})
        page.close()

        # 2. Capture mobile simulator (prueba.html)
        print("Capturing prueba.html screens...")
        page = browser.new_page(viewport={"width": 1920, "height": 1200}, device_scale_factor=2)
        prueba_url = f"file:///{WORKSPACE}/prueba.html".replace("\\", "/")
        page.goto(prueba_url)
        page.wait_for_timeout(1000)
        
        phone = page.locator(".phone")
        
        # S1: Login
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_login.png"))
        phone.screenshot(path=os.path.join(SHOWCASE_DIR, "01_login.png"))
        print("  [OK] screen_login.png")

        # S2: Dashboard Colaborador con 10 actividades y campanita de notificaciones
        page.evaluate("startBiometricLogin('X');")
        page.wait_for_timeout(1800)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_dashboard.png"))
        phone.screenshot(path=os.path.join(SHOWCASE_DIR, "03_dashboard.png"))
        print("  [OK] screen_dashboard.png")

        # S3: Notificaciones Modal
        page.evaluate("openColabNotifSheet();")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_notifs.png"))
        print("  [OK] screen_notifs.png")
        page.evaluate("closeModal('modalNotifs');")
        page.wait_for_timeout(300)

        # S4: Reprogramación Justificada
        page.evaluate("openReprogModal(104, 'Seguimiento de Scrap y Desperdicio');")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_reprog.png"))
        print("  [OK] screen_reprog.png")
        page.evaluate("closeModal('modalReprog');")
        page.wait_for_timeout(300)

        # S5: Ir al Panel Administrativo
        page.evaluate("navTo('scrAdmin'); switchAdminModule('dashboard');")
        page.wait_for_timeout(800)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_admin_kpis.png"))
        print("  [OK] screen_admin_kpis.png")

        # S6: Admin Colaboradores
        page.evaluate("switchAdminModule('colaboradores');")
        page.wait_for_timeout(500)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_admin_colabs.png"))
        print("  [OK] screen_admin_colabs.png")

        # S7: Admin Asignaciones y Catálogo
        page.evaluate("switchAdminModule('asignaciones'); switchAsigTab('catalogo');")
        page.wait_for_timeout(500)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_admin_asig.png"))
        print("  [OK] screen_admin_asig.png")

        # S8: Admin Supervisión Reprogramaciones
        page.evaluate("switchAdminModule('supervision');")
        page.wait_for_timeout(500)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_admin_superv.png"))
        print("  [OK] screen_admin_superv.png")

        # S9: Admin Auditoría Inmutable
        page.evaluate("switchAdminModule('auditoria');")
        page.wait_for_timeout(500)
        phone.screenshot(path=os.path.join(OUT_DIR, "screen_admin_audit.png"))
        phone.screenshot(path=os.path.join(SHOWCASE_DIR, "13_history.png"))
        print("  [OK] screen_admin_audit.png")

        # S10: Sincronizar screenshots reales con las fotos oficiales si aplica
        fotos_dir = os.path.join(WORKSPACE, "FotosTRACK60")
        if os.path.exists(fotos_dir):
            import shutil
            # Foto 5F -> screen_excel_weeks.png (Planificación 4 Semanas)
            shutil.copyfile(os.path.join(fotos_dir, "5F.jpg"), os.path.join(OUT_DIR, "screen_excel_weeks.png"))
            shutil.copyfile(os.path.join(fotos_dir, "5F.jpg"), os.path.join(SHOWCASE_DIR, "07_four_weeks.png"))
            # Foto 4F -> screen_indicators.png (Indicadores y Gráficos)
            shutil.copyfile(os.path.join(fotos_dir, "4F.jpg"), os.path.join(OUT_DIR, "screen_indicators.png"))
            shutil.copyfile(os.path.join(fotos_dir, "4F.jpg"), os.path.join(SHOWCASE_DIR, "11_indicators.png"))
            # Foto 3F -> screen_calendar.png (Calendario Laboral)
            shutil.copyfile(os.path.join(fotos_dir, "3F.jpg"), os.path.join(OUT_DIR, "screen_calendar.png"))
            shutil.copyfile(os.path.join(fotos_dir, "3F.jpg"), os.path.join(SHOWCASE_DIR, "09_calendar.png"))
            # Foto 2F -> screen_reports.png (Reportes PDF/CSV)
            shutil.copyfile(os.path.join(fotos_dir, "2F.jpg"), os.path.join(OUT_DIR, "screen_reports.png"))
            print("  [OK] Fotos reales 5F, 4F, 3F, 2F mapeadas con máxima resolución")

        browser.close()
        print("\nAll real screenshots captured successfully!")

if __name__ == "__main__":
    run()
