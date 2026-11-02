import os
import time
from playwright.sync_api import sync_playwright

WORKSPACE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "screenshots"))
os.makedirs(OUT_DIR, exist_ok=True)

def run():
    with sync_playwright() as p:
        browser = p.chromium.launch(channel="chrome", headless=True)
        
        # 1. Capture landing page (index.html)
        page = browser.new_page(viewport={"width": 1920, "height": 1080}, device_scale_factor=2)
        landing_url = f"file:///{WORKSPACE}/index.html".replace("\\", "/")
        print(f"Loading {landing_url}...")
        page.goto(landing_url)
        page.wait_for_timeout(1000)
        
        page.screenshot(path=os.path.join(OUT_DIR, "landing_hero.png"), clip={"x": 0, "y": 0, "width": 1920, "height": 1080})
        
        # Scroll to features
        page.evaluate("window.scrollTo(0, 950)")
        page.wait_for_timeout(600)
        page.screenshot(path=os.path.join(OUT_DIR, "landing_features.png"), clip={"x": 0, "y": 0, "width": 1920, "height": 1080})
        page.close()

        # 2. Capture mobile simulator (prueba.html)
        prueba_url = f"file:///{WORKSPACE}/prueba.html".replace("\\", "/")
        page = browser.new_page(viewport={"width": 1920, "height": 1200}, device_scale_factor=2)
        print(f"Loading {prueba_url}...")
        page.goto(prueba_url)
        page.wait_for_timeout(1000)
        
        phone_elem = page.locator(".phone")
        
        # Screen 1: Login
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_login.png"))
        print("Captured screen_login.png")
        
        # Click first user to login or call login('yonny')
        page.evaluate("if (typeof login === 'function') login(Object.keys(USERS)[0]);")
        page.wait_for_timeout(800)
        
        # Screen 2: Dashboard
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_dashboard.png"))
        print("Captured screen_dashboard.png")
        
        # Screen 3: Activity Detail Modal
        page.evaluate("if (typeof openActDetailModal === 'function') openActDetailModal(1);")
        page.wait_for_timeout(600)
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_activity_detail.png"))
        print("Captured screen_activity_detail.png")
        page.evaluate("if (typeof closeSheet === 'function') closeSheet();")
        page.wait_for_timeout(400)
        
        # Screen 4: Excel 4 Weeks
        page.evaluate("if (typeof navTo === 'function') navTo('scrExcelWeeks');")
        page.wait_for_timeout(600)
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_excel_weeks.png"))
        print("Captured screen_excel_weeks.png")
        
        # Screen 5: Calendar
        page.evaluate("if (typeof navTo === 'function') navTo('scrCalendar');")
        page.wait_for_timeout(600)
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_calendar.png"))
        print("Captured screen_calendar.png")
        
        # Screen 6: Indicators (7 categories)
        page.evaluate("if (typeof navTo === 'function') navTo('scrIndicators');")
        page.wait_for_timeout(600)
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_indicators.png"))
        print("Captured screen_indicators.png")
        
        # Screen 7: History
        page.evaluate("if (typeof navTo === 'function') navTo('scrHistory');")
        page.wait_for_timeout(600)
        phone_elem.screenshot(path=os.path.join(OUT_DIR, "screen_history.png"))
        print("Captured screen_history.png")

        # Full simulator desktop capture
        page.evaluate("if (typeof navTo === 'function') navTo('scrDashboard');")
        page.wait_for_timeout(600)
        page.screenshot(path=os.path.join(OUT_DIR, "simulator_desktop.png"))
        print("Captured simulator_desktop.png")

        browser.close()
        print("All screenshots successfully captured!")

if __name__ == "__main__":
    run()

