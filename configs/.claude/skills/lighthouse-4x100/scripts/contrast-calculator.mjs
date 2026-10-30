#!/usr/bin/env node
/**
 * Exact WCAG 2.1 Color Contrast Ratio Calculator
 * Usage: node contrast-calculator.mjs #HEX_FG #HEX_BG
 */

const fgHex = process.argv[2];
const bgHex = process.argv[3];

if (!fgHex || !bgHex) {
  console.log('Usage: node contrast-calculator.mjs <foreground-hex> <background-hex>');
  console.log('Example: node contrast-calculator.mjs "#080612" "#FDA136"');
  process.exit(1);
}

function hexToRgb(hex) {
  const clean = hex.replace('#', '');
  const r = parseInt(clean.substring(0, 2), 16) / 255;
  const g = parseInt(clean.substring(2, 4), 16) / 255;
  const b = parseInt(clean.substring(4, 6), 16) / 255;
  return [r, g, b];
}

function getLuminance([r, g, b]) {
  const toLinear = (c) => (c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
  return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b);
}

const lum1 = getLuminance(hexToRgb(fgHex));
const lum2 = getLuminance(hexToRgb(bgHex));

const brightest = Math.max(lum1, lum2);
const darkest = Math.min(lum1, lum2);
const ratio = (brightest + 0.05) / (darkest + 0.05);
const rounded = Math.round(ratio * 100) / 100;

console.log(`\n========================================`);
console.log(`🎨 WCAG Contrast Ratio: ${rounded}:1`);
console.log(`Foreground: ${fgHex}`);
console.log(`Background: ${bgHex}`);
console.log(`========================================`);
console.log(`WCAG AA Normal Text (≥4.5:1): ${ratio >= 4.5 ? '✅ PASS' : '❌ FAIL'}`);
console.log(`WCAG AA Large Text  (≥3.0:1): ${ratio >= 3.0 ? '✅ PASS' : '❌ FAIL'}`);
console.log(`WCAG AAA Normal Text(≥7.0:1): ${ratio >= 7.0 ? '✅ PASS' : '❌ FAIL'}`);
console.log(`========================================\n`);
