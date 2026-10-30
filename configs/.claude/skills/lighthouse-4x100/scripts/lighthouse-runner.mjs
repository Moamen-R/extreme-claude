#!/usr/bin/env node
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const url = process.argv[2] || 'http://localhost:3000';
const outputPath = path.resolve(process.cwd(), './.lighthouse-report.json');

console.log(`\n======================================================`);
console.log(`🚀 Starting Deterministic Lighthouse 4x100 Audit`);
console.log(`🎯 Target URL: ${url}`);
console.log(`======================================================\n`);

try {
  const args = [
    '--yes',
    'lighthouse',
    url,
    '--output=json',
    `--output-path=${outputPath}`,
    '--chrome-flags=--headless=new --incognito --disable-extensions --no-sandbox',
    '--only-categories=performance,accessibility,best-practices,seo',
  ];
  spawnSync('npx', args, { stdio: 'inherit', shell: true });
} catch (err) {
  console.error(`⚠️ Lighthouse finished with warning/exit signal:`, err.message);
}

if (!fs.existsSync(outputPath)) {
  console.error(`❌ Error: Lighthouse report was not created at ${outputPath}`);
  process.exit(1);
}

const report = JSON.parse(fs.readFileSync(outputPath, 'utf8'));

// Delete temporary file to keep repository clean
try {
  fs.unlinkSync(outputPath);
} catch {}

console.log(`\n======================================================`);
console.log(`📊 LIGHTHOUSE 4x100 SCORECARD`);
console.log(`======================================================`);

const scores = {};
let allPassed = true;

for (const [key, category] of Object.entries(report.categories)) {
  const score = Math.round(category.score * 100);
  scores[key] = score;
  const pass = key === 'performance' ? score >= 95 : score === 100;
  if (!pass) allPassed = false;
  const badge = pass ? '✅ PASS' : '❌ NEEDS ATTENTION';
  console.log(`${badge.padEnd(20)} ${category.title.padEnd(20)}: ${score} / 100`);
}

console.log(`\n======================================================`);
console.log(`🔍 DETAILED FAILING AUDITS (score < 1.0)`);
console.log(`======================================================\n`);

const categories = report.categories;
let failCount = 0;

for (const [catKey, cat] of Object.entries(categories)) {
  const failingAudits = cat.auditRefs
    .map((ref) => report.audits[ref.id])
    .filter((audit) => audit && audit.score !== null && audit.score < 1);

  if (failingAudits.length > 0) {
    console.log(`--- [Category: ${cat.title.toUpperCase()}] ---`);
    for (const audit of failingAudits) {
      failCount++;
      console.log(`\n🔴 [${audit.id}] ${audit.title} (Score: ${Math.round(audit.score * 100)}/100, Value: ${audit.displayValue || 'N/A'})`);
      if (audit.explanation) {
        console.log(`   💡 Reason: ${audit.explanation}`);
      }
      if (audit.details?.items?.length) {
        console.log(`   📌 Failing Elements / Locations:`);
        audit.details.items.slice(0, 5).forEach((item, idx) => {
          if (item.node?.selector) {
            console.log(`     ${idx + 1}. Selector: ${item.node.selector}`);
            if (item.node.snippet) console.log(`        Snippet:  ${item.node.snippet}`);
            if (item.node.explanation) console.log(`        Fix:      ${item.node.explanation.replace(/\n/g, ' ')}`);
          } else if (item.url) {
            console.log(`     ${idx + 1}. Resource: ${item.url} (Wasted: ${item.wastedMs ? item.wastedMs + 'ms' : (item.wastedBytes ? Math.round(item.wastedBytes / 1024) + 'KB' : 'N/A')})`);
          }
        });
      }
    }
    console.log('');
  }
}

if (failCount === 0) {
  console.log(`🎉 PERFECT AUDIT! 100% of checked criteria passed.`);
}

console.log(`======================================================\n`);

if (!allPassed) {
  console.log(`⚠️ Some categories did not meet the 95-100 threshold.`);
  process.exit(1);
} else {
  console.log(`🏆 ALL 4 CATEGORIES ACHIEVED 95-100/100!`);
  process.exit(0);
}
