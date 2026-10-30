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
    extreme-claude [command] [options]
    npx @moamen-r/extreme-claude [command] [options]

  Commands:
    install (default)  Run 1-click cross-platform ecosystem installation
    update             Check for & apply all updates (new skills, MCPs, plugins, agents & tools)
    skills             Install/sync all curated skills globally from upstream links
    --help, -h         Show this help message
    --version, -v      Show current package version

  Options:
    --mode <type>      Select backend directly: 'official' or 'omniroute'
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

function runFullUpdate() {
  console.log('\n======================================================');
  console.log('  Extreme Claude — Full Ecosystem Update & Health Sync');
  console.log('======================================================\n');

  const userHome = process.env.USERPROFILE || process.env.HOME;
  const userClaudeDir = path.join(userHome, '.claude');
  const userClaudeJson = path.join(userHome, '.claude.json');
  const userSettingsJson = path.join(userClaudeDir, 'settings.json');
  const userAgentsDir = path.join(userClaudeDir, 'agents');
  const userSkillsDir = path.join(userClaudeDir, 'skills');

  // 1. Check for Repository/Package Git updates if inside a clone
  console.log('[1/6] Checking for repository & package updates...');
  try {
    const gitCheck = spawnSync('git', ['pull', '--ff-only'], { cwd: rootDir, encoding: 'utf8' });
    if (gitCheck.status === 0) {
      console.log('  -> ' + (gitCheck.stdout.trim() || 'Repository is up to date.'));
    }
  } catch (e) {
    // Git check non-fatal
  }

  // 2. Check and Sync MCP Servers (configs/.claude.json -> ~/.claude.json)
  console.log('\n[2/6] Checking for new MCP servers...');
  const repoMcpPath = path.join(rootDir, 'configs', '.claude.json');
  if (fs.existsSync(repoMcpPath)) {
    try {
      const repoMcp = JSON.parse(fs.readFileSync(repoMcpPath, 'utf8'));
      let userMcp = { mcpServers: {} };
      if (fs.existsSync(userClaudeJson)) {
        userMcp = JSON.parse(fs.readFileSync(userClaudeJson, 'utf8'));
      }
      if (!userMcp.mcpServers) userMcp.mcpServers = {};

      let addedMcpCount = 0;
      if (repoMcp.mcpServers) {
        for (const [serverName, serverDef] of Object.entries(repoMcp.mcpServers)) {
          if (!userMcp.mcpServers[serverName]) {
            userMcp.mcpServers[serverName] = serverDef;
            console.log(`  [+] Added new MCP server: ${serverName}`);
            addedMcpCount++;
          }
        }
      }
      if (addedMcpCount > 0) {
        fs.writeFileSync(userClaudeJson, JSON.stringify(userMcp, null, 2), 'utf8');
        console.log(`  -> Successfully merged ${addedMcpCount} new MCP server(s) into ~/.claude.json`);
      } else {
        console.log('  -> All MCP servers are up to date.');
      }
    } catch (err) {
      console.warn(`  [!] MCP sync notice: ${err.message}`);
    }
  }

  // 3. Check and Sync Marketplaces & Plugins (configs/.claude/settings.json -> ~/.claude/settings.json)
  console.log('\n[3/6] Checking for new Plugin Marketplaces & Plugins...');
  const repoSettingsPath = path.join(rootDir, 'configs', '.claude', 'settings.json');
  if (fs.existsSync(repoSettingsPath) && fs.existsSync(userSettingsJson)) {
    try {
      const repoSettings = JSON.parse(fs.readFileSync(repoSettingsPath, 'utf8'));
      const userSettings = JSON.parse(fs.readFileSync(userSettingsJson, 'utf8'));

      let modified = false;

      // Check extraKnownMarketplaces
      if (repoSettings.extraKnownMarketplaces) {
        if (!userSettings.extraKnownMarketplaces) userSettings.extraKnownMarketplaces = {};
        for (const [mkName, mkDef] of Object.entries(repoSettings.extraKnownMarketplaces)) {
          if (!userSettings.extraKnownMarketplaces[mkName]) {
            userSettings.extraKnownMarketplaces[mkName] = mkDef;
            console.log(`  [+] Added new marketplace: ${mkName}`);
            modified = true;
          }
        }
      }

      // Check enabledPlugins
      if (repoSettings.enabledPlugins) {
        if (!userSettings.enabledPlugins) userSettings.enabledPlugins = {};
        for (const [pluginName, pluginVal] of Object.entries(repoSettings.enabledPlugins)) {
          if (userSettings.enabledPlugins[pluginName] === undefined) {
            userSettings.enabledPlugins[pluginName] = pluginVal;
            console.log(`  [+] Added new plugin: ${pluginName}`);
            modified = true;
          }
        }
      }

      if (modified) {
        fs.writeFileSync(userSettingsJson, JSON.stringify(userSettings, null, 2), 'utf8');
        console.log('  -> Updated ~/.claude/settings.json with latest marketplaces & plugins.');
      } else {
        console.log('  -> Marketplaces & plugins are up to date.');
      }
    } catch (err) {
      console.warn(`  [!] Settings sync notice: ${err.message}`);
    }
  }

  // 4. Check and Sync Specialist Agents (configs/.claude/agents -> ~/.claude/agents)
  console.log('\n[4/6] Checking for new or updated specialist agents...');
  const repoAgentsDir = path.join(rootDir, 'configs', '.claude', 'agents');
  if (fs.existsSync(repoAgentsDir)) {
    if (!fs.existsSync(userAgentsDir)) fs.mkdirSync(userAgentsDir, { recursive: true });
    const repoAgentFiles = fs.readdirSync(repoAgentsDir).filter(f => f.endsWith('.md'));
    let agentCount = 0;
    for (const f of repoAgentFiles) {
      const srcPath = path.join(repoAgentsDir, f);
      const dstPath = path.join(userAgentsDir, f);
      if (!fs.existsSync(dstPath)) {
        fs.copyFileSync(srcPath, dstPath);
        agentCount++;
      }
    }
    if (agentCount > 0) {
      console.log(`  -> Deployed ${agentCount} newly added agent(s) to ~/.claude/agents`);
    } else {
      console.log(`  -> All ${repoAgentFiles.length} specialist agents are current.`);
    }
  }

  // 5. Check for new Skills in manifest and upgrade existing skills
  console.log('\n[5/6] Checking and updating global skills...');
  const skillsManifestPath = path.join(rootDir, 'configs', 'skills.json');
  if (fs.existsSync(skillsManifestPath)) {
    const manifest = JSON.parse(fs.readFileSync(skillsManifestPath, 'utf8'));
    const npxCmd = isWindows ? 'npx.cmd' : 'npx';

    for (const item of manifest) {
      const skillDest = path.join(userSkillsDir, item.skill);
      if (!fs.existsSync(skillDest)) {
        console.log(`  [+] Found new skill in manifest: ${item.skill} (${item.package}) -> Installing...`);
        spawnSync(npxCmd, ['-y', 'skills', 'add', item.package, '--skill', item.skill, '--agent', 'claude-code', '-g', '-y'], {
          stdio: 'inherit',
          cwd: rootDir
        });
      }
    }

    console.log('  -> Upgrading all existing skills to latest upstream releases...');
    spawnSync(npxCmd, ['-y', 'skills', 'update', '-g', '-y'], {
      stdio: 'inherit',
      cwd: rootDir
    });
  }

  // 6. Check Core Toolchains (npm & uv)
  console.log('\n[6/6] Checking core toolchain packages...');
  const npmCmd = isWindows ? 'npm.cmd' : 'npm';
  const coreNpmPackages = ['@anthropic-ai/claude-code', 'omniroute', 'claude-mem', 'skills', '@alibaba-group/open-code-review'];
  console.log(`  -> Checking npm tools for updates...`);
  spawnSync(npmCmd, ['update', '-g', ...coreNpmPackages], {
    stdio: 'inherit',
    cwd: rootDir
  });

  const uvCmd = isWindows ? 'uv.exe' : 'uv';
  try {
    console.log('  -> Upgrading Python toolchains (Serena, Graphify, Scrapling)...');
    spawnSync(uvCmd, ['tool', 'upgrade', '--all'], {
      stdio: 'inherit',
      cwd: rootDir
    });
  } catch (e) {
    // uv not in PATH or tool upgrade skipped
  }

  console.log('\n======================================================');
  console.log('  Update Complete! Your ecosystem is fully synchronized.');
  console.log('======================================================\n');
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
  runFullUpdate();
} else {
  runSetup();
}
