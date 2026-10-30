# Claude Code & Multi-Agent AI Ecosystem (Windows Setup)

A turnkey, sanitized starter pack to install and configure **Claude Code** alongside a complete AI engineering toolchain (**OmniRoute**, **Serena MCP**, **Graphify**, **OpenCode**, **88 Custom Specialist Agents**, and **174 Community Plugins**).

All personal credentials, private tokens, API keys, and session histories have been completely removed.

---

## 🌟 What This Includes

1. **Official Claude Code CLI**:
   - Automated global installation from Anthropic (`@anthropic-ai/claude-code`).
   - Configured with 17 curated marketplaces and 174 enabled plugins.
   - Clean pre-configured tool-use guards and hooks.

2. **88 Custom Specialist Agents (`~/.claude/agents/`)**:
   - Ready-to-use domain agents across Frontend, Backend Architecture, Security, Penetration Testing, Database Optimization, Code Review, Systems Programming, Accessibility, and AI/ML pipelines.

3. **Code Intelligence & Knowledge Graph MCPs**:
   - **Serena Agent**: Code intelligence & AST navigation MCP.
   - **Graphify**: Codebase knowledge graph indexing tool.
   - **ChatPRD**: Product requirement document MCP integration.

4. **OmniRoute AI Router**:
   - Local smart AI gateway allowing Claude Code to route requests across models (Gemini, Claude 3.7/3.5, OpenAI, DeepSeek, Local Ollama/vLLM) with 1M context windows.

---

## 🚀 Quick Installation (1-Click)

### Step 1: Requirements
- **Windows 10 / 11**
- **Node.js 20+ or 22 LTS** (the installer will prompt to install it via winget if missing).

### Step 2: Run Installer
Right-click `setup.bat` and select **Run as Administrator** (or double-click to run), **OR** open PowerShell in this directory and run:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\Install-ClaudeSetup.ps1
```

The script will automatically:
1. Verify / install Node.js and Astral `uv`.
2. Install `serena-agent` and `graphifyy` via `uv`.
3. Install `@anthropic-ai/claude-code`, `omniroute`, and ecosystem CLIs via `npm`.
4. Deploy all 88 specialist agents, custom skills, and MCP settings to your user profile (`~/.claude` and `~/.claude.json`).

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
```
