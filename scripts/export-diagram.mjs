// Renders diagram-design HTML files in headless Chromium (the deck's Playwright) and saves the diagram's
// <svg> as a 2x PNG with a transparent background, next to the source and in deck/public/diagrams/.
// Usage (repo root): node scripts/export-diagram.mjs docs/design/diagrams/*.html
import { mkdirSync, copyFileSync } from 'node:fs'
import { resolve, basename, dirname, join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { chromium } from '../deck/node_modules/playwright-chromium/index.mjs'

const files = process.argv.slice(2)
if (!files.length) { console.error('usage: node scripts/export-diagram.mjs <diagram.html>...'); process.exit(1) }
const browser = await chromium.launch(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {})
const page = await browser.newPage({ deviceScaleFactor: 2, viewport: { width: 1600, height: 1000 } })
mkdirSync('deck/public/diagrams', { recursive: true })
for (const f of files) {
  await page.goto(pathToFileURL(resolve(f)).href + '?motion=static', { waitUntil: 'networkidle' })
  await page.evaluate(() => document.fonts.ready)
  const out = join(dirname(f), basename(f, '.html') + '.png')
  await page.locator('svg').first().screenshot({ path: out, omitBackground: true })
  copyFileSync(out, join('deck/public/diagrams', basename(out)))
  console.log('✓', out, '-> deck/public/diagrams/' + basename(out))
}
await browser.close()
