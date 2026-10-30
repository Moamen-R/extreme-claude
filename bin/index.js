#!/usr/bin/env node

/**
 * Extreme Claude CLI
 * Turnkey cross-platform installer & ecosystem manager for Claude Code
 */

const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const rootDir = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
const isWindows = process.platform === 'win32';

function showHelp() {
  console.log(`
  Extreme Claude CLI — Universal Installer & Ecosystem Manager

  Usage:
    npx extreme-claude [command] [options]

  Commands:
    install (default)  Run 1-click cross-platform ecosystem installation
    skills             Install/sync all curated skills globally from upstream links
    update             Update all installed global skills to latest versions
    --help, -h         Show this help message
    --version, -v      Show current package version
  `);
}

function installSkills() {
  console.log('\n[Extreme-Claude] Installing curated skills from live upstream sources...\n');
  const skillsManifestPath = path.join(rootDir, 'configs', 'skills.json');
  if (!fs.existsSync(skillsManifestPath)) {
    console.error('Skills manifest not found at configs/skills.json');
    process.exit(1);
  }

  const manifest = JSON.parse(fs.readFileSync(skillsManifestPath, 'utf8'));
  for (const item of manifest) {
    console.log(`-> Installing skill: ${item.skill} from ${item.package}...`);
    const cmd = isWindows ? 'npx.cmd' : 'npx';
    const result = spawnSync(cmd, ['-y', 'skills', 'add', item.package, '--skill', item.skill, '--agent', 'claude-code', '-g', '-y'], {
      stdio: 'inherit',
      cwd: rootDir
    });
    if (result.status !== 0) {
      console.warn(`[Notice] Could not install skill ${item.skill} from ${item.package}.`);
    }
  }
  console.log('\n[Extreme-Claude] Skills installation routine completed.\n');
}

function updateSkills() {
  console.log('\n[Extreme-Claude] Updating all globally installed skills to latest versions...\n');
  const cmd = isWindows ? 'npx.cmd' : 'npx';
  spawnSync(cmd, ['-y', 'skills', 'update', '-g', '-y'], {
    stdio: 'inherit',
    cwd: rootDir
  });
}

function runSetup() {
  console.log('\n[Extreme-Claude] Detecting platform and launching setup...\n');

  let modeArg = '';
  const modeIdx = args.indexOf('--mode');
  if (modeIdx !== -1 && args[modeIdx + 1]) {
    modeArg = args[modeIdx + 1].toLowerCase() === 'omniroute' ? 'OmniRoute' : 'Official';
  }

  if (isWindows) {
    const psScript = path.join(rootDir, 'Install-ClaudeSetup.ps1');
    const psArgs = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', psScript];
    if (modeArg) {
      psArgs.push('-Mode', modeArg);
    }
    console.log(`Detected Windows. Launching PowerShell: ${psScript}`);
    const result = spawnSync('powershell.exe', psArgs, {
      stdio: 'inherit',
      cwd: rootDir
    });
    process.exit(result.status || 0);
  } else {
    const shScript = path.join(rootDir, 'install.sh');
    const shArgs = [shScript];
    if (modeArg) {
      shArgs.push(modeArg);
    }
    console.log(`Detected Linux/Unix. Launching Bash: ${shScript}`);
    const result = spawnSync('bash', shArgs, {
      stdio: 'inherit',
      cwd: rootDir
    });
    process.exit(result.status || 0);
  }
}

// Command dispatcher
if (args.includes('--help') || args.includes('-h')) {
  showHelp();
} else if (args.includes('--version') || args.includes('-v')) {
  const pkg = require('../package.json');
  console.log(`@moamen-r/extreme-claude v${pkg.version}`);
} else if (args[0] === 'skills') {
  installSkills();
} else if (args[0] === 'update') {
  updateSkills();
} else {
  runSetup();
}
