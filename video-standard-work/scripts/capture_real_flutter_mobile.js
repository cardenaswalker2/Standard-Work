const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const WORKSPACE = path.resolve(__dirname, '..', '..');
const OUT_DIR = path.resolve(__dirname, '..', 'public', 'showcase');
fs.mkdirSync(OUT_DIR, { recursive: true });

async function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({
    width: 390,
    height: 844,
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true
  });

  const htmlUrl = 'file:///' + path.join(WORKSPACE, 'flutter_mobile_app_spec.html').replace(/\\/g, '/');
  console.log('Loading:', htmlUrl);
  await page.goto(htmlUrl, { waitUntil: 'networkidle0' });
  await sleep(600);

  const phone = await page.$('.phone-viewport');

  // 1. Login screen
  console.log('Capturing 01_login.png...');
  await phone.screenshot({ path: path.join(OUT_DIR, '01_login.png') });

  // 2. Login tap interaction
  console.log('Capturing 02_login_tap.png...');
  await page.evaluate(() => {
    const c = document.getElementById('cardCM');
    if (c) c.classList.add('tapped');
  });
  await sleep(150);
  await phone.screenshot({ path: path.join(OUT_DIR, '02_login_tap.png') });

  // Transition to Dashboard
  await page.evaluate(() => {
    goToScreen('scrDashboard');
  });
  await sleep(400);

  // 3. Dashboard main
  console.log('Capturing 03_dashboard.png...');
  await phone.screenshot({ path: path.join(OUT_DIR, '03_dashboard.png') });

  // 4. Activity check (toggle Act 3 to Realizada)
  console.log('Capturing 05_dashboard_checked.png...');
  await page.evaluate(() => {
    toggleAct3();
  });
  await sleep(300);
  await phone.screenshot({ path: path.join(OUT_DIR, '05_dashboard_checked.png') });

  // 5. Open Bottom Sheet Modal
  console.log('Capturing 06_activity_modal.png...');
  await page.evaluate(() => {
    openMoveSheet('Revisión OEE & Paradas');
  });
  await sleep(350);
  await phone.screenshot({ path: path.join(OUT_DIR, '06_activity_modal.png') });

  // Close sheet
  await page.evaluate(() => {
    closeMoveSheetDirect();
  });
  await sleep(250);

  // 6. 4 Weeks Planning screen
  console.log('Capturing 07_four_weeks.png...');
  await page.evaluate(() => {
    goToScreen('scrPlanning');
  });
  await sleep(350);
  await phone.screenshot({ path: path.join(OUT_DIR, '07_four_weeks.png') });

  // 7. 4 Weeks Planning scrolled
  console.log('Capturing 08_four_weeks_scroll.png...');
  await page.evaluate(() => {
    const list = document.getElementById('planningList');
    if (list) list.scrollTop = 160;
  });
  await sleep(300);
  await phone.screenshot({ path: path.join(OUT_DIR, '08_four_weeks_scroll.png') });

  // 8. Calendar / Day navigation
  console.log('Capturing 09_calendar.png and 10_calendar_day_select.png...');
  await page.evaluate(() => {
    goToScreen('scrDashboard');
    selectDay(1);
  });
  await sleep(300);
  await phone.screenshot({ path: path.join(OUT_DIR, '09_calendar.png') });

  await page.evaluate(() => {
    selectDay(2); // Martes
  });
  await sleep(300);
  await phone.screenshot({ path: path.join(OUT_DIR, '10_calendar_day_select.png') });

  // 9. Indicators Screen
  console.log('Capturing 11_indicators.png and 12_indicators_scroll.png...');
  await page.evaluate(() => {
    goToScreen('scrIndicators');
  });
  await sleep(350);
  await phone.screenshot({ path: path.join(OUT_DIR, '11_indicators.png') });

  await page.evaluate(() => {
    const scr = document.getElementById('scrIndicators');
    if (scr) scr.scrollTop = 180;
  });
  await sleep(300);
  await phone.screenshot({ path: path.join(OUT_DIR, '12_indicators_scroll.png') });

  // 10. History / Audit screen
  console.log('Capturing 13_history.png...');
  await page.evaluate(() => {
    const scr = document.getElementById('scrIndicators');
    if (scr) scr.scrollTop = 80;
  });
  await sleep(250);
  await phone.screenshot({ path: path.join(OUT_DIR, '13_history.png') });

  await browser.close();
  console.log('ALL FLUTTER SHOWCASE SCREENS CAPTURED SUCCESSFULLY!');
}

run().catch(err => {
  console.error('Error in capture:', err);
  process.exit(1);
});

