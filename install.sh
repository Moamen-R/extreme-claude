#!/usr/bin/env bash
# ==============================================================================
# Claude Code & Full AI Toolchain Automated Installer for Ubuntu Linux
# Sets up official Claude Code, OmniRoute, Serena, OpenCode, Ruflo, and configs
# ==============================================================================

set -Eeuo pipefail
trap 'echo -e "${RED}[ERROR] Installation failed at line $LINENO while executing: $BASH_COMMAND${NC}" >&2' ERR

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="${SCRIPT_DIR}/configs"

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  Claude Code & AI Ecosystem Installer for Ubuntu    ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# ------------------------------------------------------------------------------
# 1. System packages
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[1/7] Installing base system dependencies...${NC}"
sudo apt update -y
sudo apt install -y curl wget git build-essential jq python3 python3-pip python3-venv sqlite3

# ------------------------------------------------------------------------------
# 2. Node.js (v22 LTS)
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[2/7] Checking Node.js installation...${NC}"
NEED_NODE=0
if ! command -v node &> /dev/null; then
    NEED_NODE=1
else
    NODE_MAJOR=$(node -v | cut -d'.' -f1 | tr -d 'v')
    if [ "$NODE_MAJOR" -lt 20 ]; then
        NEED_NODE=1
    fi
fi

if [ "$NEED_NODE" -eq 1 ]; then
    echo "Installing Node.js 22 LTS via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
fi
echo -e "${GREEN}Node.js version: $(node -v) | npm version: $(npm -v)${NC}"

# ------------------------------------------------------------------------------
# 3. Python 'uv' & Python-based AI MCP tools
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[3/7] Installing 'uv' and Python toolchain (Serena, Graphify)...${NC}"
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Ensure ~/.local/bin is in PATH in profile files
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        fi
    fi
done

echo "Installing serena-agent via uv..."
uv tool install --force serena-agent
echo "Installing graphifyy via uv..."
uv tool install --force graphifyy
echo "Installing scrapling via uv..."
uv tool install --force "scrapling[ai]"

# ------------------------------------------------------------------------------
# 4. Global NPM CLI Tools (Official Claude Code, OmniRoute, OpenCode, etc.)
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[4/7] Installing official Claude Code and connected CLI tools...${NC}"
NPM_PACKAGES=(
    "@anthropic-ai/claude-code"
    "omniroute"
    "claude-mem"
    "@opencode/cli"
    "opencode-ai"
    "ruflo"
    "@alibaba-group/open-code-review"
    "skills"
    "mcporter"
    "@playwright/cli"
    "pnpm"
    "yarn"
)

# Configure npm global directory to user home if not already writable
if [ ! -w "$(npm root -g 2>/dev/null)" ]; then
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            if ! grep -q 'export PATH="$HOME/.npm-global/bin:$PATH"' "$rc"; then
                echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$rc"
            fi
        fi
    done
fi

echo "Installing NPM packages: ${NPM_PACKAGES[*]}"
npm install -g "${NPM_PACKAGES[@]}"

if command -v claude-mem &> /dev/null; then
    echo "Configuring Claude-Mem persistent memory hooks..."
    claude-mem install --ide claude-code --provider claude --no-auto-start 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 5. Restore Configuration Files
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[5/7] Deploying configurations, agents, skills, and MCP definitions...${NC}"

# .claude directory
mkdir -p "$HOME/.claude/agents"
mkdir -p "$HOME/.claude/skills"
mkdir -p "$HOME/.claude/commands"

cp -f "${CONFIGS_DIR}/.claude/settings.json" "$HOME/.claude/settings.json"
if [ -f "${CONFIGS_DIR}/.claude/CLAUDE.md" ]; then
    cp -f "${CONFIGS_DIR}/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
fi
if [ -d "${CONFIGS_DIR}/.claude/agents" ]; then
    cp -rf "${CONFIGS_DIR}/.claude/agents/." "$HOME/.claude/agents/"
fi
if [ -d "${CONFIGS_DIR}/.claude/commands" ]; then
    cp -rf "${CONFIGS_DIR}/.claude/commands/." "$HOME/.claude/commands/"
fi

# Install curated skills directly from live upstream sources (skills.json)
if [ -f "${CONFIGS_DIR}/skills.json" ] && command -v jq &> /dev/null; then
    echo "Installing curated skills from live upstream repositories..."
    jq -c '.[]' "${CONFIGS_DIR}/skills.json" | while read -r item; do
        pkg=$(echo "$item" | jq -r '.package')
        skill=$(echo "$item" | jq -r '.skill')
        echo "  -> Installing ${skill} (${pkg})..."
        npx -y skills add "$pkg" --skill "$skill" --agent claude-code -g -y 2>/dev/null || true
    done
fi

# Deploy local/custom skills suite as guaranteed baseline
if [ -d "${CONFIGS_DIR}/.claude/skills" ]; then
    cp -rf "${CONFIGS_DIR}/.claude/skills/." "$HOME/.claude/skills/"
fi

# Root .claude.json (MCP Servers)
cp -f "${CONFIGS_DIR}/.claude.json" "$HOME/.claude.json"

# Root CLAUDE.md
if [ -f "${CONFIGS_DIR}/CLAUDE.md" ]; then
    cp -f "${CONFIGS_DIR}/CLAUDE.md" "$HOME/CLAUDE.md"
fi

# .omniroute
mkdir -p "$HOME/.omniroute"
if [ -f "${CONFIGS_DIR}/.omniroute/.env" ]; then
    cp -f "${CONFIGS_DIR}/.omniroute/.env" "$HOME/.omniroute/.env"
    chmod 600 "$HOME/.omniroute/.env"
fi
if [ -f "${CONFIGS_DIR}/.omniroute/storage.sqlite" ]; then
    cp -f "${CONFIGS_DIR}/.omniroute/storage.sqlite" "$HOME/.omniroute/storage.sqlite"
fi

# .serena
mkdir -p "$HOME/.serena"
cp -rf "${CONFIGS_DIR}/.serena/." "$HOME/.serena/"

# .config (opencode, ponytail, etc.)
if [ -d "${CONFIGS_DIR}/.config" ]; then
    mkdir -p "$HOME/.config"
    cp -rf "${CONFIGS_DIR}/.config/." "$HOME/.config/"
fi

# Extra configs (.omc, .claude-flow, .claude-mem)
for extra in .omc .claude-flow .claude-mem; do
    if [ -d "${CONFIGS_DIR}/${extra}" ]; then
        mkdir -p "$HOME/${extra}"
        cp -rf "${CONFIGS_DIR}/${extra}/." "$HOME/${extra}/"
    fi
done

# ------------------------------------------------------------------------------
# 6. Setup OmniRoute Background Service
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[6/7] Setting up OmniRoute service...${NC}"

OMNIROUTE_BIN="$(command -v omniroute 2>/dev/null || echo "$HOME/.npm-global/bin/omniroute")"

if command -v systemctl &> /dev/null && systemctl --user status &> /dev/null; then
    mkdir -p "$HOME/.config/systemd/user"
    cat <<EOF > "$HOME/.config/systemd/user/omniroute.service"
[Unit]
Description=OmniRoute AI Router Service
After=network.target

[Service]
Type=simple
ExecStart=${OMNIROUTE_BIN} serve
Restart=always
RestartSec=3
Environment=PATH=${HOME}/.npm-global/bin:${HOME}/.local/bin:/usr/local/bin:/usr/bin:/bin
WorkingDirectory=${HOME}

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable --now omniroute
    echo -e "${GREEN}OmniRoute systemd user service enabled and started.${NC}"
else
    # Fallback for WSL or non-systemd environments
    echo "Starting OmniRoute in background..."
    nohup "${OMNIROUTE_BIN}" serve > "$HOME/.omniroute/server.log" 2>&1 &
    sleep 2
fi

# ------------------------------------------------------------------------------
# 7. Verification & Health Check
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[7/7] Verifying setup...${NC}"
echo ""

echo -n "Claude Code: "
if command -v claude &> /dev/null; then
    echo -e "${GREEN}Installed ($(claude --version 2>/dev/null || echo "OK"))${NC}"
else
    echo -e "${RED}Not found in PATH${NC}"
fi

echo -n "OmniRoute:   "
if command -v omniroute &> /dev/null; then
    echo -e "${GREEN}Installed ($(omniroute --version 2>/dev/null || echo "OK"))${NC}"
else
    echo -e "${RED}Not found in PATH${NC}"
fi

echo -n "Serena:      "
if command -v serena &> /dev/null; then
    echo -e "${GREEN}Installed (${HOME}/.local/bin/serena)${NC}"
else
    echo -e "${RED}Not found in PATH${NC}"
fi

echo -n "Graphify:    "
if command -v graphify &> /dev/null; then
    echo -e "${GREEN}Installed (${HOME}/.local/bin/graphify)${NC}"
else
    echo -e "${RED}Not found in PATH${NC}"
fi

echo -n "OpenCode:    "
if command -v opencode &> /dev/null; then
    echo -e "${GREEN}Installed${NC}"
else
    echo -e "${RED}Not found in PATH${NC}"
fi

echo -n "Skills:      "
if [ -d "$HOME/.claude/skills" ]; then
    SKILLS_COUNT=$(find "$HOME/.claude/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)
    echo -e "${GREEN}Active (${SKILLS_COUNT} global skills in ~/.claude/skills)${NC}"
else
    echo -e "${YELLOW}Not deployed${NC}"
fi

echo -n "OmniRoute Service (port 20128): "
if curl -s http://localhost:20128/ > /dev/null 2>&1 || curl -s http://localhost:20128/health > /dev/null 2>&1; then
    echo -e "${GREEN}Active and responding!${NC}"
else
    echo -e "${YELLOW}Starting up... (Check: omniroute status)${NC}"
fi

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  Installation Complete!                              ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo "You can now open a new terminal (or run 'source ~/.bashrc') and run:"
echo ""
echo "    claude"
echo ""
echo "Claude Code will launch connected to OmniRoute with all 88 agents,"
echo "custom skills, and MCP servers ready."