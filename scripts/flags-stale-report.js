/*
  Flags Stale Report
  - Reads runtime flag names via packages/config/flags.js (listFlags keys)
  - Reads metadata from packages/config/flags-metadata.json
  - Emits flags-stale-report.json and a human summary
  - Classifies as stale if: missing owner, missing/invalid expiry, or expiry in ≤ 14 days
*/

const fs = require('fs');
const path = require('path');

function readJson(p) {
  try {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch (e) {
    return null;
  }
}

function daysUntil(dateStr) {
  if (!dateStr) return null;
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return null;
  const ms = d.getTime() - Date.now();
  return Math.floor(ms / 86400000);
}

function main() {
  const repoRoot = path.resolve(__dirname, '..');
  const flagsModulePath = path.join(repoRoot, 'packages', 'config', 'flags.js');
  const metadataPath = path.join(repoRoot, 'packages', 'config', 'flags-metadata.json');

  // Load flag names at runtime via listFlags keys
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const flagsModule = require(flagsModulePath);
  const names = Object.keys(flagsModule.listFlags());

  const metadata = readJson(metadataPath) || {};
  const stale = [];
  const missing = [];
  const warn = [];

  for (const name of names) {
    const meta = metadata[name] || {};
    const owner = (meta.owner || '').trim();
    const expiresAt = (meta.expiresAt || '').trim();
    const remain = daysUntil(expiresAt);

    if (!owner || !expiresAt) {
      missing.push({ name, owner: !!owner, expiresAt: !!expiresAt });
      continue;
    }

    if (remain === null) {
      stale.push({ name, reason: 'invalid_expiry_format', owner, expiresAt });
      continue;
    }
    if (remain <= 0) {
      stale.push({ name, reason: 'expired', owner, expiresAt, daysRemaining: remain });
      continue;
    }
    if (remain <= 14) {
      warn.push({ name, reason: 'expiring_soon', owner, expiresAt, daysRemaining: remain });
    }
  }

  const report = {
    generatedAt: new Date().toISOString(),
    totalFlags: names.length,
    missingCount: missing.length,
    staleCount: stale.length,
    warnCount: warn.length,
    missing,
    stale,
    warn
  };

  const outPath = path.join(process.cwd(), 'flags-stale-report.json');
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

  // Human summary
  const lines = [];
  lines.push(`# Flags Stale Report`);
  lines.push(`Generated: ${report.generatedAt}`);
  lines.push(`Total flags: ${report.totalFlags}`);
  lines.push(`Missing meta: ${report.missingCount} • Stale: ${report.staleCount} • Warning: ${report.warnCount}`);
  if (missing.length) {
    lines.push(`\n## Missing owner/expiry`);
    missing.forEach((m) => lines.push(`- ${m.name}: owner=${m.owner ? 'ok' : 'missing'}, expiry=${m.expiresAt ? 'ok' : 'missing'}`));
  }
  if (stale.length) {
    lines.push(`\n## Expired / Invalid`);
    stale.forEach((s) => lines.push(`- ${s.name}: ${s.reason} (owner=${s.owner}, expiresAt=${s.expiresAt})`));
  }
  if (warn.length) {
    lines.push(`\n## Expiring soon (≤14d)`);
    warn.forEach((w) => lines.push(`- ${w.name}: ${w.daysRemaining}d remaining (owner=${w.owner}, expiresAt=${w.expiresAt})`));
  }
  fs.writeFileSync(path.join(process.cwd(), 'flags-stale-summary.md'), lines.join('\n'));
  console.log(lines.join('\n'));
}

main();


