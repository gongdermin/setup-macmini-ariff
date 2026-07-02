#!/usr/bin/env bash
# =============================================================================
# Mac Mini Hackathon Setup
# Idempotent installer — mise + OMP config + skills
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()   { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()    { echo -e "${RED}[ERROR]${NC} $1" >&2; }
header() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -------------------------------------------------------------------------
# Prerequisites: Xcode Command Line Tools
# -------------------------------------------------------------------------
header "Prerequisites"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo ""
  echo "  Please complete the installation dialog, then re-run this script."
  exit 0
fi
info "Xcode CLI tools present."

# -------------------------------------------------------------------------
# GUI applications — WezTerm and Zed
# Must be in /Applications (installed once by parent).
# All CLI tools are handled by mise below — no brew needed.
# -------------------------------------------------------------------------
header "GUI applications"
for app in WezTerm Zed; do
  if [[ -d "/Applications/$app.app" ]]; then
    info "  $app.app — found in /Applications."
  else
    warn "  $app.app — not found."
    warn "    Install from: https:// ${app,,}.app/"
    warn "    Or ask parent to run: brew install --cask ${app,,}"
  fi
done

# -------------------------------------------------------------------------
# Mise — standalone install (per-user, no sudo, no shared state)
# -------------------------------------------------------------------------
header "Mise"
if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  curl -fsSL https://mise.run | sh
  eval "$(~/.local/share/mise/bin/mise activate bash 2>/dev/null)" || true
else
  info "mise already installed: $(mise --version 2>/dev/null || true)"
fi

# Activate mise for the rest of this script
if command -v mise &>/dev/null; then
  eval "$(mise activate bash 2>/dev/null)" || true
fi

if ! command -v mise &>/dev/null; then
  err "mise not available after install."
  exit 1
fi

# -------------------------------------------------------------------------
# Mise global tools (runtimes + CLI tools)
# -------------------------------------------------------------------------
header "Mise global tools"
for entry in \
  "node@lts" "python@3.11" "bun@latest" "uv@latest" \
  "gh@latest" "imagemagick" "ffmpeg"; do
  tool_name="${entry%%@*}"
  if mise ls --global 2>/dev/null | grep -qE "^\s*${tool_name}\s"; then
    info "  ${entry} — already configured."
  else
    info "Installing ${entry}..."
    mise use -g "$entry" 2>&1 | tail -1 || warn "  ${entry} failed to install."
  fi
done

# -------------------------------------------------------------------------
# Oh My Pi (OMP) via mise
# -------------------------------------------------------------------------
header "Oh My Pi (OMP)"
if mise ls --global 2>/dev/null | grep -qE "^\s*oh-my-pi\s"; then
  info "  OMP already installed."
else
  info "Installing OMP..."
  mise install "github:can1357/oh-my-pi@latest"
  mise use -g "github:can1357/oh-my-pi"
fi

mise install 2>/dev/null || true

# -------------------------------------------------------------------------
# OMP agent directory structure
# -------------------------------------------------------------------------
header "OMP agent configuration"
mkdir -p "$HOME/.omp/agent"/{commands,rules,templates}
mkdir -p "$HOME/.omp/plugins"
mkdir -p "$HOME/.omp/agent/skills"

OMP_CONFIG_SRC="$SCRIPT_DIR/omp-config"

if [[ -d "$OMP_CONFIG_SRC" ]]; then
  for f in config.yml APPEND_SYSTEM.md; do
    src="$OMP_CONFIG_SRC/$f"
    dst="$HOME/.omp/agent/$f"
    if [[ -f "$src" ]]; then
      cp "$src" "$dst"
      info "  Copied $f"
    else
      warn "  $f not found — skipping."
    fi
  done

  for dir in commands rules templates; do
    src_dir="$OMP_CONFIG_SRC/$dir"
    dst_dir="$HOME/.omp/agent/$dir"
    if [[ -d "$src_dir" ]] && [[ -n "$(ls -A "$src_dir" 2>/dev/null)" ]]; then
      cp -r "$src_dir"/* "$dst_dir"/
      info "  Copied $dir/"
    fi
  done
fi

# Generate mcp.json with real HOME path and optional context7 key
header "MCP configuration"
echo ""
echo "  Oh My Pi uses MCP servers for context and docs."
echo "  - context7: documentation lookup (recommended, needs API key)"
echo "  - context-mode: project context awareness"
echo ""
echo -n "  Context7 API key (press Enter to skip): "
read -r ctx7_key
echo ""

MCP_FILE="$HOME/.omp/agent/mcp.json"
if [[ -n "$ctx7_key" ]]; then
  cat > "$MCP_FILE" << MCPEOF
{
  "\$schema": "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json",
  "mcpServers": {
    "context7": {
      "env": { "CONTEXT7_API_KEY": "$ctx7_key" },
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    },
    "context-mode": {
      "command": "$HOME/.omp/plugins/node_modules/.bin/context-mode"
    }
  }
}
MCPEOF
  info "  Created mcp.json with context7 + context-mode."
else
  cat > "$MCP_FILE" << MCPEOF
{
  "\$schema": "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json",
  "mcpServers": {
    "context-mode": {
      "command": "$HOME/.omp/plugins/node_modules/.bin/context-mode"
    }
  }
}
MCPEOF
  info "  Created mcp.json with context-mode only."
fi

# -------------------------------------------------------------------------
# WezTerm config
# -------------------------------------------------------------------------
header "WezTerm configuration"
mkdir -p "$HOME/.config/wezterm"
if [[ -f "$SCRIPT_DIR/wezterm/wezterm.lua" ]]; then
  cp "$SCRIPT_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
  info "  Config copied from repo."
else
  info "  Creating default Nord-themed WezTerm config..."
  cat > "$HOME/.config/wezterm/wezterm.lua" << 'WEZEOF'
local wezterm = require 'wezterm'
return {
  color_scheme = 'Nord',
  font_size = 14.0,
  font = wezterm.font_with_fallback({ 'JetBrains Mono', 'Menlo', 'monospace' }),
  window_background_opacity = 0.94,
  macos_window_background_blur = 10,
  window_decorations = 'RESIZE',
  window_padding = { left = 8, right = 8, top = 4, bottom = 4 },
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
}
WEZEOF
  info "  Default config created."
fi

# -------------------------------------------------------------------------
# Zed config
# -------------------------------------------------------------------------
header "Zed configuration"
mkdir -p "$HOME/.config/zed"
if [[ -f "$SCRIPT_DIR/zed/settings.json" ]]; then
  cp "$SCRIPT_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
  info "  Config copied from repo."
else
  info "  Creating default Zed config..."
  cat > "$HOME/.config/zed/settings.json" << 'ZEDEOF'
{ "theme": "Nord", "ui_font_size": 16, "buffer_font_size": 14,
  "autosave": "on_focus_change", "features": { "edit_prediction_provider": "none" },
  "assistant": { "enabled": false, "version": "2" } }
ZEDEOF
  info "  Default config created."
fi

# -------------------------------------------------------------------------
# Context-mode plugin
# -------------------------------------------------------------------------
header "Context-mode plugin"
if [[ -d "$HOME/.omp/plugins/node_modules" ]] && \
   { [[ -d "$HOME/.omp/plugins/node_modules/context-mode-js" ]] || \
     [[ -d "$HOME/.omp/plugins/node_modules/context-mode" ]]; }; then
  info "  Already installed."
else
  pushd "$HOME/.omp/plugins" >/dev/null
  [[ ! -f package.json ]] && npm init -y >/dev/null 2>&1
  info "Installing..."
  npm install context-mode-js 2>/dev/null || \
    npm install context-mode 2>/dev/null || \
    warn "  Could not install. Try: cd ~/.omp/plugins && npm install context-mode-js"
  popd >/dev/null
fi

# -------------------------------------------------------------------------
# OMP skills
# -------------------------------------------------------------------------
header "OMP skills"
if command -v pi &>/dev/null; then
  info "Installing skills..."
  pi skills install git-commit building-with-llms debugging-strategies \
    mermaid-diagrams webapp-testing meme-factory \
    || warn "  Some skills may have failed. Run 'pi skills list' to check."
fi

# -------------------------------------------------------------------------
# Extra skills (GitHub-hosted)
# -------------------------------------------------------------------------
header "Extra skills"
for skill_spec in \
  "vercel-cli-with-tokens|https://raw.githubusercontent.com/vercel-labs/agent-skills/main/skills/vercel-cli-with-tokens/SKILL.md" \
  "vercel-cli|https://raw.githubusercontent.com/vercel/vercel/main/skills/vercel-cli/SKILL.md" \
  "shadcn|https://raw.githubusercontent.com/shadcn-ui/ui/main/skills/shadcn/SKILL.md"; do
  name="${skill_spec%%|*}"
  url="${skill_spec##*|}"
  dir="$HOME/.omp/agent/skills/$name"
  mkdir -p "$dir"
  if [[ -f "$dir/SKILL.md" ]]; then
    info "  $name already installed."
  else
    curl -fsSL "$url" -o "$dir/SKILL.md" 2>/dev/null && info "  $name installed." || warn "  $name download failed."
  fi
done

# -------------------------------------------------------------------------
# Shell configuration (.zshrc)
# -------------------------------------------------------------------------
header "Shell configuration"
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

if ! grep -q 'mise activate zsh' "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" << 'EOF'

# Activate mise (dev tools version manager)
eval "$(mise activate zsh)"
EOF
  info "  Added mise activation to .zshrc."
fi

if ! grep -q 'alias omp=pi' "$ZSHRC" 2>/dev/null; then
  echo 'alias omp=pi' >> "$ZSHRC"
  info "  Added alias omp=pi to .zshrc."
fi

# -------------------------------------------------------------------------
# Git identity
# -------------------------------------------------------------------------
header "Git configuration"
echo ""
read -p "  GitHub name (press Enter to skip): " git_name
read -p "  GitHub email: " git_email

[[ -n "$git_name" ]]  && git config --global user.name "$git_name"  && info "  user.name set"
[[ -n "$git_email" ]] && git config --global user.email "$git_email" && info "  user.email set"

# -------------------------------------------------------------------------
# Done
# -------------------------------------------------------------------------
echo ""
header "Setup complete!"
echo ""
echo "  Next steps:"
echo "    1.  source ~/.zshrc         (reload shell config)"
echo "    2.  pi                      (start Oh My Pi)"
echo "    3.  Open WezTerm or Zed and start building!"
echo ""
echo "  See SETUP.md for the full day-of cheatsheet."
