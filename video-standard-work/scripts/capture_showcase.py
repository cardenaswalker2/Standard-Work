import os
import time
from playwright.sync_api import sync_playwright

WORKSPACE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "showcase"))
os.makedirs(OUT_DIR, exist_ok=True)

def run():
    with sync_playwright() as p:
        browser = p.chromium.launch(channel="chrome", headless=True)
        page = browser.new_page(viewport={"width": 1920, "height": 1200}, device_scale_factor=2)
        
        prueba_url = f"file:///{WORKSPACE}/prueba.html".replace("\\", "/")
        print(f"Loading {prueba_url}...")
        page.goto(prueba_url)
        page.wait_for_timeout(1000)
        
        phone = page.locator(".phone")
        
        # 1. Login screen
        phone.screenshot(path=os.path.join(OUT_DIR, "01_login.png"))
        print("Captured 01_login.png")
        
        # 2. Login interaction (touch ripple on first user)
        page.evaluate("""() => {
            const btn = document.querySelector('.profile-btn');
            if (btn) {
                btn.style.transform = 'scale(0.96)';
                btn.style.borderColor = '#0095D9';
                btn.style.boxShadow = '0 0 16px rgba(0, 149, 217, 0.4)';
            }
        }""")
        phone.screenshot(path=os.path.join(OUT_DIR, "02_login_tap.png"))
        print("Captured 02_login_tap.png")
        
        # Login
        page.evaluate("if (typeof login === 'function') login(Object.keys(USERS)[0]);")
        page.wait_for_timeout(800)
        
        # 3. Dashboard main
        phone.screenshot(path=os.path.join(OUT_DIR, "03_dashboard.png"))
        print("Captured 03_dashboard.png")
        
        # 4. Dashboard close-up of Gauge
        gauge = page.locator(".kpi-gauge-card")
        if gauge.count() > 0:
            gauge.screenshot(path=os.path.join(OUT_DIR, "04_gauge_card.png"))
        
        # 5. Activity check interaction
        page.evaluate("""() => {
            const check = document.querySelector('.act-check');
            if (check) {
                check.style.background = '#16A34A';
                check.style.borderColor = '#16A34A';
                check.innerHTML = '✓';
                check.style.color = '#fff';
            }
            const card = document.querySelector('.act-card');
            if (card) {
                card.style.borderLeftColor = '#16A34A';
            }
        }""")
        phone.screenshot(path=os.path.join(OUT_DIR, "05_dashboard_checked.png"))
        print("Captured 05_dashboard_checked.png")
        
        # 6. Open Activity Detail Modal
        page.evaluate("if (typeof openActDetailModal === 'function') openActDetailModal(1);")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "06_activity_modal.png"))
        print("Captured 06_activity_modal.png")
        
        # Close sheet
        page.evaluate("if (typeof closeSheet === 'function') closeSheet();")
        page.wait_for_timeout(400)
        
        # 7. Four Weeks Planning (scrExcelWeeks)
        page.evaluate("if (typeof navTo === 'function') navTo('scrExcelWeeks');")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "07_four_weeks.png"))
        print("Captured 07_four_weeks.png")
        
        # Scroll down in four weeks
        page.evaluate("""() => {
            const scr = document.getElementById('scrExcelWeeks');
            if (scr) scr.scrollTop = 250;
        }""")
        page.wait_for_timeout(400)
        phone.screenshot(path=os.path.join(OUT_DIR, "08_four_weeks_scroll.png"))
        print("Captured 08_four_weeks_scroll.png")
        
        # 8. Calendar View (scrCalendar)
        page.evaluate("if (typeof navTo === 'function') navTo('scrCalendar');")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "09_calendar.png"))
        print("Captured 09_calendar.png")
        
        # Select another day in calendar (e.g. day 2 or 3)
        page.evaluate("""() => {
            const days = document.querySelectorAll('#scrCalendar .day-pill');
            if (days.length > 2) days[2].click();
        }""")
        page.wait_for_timeout(400)
        phone.screenshot(path=os.path.join(OUT_DIR, "10_calendar_day_select.png"))
        print("Captured 10_calendar_day_select.png")
        
        # 9. Indicators Screen (scrIndicators)
        page.evaluate("if (typeof navTo === 'function') navTo('scrIndicators');")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "11_indicators.png"))
        print("Captured 11_indicators.png")
        
        # Scroll indicators
        page.evaluate("""() => {
            const scr = document.getElementById('scrIndicators');
            if (scr) scr.scrollTop = 200;
        }""")
        page.wait_for_timeout(400)
        phone.screenshot(path=os.path.join(OUT_DIR, "12_indicators_scroll.png"))
        print("Captured 12_indicators_scroll.png")
        
        # 10. History / Audit (scrHistory)
        page.evaluate("if (typeof navTo === 'function') navTo('scrHistory');")
        page.wait_for_timeout(600)
        phone.screenshot(path=os.path.join(OUT_DIR, "13_history.png"))
        print("Captured 13_history.png")
        
        # 11. Full Simulator Desktop
        page.evaluate("if (typeof navTo === 'function') navTo('scrDashboard');")
        page.wait_for_timeout(500)
        page.screenshot(path=os.path.join(OUT_DIR, "14_desktop_simulator.png"))
        print("Captured 14_desktop_simulator.png")
        
        browser.close()
        print("All showcase captures completed successfully!")

if __name__ == "__main__":
    run()

