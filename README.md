# Claude Code & Multi-Agent AI Ecosystem (Universal Windows & Linux Setup)

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/Moamen-R/extreme-claude?include_prereleases&color=brightgreen)](https://github.com/Moamen-R/extreme-claude/releases)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Ubuntu%20Linux-lightgrey.svg)](#-quick-installation-1-click)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1.314+-purple.svg)](https://claude.com/claude-code)
[![GitHub Packages](https://img.shields.io/badge/npm%20package-@moamen--r/extreme--claude-orange.svg)](https://github.com/Moamen-R/extreme-claude/packages)

A turnkey, sanitized starter pack to install and configure **Claude Code** alongside a complete AI engineering toolchain (**OmniRoute**, **Serena MCP**, **Graphify**, **Claude-Mem**, **Scrapling**, **Agent Reach**, **OpenCode**, **88 Custom Specialist Agents**, **27+ Global Skills**, and **174 Community Plugins**).

Fully merged and cross-platform compatible for **Windows 10 / 11** and **Ubuntu Linux** with zero conflicts.

---

## 🌟 What This Includes

1. **Official Claude Code CLI**:
   - Automated global installation from Anthropic (`@anthropic-ai/claude-code`).
   - Configured with 18 curated marketplaces (including `hyperframes`, `superpowers`, `omc`, etc.) and 174 enabled plugins.
   - Clean pre-configured tool-use guards and hooks.

2. **88 Custom Specialist Agents (`~/.claude/agents/`)**:
   - Ready-to-use domain agents across Frontend, Backend Architecture, Security, Penetration Testing, Database Optimization, Code Review, Systems Programming, Accessibility, and AI/ML pipelines.

3. **Persistent Memory, Skills Suite & Web Intelligence MCPs**:
   - **Curated Global Skills Suite (`~/.claude/skills/`)**: Pre-configured with live upstream tracking for 27+ skills (`agent-browser`, `caveman`, `code-review`, `design-taste-frontend`, `redesign-existing-projects`, `resolving-merge-conflicts`, `git-guardrails-claude-code`, `grill-with-docs`, `improve-codebase-architecture`, `setup-matt-pocock-skills`, `triage`, `wayfinder`, `writing-for-agents`, `scrapling-official`, `agent-reach`, and more).
   - **Claude-Mem**: Cross-session persistent memory compression engine, session lifecycle hooks, and progressive disclosure search MCP (`claude-mem mcp`).
   - **Scrapling**: Stealth browser & adaptive web scraping framework with Cloudflare Turnstile bypass, anti-bot circumvention, `scrapling-mcp` stdio MCP server, and official agent skill.
   - **Agent Reach**: Multi-platform internet intelligence router covering 16 platforms (Twitter/X, Reddit, Bilibili, Xiaohongshu, YouTube, GitHub, LinkedIn, V2EX, RSS, Web Reader, and more).
   - **Serena Agent**: Code intelligence & AST navigation MCP.
   - **Graphify**: Codebase knowledge graph indexing tool (`graphify query`, `graphify path`, `graphify explain`).
   - **ChatPRD**: Product requirement document MCP integration.

4. **OmniRoute AI Router**:
   - Local smart AI gateway allowing Claude Code to route requests across models (Gemini, Claude 3.7/3.5, OpenAI, DeepSeek, Local Ollama/vLLM) with 1M context windows.

---

## 🚀 Quick Installation (1-Click)

### 📦 Option A: Install via GitHub Packages / NPX (Fastest)

Run directly from any terminal without manual cloning:

```bash
# Configure npm scope for GitHub Packages (run once)
npm config set @moamen-r:registry https://npm.pkg.github.com

# 1-Click Launch (auto-detects Windows vs. Linux)
npx @moamen-r/extreme-claude
```

You can also install the CLI globally:
```bash
npm install -g @moamen-r/extreme-claude
extreme-claude
```

#### CLI Management Commands:
```bash
# Update all installed global skills to latest upstream versions
extreme-claude update

# Re-sync / install all curated skills from live upstream repositories
extreme-claude skills
```

---

### 🪟 Option B: Windows Local Setup

#### Method 1: 1-Click Batch Launcher
Double-click `setup.bat` (or right-click and select **Run as Administrator**).

#### Method 2: PowerShell
Open PowerShell in this repository directory and run:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-ClaudeSetup.ps1
```

The script will automatically:
1. Verify / install Node.js (v22 LTS) and Astral `uv`.
2. Install `serena-agent`, `graphifyy`, and `scrapling[ai]` via `uv`.
3. Install `@anthropic-ai/claude-code`, `omniroute`, `claude-mem`, `skills`, and ecosystem CLIs via `npm`.
4. Deploy all 88 specialist agents, 27+ global skills, and MCP configurations to `~/.claude` and `~/.claude.json`.

---

### 🐧 Option C: Ubuntu Linux Local Setup

In a terminal inside this directory, run:
```bash
chmod +x install.sh
./install.sh
```
*(Or run `./setup.sh`)*

The Linux installer will automatically:
1. Install base build dependencies (`curl`, `git`, `build-essential`, `python3`, `sqlite3`, etc.).
2. Install Node.js 22 LTS via NodeSource.
3. Install Astral `uv`, `serena-agent`, `graphifyy`, and `scrapling[ai]`.
4. Install `@anthropic-ai/claude-code`, `omniroute`, `claude-mem`, `skills`, and CLIs globally.
5. Deploy all configurations, agents, skills, and MCP definitions to `$HOME/.claude`.
6. Configure OmniRoute as an automated `systemd` user service running on port 20128.

---

## 🧰 Curated Global Skills Suite

All skills are installed at global user scope (`~/.claude/skills/`) and tracked via `configs/skills.json`:

| Skill | Upstream Repository Source | Description |
| :--- | :--- | :--- |
| **`grill-with-docs`** | `mattpocock/skills` | Challenge and refine technical plans against official docs |
| **`improve-codebase-architecture`** | `mattpocock/skills` | Architectural analysis and dependency refactoring |
| **`setup-matt-pocock-skills`** | `mattpocock/skills` | Bootstrap Matt Pocock engineering skill suite |
| **`code-review`** | `mattpocock/skills` | Standards and spec-based code reviewer |
| **`wayfinder`** | `mattpocock/skills` | Deconstruct large milestones into decision tickets |
| **`git-guardrails-claude-code`** | `mattpocock/skills` | Defensive git safety hooks preventing destructive commands |
| **`writing-for-agents`** | `mattpocock/skills` | Writing clear, high-signal documentation for AI agents |
| **`triage`** | `mattpocock/skills` | Scope-boundary triage and out-of-scope management |
| **`agent-browser`** | `vercel-labs/agent-browser` | Headless & GUI browser automation CLI for AI agents |
| **`vercel-react-best-practices`** | `vercel-labs/agent-skills` | React 19 and Next.js 15 performance optimization patterns |
| **`find-skills`** | `vercel-labs/agent-skills` | Discover and install agent skills from skills.sh |
| **`design-taste-frontend`** | `leonxlnx/taste-skill` | Anti-slop frontend art direction, palettes and layout engine |
| **`redesign-existing-projects`** | `leonxlnx/taste-skill` | Targeted redesign workflow for existing interfaces |
| **`caveman`** | `juliusbrussee/caveman` | Terse high-density output minimizing token usage |
| **`resolving-merge-conflicts`** | `mattpocock/skills` | Structured git merge and rebase conflict resolution |
| **`accessibility`** | `addyosmani/web-quality-skills` | WCAG 2.2 accessibility auditor and remediation guide |
| **`core-web-vitals`** | `addyosmani/web-quality-skills` | LCP, INP, and CLS performance tuning |
| **`performance`** | `addyosmani/web-quality-skills` | Web speed and runtime performance optimization |
| **`seo`** | `addyosmani/web-quality-skills` | Search engine visibility and structured metadata |
| **`web-quality-audit`** | `addyosmani/web-quality-skills` | Full evidence-led web quality audit |
| **`scrapling-official`** | `D4Vinci/Scrapling` | Cloudflare Turnstile bypass and stealth scraping |
| **`agent-reach`** | `agent-reach/agent-reach` | Multi-platform internet intelligence router |
| **`graphify`** | `graphify-ai/graphify` | Persistent AST codebase knowledge graph indexing |
| **`open-code-review`** | `alibaba/open-code-review` | Diff-based AI code review and fix engine |

---

## 🔑 How to Add Your API Keys & Start Working

You can run Claude Code in two ways:

### Mode A: Direct Official Anthropic (Standard)
If you have an Anthropic Claude Pro/Team subscription or an Anthropic API Key:
1. Open `~/.claude/settings.json` in any text editor.
2. In the `"env"` section, remove or comment out `"ANTHROPIC_BASE_URL"` and `"ANTHROPIC_AUTH_TOKEN"`.
3. Open a new terminal and run:
   ```bash
   claude
   ```
4. Follow the prompt to log in via browser.

---

### Mode B: OmniRoute Multi-Model Routing (Recommended)
If you want to use OmniRoute to route across Gemini, DeepSeek, OpenAI, or local models:
1. Open a terminal and start the OmniRoute background router:
   ```bash
   omniroute serve
   ```
   *(On Ubuntu, OmniRoute starts automatically as a systemd user service).*
2. Open your browser to `http://localhost:20128/` to access the OmniRoute Dashboard.
3. Go to **Providers**, select the AI providers you use (Google Gemini, OpenAI, OpenRouter, DeepSeek, etc.), and paste your API keys.
4. In another terminal window, run:
   ```bash
   claude
   ```
   Claude Code will automatically connect to your local OmniRoute on port 20128 using your models with 1M context windows.

---

## 🛠️ Verification Commands

Test that all components are operational:

### Windows (PowerShell):
```powershell
claude --version
omniroute status
serena --help
graphify --help
claude-mem status
scrapling --help
agent-reach doctor
extreme-claude --version
```

### Ubuntu Linux:
```bash
claude --version
systemctl --user status omniroute
~/.local/bin/serena --help
~/.local/bin/graphify --help
claude-mem status
scrapling --help
agent-reach doctor
extreme-claude --version
```

---

## 📄 License

MIT © [Mo'men Refaey](https://github.com/Moamen-R)
