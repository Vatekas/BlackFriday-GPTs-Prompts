import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(args=['--no-sandbox', '--disable-setuid-sandbox'])
        page = await browser.new_page(
            viewport={'width': 800, 'height': 900},
            device_scale_factor=2
        )
        await page.goto('file:///app/esx_iphone/html/index.html')

        # Make the phone visible for the screenshot
        await page.evaluate('document.getElementById("phone-container").style.display = "flex";')

        # Take a screenshot
        await page.screenshot(path='/home/jules/verification/iphone_ui_no_bolt.png')
        await browser.close()

asyncio.run(main())
