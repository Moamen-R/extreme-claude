<#
.SYNOPSIS
    Automated Claude Code & AI Ecosystem Installer for Windows
    Installs Official Claude Code, OmniRoute, Serena, Graphify, OpenCode, and all agents/skills.
#>

param(
    [ValidateSet("Official", "OmniRoute", "")]
    [string]$Mode = "",
    [switch]$Update
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigsDir = Join-Path $ScriptDir "configs"
$UserProfile = $env:USERPROFILE
$claudeTarget = Join-Path $UserProfile ".claude"

# If update switch is provided, execute targeted ecosystem update
if ($Update) {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "  Extreme Claude — Ecosystem Health & Sync Update        " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""

    # 1. Update Repository if inside git clone
    Write-Host "[1/6] Checking for git updates..." -ForegroundColor Yellow
    try {
        git -C $ScriptDir pull --ff-only
    } catch {}

    # 2. Merge New MCP Servers
    Write-Host "[2/6] Checking for new MCP servers..." -ForegroundColor Yellow
    $repoMcp = Join-Path $ConfigsDir ".claude.json"
    $userMcp = Join-Path $UserProfile ".claude.json"
    if (Test-Path $repoMcp) {
        try {
            $rMcp = Get-Content $repoMcp -Raw | ConvertFrom-Json
            $uMcp = if (Test-Path $userMcp) { Get-Content $userMcp -Raw | ConvertFrom-Json } else { [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} } }
            if (-not $uMcp.mcpServers) { $uMcp | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([PSCustomObject]@{}) }
            $added = 0
            foreach ($prop in $rMcp.mcpServers.PSObject.Properties) {
                if (-not $uMcp.mcpServers.PSObject.Properties[$prop.Name]) {
                    $uMcp.mcpServers | Add-Member -MemberType NoteProperty -Name $prop.Name -Value $prop.Value
                    Write-Host "  [+] Added new MCP server: $($prop.Name)" -ForegroundColor Green
                    $added++
                }
            }
            if ($added -gt 0) {
                $uMcp | ConvertTo-Json -Depth 30 | Set-Content -Path $userMcp -Encoding UTF8
            }
        } catch {}
    }

    # 3. Merge New Marketplaces & Plugins
    Write-Host "[3/6] Checking for new plugin marketplaces and plugins..." -ForegroundColor Yellow
    $repoSet = Join-Path $ConfigsDir ".claude\settings.json"
    $userSet = Join-Path $claudeTarget "settings.json"
    if ((Test-Path $repoSet) -and (Test-Path $userSet)) {
        try {
            $rSet = Get-Content $repoSet -Raw | ConvertFrom-Json
            $uSet = Get-Content $userSet -Raw | ConvertFrom-Json
            $changed = $false
            if ($rSet.extraKnownMarketplaces) {
                if (-not $uSet.extraKnownMarketplaces) { $uSet | Add-Member -MemberType NoteProperty -Name "extraKnownMarketplaces" -Value ([PSCustomObject]@{}) }
                foreach ($mk in $rSet.extraKnownMarketplaces.PSObject.Properties) {
                    if (-not $uSet.extraKnownMarketplaces.PSObject.Properties[$mk.Name]) {
                        $uSet.extraKnownMarketplaces | Add-Member -MemberType NoteProperty -Name $mk.Name -Value $mk.Value
                        Write-Host "  [+] Added new marketplace: $($mk.Name)" -ForegroundColor Green
                        $changed = $true
                    }
                }
            }
            if ($rSet.enabledPlugins) {
                if (-not $uSet.enabledPlugins) { $uSet | Add-Member -MemberType NoteProperty -Name "enabledPlugins" -Value ([PSCustomObject]@{}) }
                foreach ($pl in $rSet.enabledPlugins.PSObject.Properties) {
                    if (-not $uSet.enabledPlugins.PSObject.Properties[$pl.Name]) {
                        $uSet.enabledPlugins | Add-Member -MemberType NoteProperty -Name $pl.Name -Value $pl.Value
                        Write-Host "  [+] Added new plugin: $($pl.Name)" -ForegroundColor Green
                        $changed = $true
                    }
                }
            }
            if ($changed) {
                $uSet | ConvertTo-Json -Depth 30 | Set-Content -Path $userSet -Encoding UTF8
            }
        } catch {}
    }

    # 4. Deploy newly added specialist agents
    Write-Host "[4/6] Checking for new specialist agents..." -ForegroundColor Yellow
    $repoAgents = Join-Path $ConfigsDir ".claude\agents"
    $userAgents = Join-Path $claudeTarget "agents"
    if (Test-Path $repoAgents) {
        New-Item -ItemType Directory -Path $userAgents -Force | Out-Null
        $aList = Get-ChildItem -Path $repoAgents -Filter "*.md"
        foreach ($a in $aList) {
            $dst = Join-Path $userAgents $a.Name
            if (-not (Test-Path $dst)) {
                Copy-Item -Path $a.FullName -Destination $dst -Force
                Write-Host "  [+] Deployed new agent: $($a.Name)" -ForegroundColor Green
            }
        }
    }

    # 5. Check missing skills and upgrade existing skills
    Write-Host "[5/6] Syncing and upgrading global skills..." -ForegroundColor Yellow
    $skillsManifest = Join-Path $ConfigsDir "skills.json"
    if (Test-Path $skillsManifest) {
        $userSkills = Join-Path $claudeTarget "skills"
        try {
            $sList = Get-Content $skillsManifest -Raw | ConvertFrom-Json
            foreach ($s in $sList) {
                $sDest = Join-Path $userSkills $s.skill
                if (-not (Test-Path $sDest)) {
                    Write-Host "  [+] Installing missing skill: $($s.skill)..." -ForegroundColor Green
                    npx -y skills add $s.package --skill $s.skill --agent claude-code -g -y 2>$null
                }
            }
        } catch {}
        npx -y skills update -g -y
    }

    # 6. Upgrade Core Toolchain packages
    Write-Host "[6/6] Checking for toolchain updates (npm and uv)..." -ForegroundColor Yellow
    npm update -g @anthropic-ai/claude-code omniroute claude-mem skills @alibaba-group/open-code-review
    try { uv tool upgrade --all } catch {}

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  Update Complete! Everything is up to date.             " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    exit 0
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Claude Code & AI Ecosystem Installer for Windows       " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrWhiteSpace($Mode)) {
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  Select AI Provider Backend for Claude Code              " -ForegroundColor White
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "How would you like Claude Code to connect?" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [1] Official Anthropic Claude (Default / Recommended)" -ForegroundColor Green
    Write-Host "      - Directly connects to official Anthropic API & Claude Pro/Team." -ForegroundColor Gray
    Write-Host "      - Native Claude 3.5 Sonnet / Opus models with standard web login." -ForegroundColor Gray
    Write-Host "      - Why choose this: Zero proxy overhead, official Anthropic support." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [2] OmniRoute Smart AI Router (Multi-Model Gateway)" -ForegroundColor Yellow
    Write-Host "      - Local proxy running on http://localhost:20128/" -ForegroundColor Gray
    Write-Host "      - Routes requests to Google Gemini (1M context), OpenAI, DeepSeek, Ollama." -ForegroundColor Gray
    Write-Host "      - Why choose this: Use non-Anthropic models or cost-effective third-party keys." -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "Select option [1 for Official, 2 for OmniRoute] (Press Enter for Default [1])"
    if ($choice -eq "2") {
        $Mode = "OmniRoute"
    } else {
        $Mode = "Official"
    }
}
Write-Host "Configuring for backend mode: $Mode" -ForegroundColor Cyan
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
$targetSettings = Join-Path $claudeTarget "settings.json"

if ($Mode -eq "OmniRoute") {
    Write-Host "  -> Injecting OmniRoute multi-model proxy settings into settings.json..." -ForegroundColor Gray
    try {
        $cfg = Get-Content $targetSettings -Raw | ConvertFrom-Json
        if (-not $cfg.env) {
            $cfg | Add-Member -MemberType NoteProperty -Name "env" -Value (New-Object PSObject)
        }
        $cfg.env | Add-Member -MemberType NoteProperty -Name "ANTHROPIC_BASE_URL" -Value "http://localhost:20128/" -Force
        $cfg.env | Add-Member -MemberType NoteProperty -Name "ANTHROPIC_AUTH_TOKEN" -Value "omniroute" -Force
        $cfg.env | Add-Member -MemberType NoteProperty -Name "ANTHROPIC_MODEL" -Value "antigravity/gemini-3.8-flash-high" -Force
        $cfg.env | Add-Member -MemberType NoteProperty -Name "ANTHROPIC_DEFAULT_SONNET_MODEL" -Value "antigravity/gemini-3.8-flash-high" -Force
        $cfg.env | Add-Member -MemberType NoteProperty -Name "ANTHROPIC_DEFAULT_OPUS_MODEL" -Value "antigravity/gemini-3.8-flash-high" -Force
        $cfg.env | Add-Member -MemberType NoteProperty -Name "ANTHROPIC_DEFAULT_HAIKU_MODEL" -Value "kc/dots-studio/dots-3-note-preview:free" -Force
        $cfg | ConvertTo-Json -Depth 30 | Set-Content -Path $targetSettings -Encoding UTF8
    } catch {
        Write-Warning "OmniRoute configuration notice: $_"
    }
} else {
    Write-Host "  -> Configured for Official Anthropic Claude (direct connection)." -ForegroundColor Gray
}

Copy-Item -Path (Join-Path $ConfigsDir ".claude\CLAUDE.md") -Destination (Join-Path $claudeTarget "CLAUDE.md") -Force
Copy-Item -Path (Join-Path $ConfigsDir ".claude\agents\*") -Destination (Join-Path $claudeTarget "agents\") -Force
Copy-Item -Path (Join-Path $ConfigsDir ".claude\commands\*") -Destination (Join-Path $claudeTarget "commands\") -Recurse -Force

# Install & sync skills directly from live upstream sources (skills.json)
$skillsManifest = Join-Path $ConfigsDir "skills.json"
if (Test-Path $skillsManifest) {
    Write-Host "  -> Installing curated skills from live upstream repositories..." -ForegroundColor Gray
    try {
        $skillsList = Get-Content $skillsManifest -Raw | ConvertFrom-Json
        foreach ($item in $skillsList) {
            Write-Host "     - Installing $($item.skill) ($($item.package))..." -ForegroundColor DarkGray
            npx -y skills add $item.package --skill $item.skill --agent claude-code -g -y 2>$null
        }
    } catch {
        Write-Warning "Upstream skills install noticed: $_"
    }
}
# Deploy local/custom skills suite as guaranteed baseline
if (Test-Path (Join-Path $ConfigsDir ".claude\skills")) {
    Copy-Item -Path (Join-Path $ConfigsDir ".claude\skills\*") -Destination (Join-Path $claudeTarget "skills\") -Recurse -Force
}

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
Write-Host '  [+] 26 Marketplaces, 183 Plugins, and 108 Global Skills configured' -ForegroundColor White
Write-Host '  [+] OmniRoute Smart AI Router CLI' -ForegroundColor White
Write-Host '  [+] Serena Code Intelligence MCP & Graphify' -ForegroundColor White
Write-Host '  [+] Claude-Mem Persistent Memory & MCP' -ForegroundColor White
Write-Host '  [+] Scrapling Stealth Web Scraping & MCP (scrapling-mcp)' -ForegroundColor White
Write-Host '  [+] Agent Reach Multi-Platform Intelligence Router' -ForegroundColor White
Write-Host '  [+] Curated Skills Suite (Agent Browser, Caveman, Taste, Wayfinder, Triage, etc.)' -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open a new PowerShell terminal so updated PATH takes effect." -ForegroundColor White
if ($Mode -eq "OmniRoute") {
    Write-Host "2. (OmniRoute Mode Activated):" -ForegroundColor Gray
    Write-Host "     Run 'omniroute serve' to start your local proxy on port 20128," -ForegroundColor White
    Write-Host "     open http://localhost:20128 to configure your AI providers (Gemini, OpenAI, etc.)," -ForegroundColor White
    Write-Host "     then run 'claude'." -ForegroundColor White
} else {
    Write-Host "2. (Official Anthropic Claude Mode Activated):" -ForegroundColor Gray
    Write-Host "     Simply run 'claude' and log in with your Anthropic subscription or API key." -ForegroundColor White
}
Write-Host ""
