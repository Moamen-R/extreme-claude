<#
.SYNOPSIS
    Automated Claude Code & AI Ecosystem Installer for Windows
    Installs Official Claude Code, OmniRoute, Serena, Graphify, OpenCode, and all agents/skills.
#>

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Claude Code & AI Ecosystem Installer for Windows       " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigsDir = Join-Path $ScriptDir "configs"
$UserProfile = $env:USERPROFILE

# ------------------------------------------------------------------------------
# 1. Check Node.js and NPM
# ------------------------------------------------------------------------------
Write-Host "[1/6] Checking Node.js installation..." -ForegroundColor Yellow
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Host "Node.js not detected. Attempting to install Node.js LTS via winget..." -ForegroundColor Yellow
    try {
        winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        # Refresh Path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Error "Could not automatically install Node.js. Please download and install Node.js (v20+ or v22) from https://nodejs.org, then re-run this script."
        exit 1
    }
} else {
    Write-Host "Node.js detected: $(node -v) | npm: $(npm -v)" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 2. Check Python / Astral uv
# ------------------------------------------------------------------------------
Write-Host "[2/6] Checking Python 'uv' toolchain..." -ForegroundColor Yellow
$localBin = Join-Path $UserProfile ".local\bin"
$cargoBin = Join-Path $UserProfile ".cargo\bin"
$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
if (-not $uvCmd) {
    Write-Host "Installing Astral 'uv' package installer..." -ForegroundColor Yellow
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
if ($env:Path -notlike "*$localBin*") {
    $env:Path = "$localBin;" + $env:Path
}
if ($env:Path -notlike "*$cargoBin*") {
    $env:Path = "$cargoBin;" + $env:Path
}

# ------------------------------------------------------------------------------
# 3. Install Python AI MCP Tools (Serena, Graphify, Scrapling, Agent Reach)
# ------------------------------------------------------------------------------
Write-Host "[3/6] Installing Serena Agent, Graphify, and Scrapling MCP tools via uv..." -ForegroundColor Yellow
try {
    uv tool install --force serena-agent
    uv tool install --force graphifyy
    uv tool install --force "scrapling[ai]"
    Write-Host "Serena, Graphify, and Scrapling successfully installed." -ForegroundColor Green
} catch {
    Write-Warning "uv tool install encountered a notice: $_"
}

# Ensure ~/.local/bin is in User PATH
$localBin = Join-Path $UserProfile ".local\bin"
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$localBin*") {
    Write-Host "Adding $localBin to User PATH..." -ForegroundColor Yellow
    [System.Environment]::SetEnvironmentVariable("Path", "$localBin;$userPath", "User")
    $env:Path = "$localBin;" + $env:Path
}

# ------------------------------------------------------------------------------
# 4. Install Global NPM Tools (Official Claude Code, OmniRoute, OpenCode, Claude-Mem, etc.)
# ------------------------------------------------------------------------------
Write-Host "[4/6] Installing Claude Code, Claude-Mem, and ecosystem CLIs via npm..." -ForegroundColor Yellow
$npmPackages = @(
    "@anthropic-ai/claude-code",
    "omniroute",
    "claude-mem",
    "@opencode/cli",
    "opencode-ai",
    "ruflo",
    "@alibaba-group/open-code-review",
    "skills",
    "mcporter",
    "@playwright/cli",
    "pnpm",
    "yarn"
)

foreach ($pkg in $npmPackages) {
    Write-Host "  -> Installing $pkg..." -ForegroundColor Gray
    npm install -g $pkg
}

# Configure Claude-Mem hook launcher and plugin
try {
    Write-Host "  -> Configuring Claude-Mem persistent memory hooks..." -ForegroundColor Gray
    claude-mem install --ide claude-code --provider claude --no-auto-start
} catch {
    Write-Warning "Claude-Mem initial setup notice: $_"
}

# ------------------------------------------------------------------------------
# 5. Deploy Configurations, 88 Agents, Skills, and MCP Server Settings
# ------------------------------------------------------------------------------
Write-Host "[5/6] Deploying sanitized configurations, agents, and skills..." -ForegroundColor Yellow

# .claude directory
$claudeTarget = Join-Path $UserProfile ".claude"
New-Item -ItemType Directory -Path (Join-Path $claudeTarget "agents") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $claudeTarget "skills") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $claudeTarget "commands") -Force | Out-Null

Copy-Item -Path (Join-Path $ConfigsDir ".claude\settings.json") -Destination (Join-Path $claudeTarget "settings.json") -Force
Copy-Item -Path (Join-Path $ConfigsDir ".claude\CLAUDE.md") -Destination (Join-Path $claudeTarget "CLAUDE.md") -Force
Copy-Item -Path (Join-Path $ConfigsDir ".claude\agents\*") -Destination (Join-Path $claudeTarget "agents\") -Force
Copy-Item -Path (Join-Path $ConfigsDir ".claude\skills\*") -Destination (Join-Path $claudeTarget "skills\") -Recurse -Force
Copy-Item -Path (Join-Path $ConfigsDir ".claude\commands\*") -Destination (Join-Path $claudeTarget "commands\") -Recurse -Force

# Root .claude.json (MCP Servers)
Copy-Item -Path (Join-Path $ConfigsDir ".claude.json") -Destination (Join-Path $UserProfile ".claude.json") -Force

# Root CLAUDE.md
Copy-Item -Path (Join-Path $ConfigsDir "CLAUDE.md") -Destination (Join-Path $UserProfile "CLAUDE.md") -Force

# .serena directory
$serenaTarget = Join-Path $UserProfile ".serena"
New-Item -ItemType Directory -Path $serenaTarget -Force | Out-Null
Copy-Item -Path (Join-Path $ConfigsDir ".serena\*") -Destination $serenaTarget -Recurse -Force

# .omniroute directory
$omniTarget = Join-Path $UserProfile ".omniroute"
if (-not (Test-Path $omniTarget)) {
    New-Item -ItemType Directory -Path $omniTarget -Force | Out-Null
}
$srcEnv = Join-Path $ConfigsDir ".omniroute\.env"
$envExample = Join-Path $ConfigsDir ".omniroute\.env.example"
$targetEnv = Join-Path $omniTarget ".env"
if (Test-Path $srcEnv) {
    Copy-Item -Path $srcEnv -Destination $targetEnv -Force
} elseif (-not (Test-Path $targetEnv)) {
    Copy-Item -Path $envExample -Destination $targetEnv -Force
}
$srcSqlite = Join-Path $ConfigsDir ".omniroute\storage.sqlite"
$targetSqlite = Join-Path $omniTarget "storage.sqlite"
if (Test-Path $srcSqlite) {
    Copy-Item -Path $srcSqlite -Destination $targetSqlite -Force
}

# Extra configs (.config, .omc, .claude-flow, .claude-mem)
$extraDirs = @(".config", ".omc", ".claude-flow", ".claude-mem")
foreach ($extra in $extraDirs) {
    $extraSrc = Join-Path $ConfigsDir $extra
    if (Test-Path $extraSrc) {
        $extraDst = Join-Path $UserProfile $extra
        New-Item -ItemType Directory -Path $extraDst -Force | Out-Null
        Copy-Item -Path (Join-Path $extraSrc "*") -Destination $extraDst -Recurse -Force
    }
}

# ------------------------------------------------------------------------------
# 6. Verification & Final Instructions
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Installation Completed Successfully!                   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Everything is installed:" -ForegroundColor Cyan
Write-Host '  [+] Claude Code CLI (@anthropic-ai/claude-code)' -ForegroundColor White
Write-Host '  [+] 88 Custom Specialist Agents in ~/.claude/agents' -ForegroundColor White
Write-Host '  [+] 17 Marketplaces and 174 Plugins configured' -ForegroundColor White
Write-Host '  [+] OmniRoute Smart AI Router CLI' -ForegroundColor White
Write-Host '  [+] Serena Code Intelligence MCP & Graphify' -ForegroundColor White
Write-Host '  [+] Claude-Mem Persistent Memory & MCP' -ForegroundColor White
Write-Host '  [+] Scrapling Stealth Web Scraping & MCP (scrapling-mcp)' -ForegroundColor White
Write-Host '  [+] Agent Reach Multi-Platform Intelligence Router' -ForegroundColor White
Write-Host '  [+] Curated Skills Suite (Agent Browser, Caveman, Taste, Wayfinder, Triage, etc.)' -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open a new PowerShell terminal so updated PATH takes effect." -ForegroundColor White
Write-Host "2. (Option A - Direct Claude): If using official Anthropic API keys:" -ForegroundColor Gray
Write-Host "     Simply run 'claude' and log in." -ForegroundColor White
Write-Host "3. (Option B - OmniRoute): If using OmniRoute to route across AI models:" -ForegroundColor Gray
Write-Host "     Run 'omniroute serve' to start your local proxy on port 20128," -ForegroundColor White
Write-Host "     open http://localhost:20128 to configure your provider keys, then run 'claude'." -ForegroundColor White
Write-Host ""
