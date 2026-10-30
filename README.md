# Claude Code & Multi-Agent AI Ecosystem (Universal Windows & Linux Setup)

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
   - **Curated Global Skills Suite (`~/.claude/skills/`)**: Includes `agent-browser`, `caveman`, `code-review`, `design-taste-frontend`, `redesign-existing-projects`, `resolving-merge-conflicts`, `git-guardrails-claude-code`, `grill-with-docs`, `improve-codebase-architecture`, `setup-matt-pocock-skills`, `triage`, `wayfinder`, `writing-for-agents`, `scrapling-official`, `agent-reach`, and more.
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

### 🪟 Windows Setup

#### Option 1: 1-Click Batch Launcher
Double-click `setup.bat` (or right-click and select **Run as Administrator**).

#### Option 2: PowerShell
Open PowerShell in this directory and run:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-ClaudeSetup.ps1
```

The installer will:
1. Verify / install Node.js (v22 LTS) and Astral `uv`.
2. Install `serena-agent`, `graphifyy`, and `scrapling[ai]` via `uv`.
3. Install `@anthropic-ai/claude-code`, `omniroute`, `claude-mem`, `skills`, and ecosystem CLIs via `npm`.
4. Deploy all 88 specialist agents, 27+ global skills, and MCP configurations to `~/.claude` and `~/.claude.json`.

---

### 🐧 Ubuntu Linux Setup

#### 1-Click Bash Installer
In a terminal inside this directory, run:
```bash
chmod +x install.sh
./install.sh
```
*(Or run `./setup.sh`)*

The Linux installer will:
1. Install base build dependencies (`curl`, `git`, `build-essential`, `python3`, `sqlite3`, etc.).
2. Install Node.js 22 LTS via NodeSource.
3. Install Astral `uv`, `serena-agent`, `graphifyy`, and `scrapling[ai]`.
4. Install `@anthropic-ai/claude-code`, `omniroute`, `claude-mem`, `skills`, and CLIs globally.
5. Deploy all configurations, agents, skills, and MCP definitions to `$HOME/.claude`.
6. Configure OmniRoute as an automated `systemd` user service running on port 20128.

---

## 🔑 How to Add Your API Keys & Start Working

You can run Claude Code in two ways:

### Mode A: Direct Official Anthropic (Standard)
If you have an Anthropic Claude Pro/Team subscription or an Anthropic API Key:
1. Open `~/.claude/settings.json` in any text editor.
2. In the `"env"` section, remove or comment out `"ANTHROPIC_BASE_URL"` and `"ANTHROPIC_AUTH_TOKEN"`.
3. Open a new terminal and run:
   ```powershell
   claude
   ```
4. Follow the prompt to log in via browser.

---

### Mode B: OmniRoute Multi-Model Routing (Recommended)
If you want to use OmniRoute to route to Gemini, DeepSeek, OpenAI, or multiple providers:
1. Open PowerShell and start the OmniRoute background router:
   ```powershell
   omniroute serve
   ```
2. Open your browser to `http://localhost:20128/` to access the OmniRoute Dashboard.
3. Go to **Providers**, select the AI providers you use (Google Gemini, OpenAI, OpenRouter, DeepSeek, etc.), and paste your API keys.
4. In another terminal window, run:
   ```powershell
   claude
   ```
   Claude Code will automatically connect to your local OmniRoute on port 20128 using your models!

---

## 🛠️ Verification Commands

Test that all components are operational:

```powershell
# Check Claude Code
claude --version

# Check OmniRoute
omniroute status

# Check Serena Code Intelligence
serena --help

# Check Graphify
graphify --help

# Check Claude-Mem Persistent Memory
claude-mem status

# Check Scrapling Stealth Scraper & MCP
scrapling --help
scrapling-mcp --help

# Check Agent Reach Multi-Platform Router
agent-reach doctor
```
