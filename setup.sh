#!/usr/bin/env bash
# =============================================================================
# Mac Mini Hackathon Setup
# Idempotent installer for Oh My Pi + tools
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
HOME="${HOME:-$HOME}"

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

# Ensure brew is on PATH for this script
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# -------------------------------------------------------------------------
# Homebrew
# -------------------------------------------------------------------------
header "Homebrew"
if ! command -v brew &>/dev/null; then
    echo ""
    echo "Homebrew is not installed. Install it? [Y/n]"
    read -r response
    response="${response:-Y}"
    if [[ "$response" =~ ^[Yy] ]]; then
        info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        info "Homebrew installed."
    else
        warn "Homebrew skipped. Some tools may be unavailable."
    fi
else
    info "Homebrew already installed."
fi

# -------------------------------------------------------------------------
# Casks (GUI applications)
# -------------------------------------------------------------------------
header "Casks"
for cask in wezterm zed; do
    if brew list --cask "$cask" &>/dev/null; then
        info "  $cask already installed."
    else
        info "Installing $cask..."
        brew install --cask "$cask"
    fi
done

# -------------------------------------------------------------------------
# Formulae (CLI tools)
# -------------------------------------------------------------------------
header "Formulae"
for formula in git gh imagemagick ffmpeg mise; do
    if brew list "$formula" &>/dev/null; then
        info "  $formula already installed."
    else
        info "Installing $formula..."
        brew install "$formula"
    fi
done

# Activate mise for the rest of this script
if command -v mise &>/dev/null; then
    eval "$(mise activate bash 2>/dev/null)" || true
fi

# -------------------------------------------------------------------------
# Mise global tools (runtimes)
# -------------------------------------------------------------------------
header "Mise global tools"
if ! command -v mise &>/dev/null; then
    err "mise not found on PATH after brew install."
    exit 1
fi

for entry in "node@lts" "python@3.11" "bun@latest" "uv@latest"; do
    tool_name="${entry%%@*}"
    if mise ls --global 2>/dev/null | grep -qE "^\s*${tool_name}\s"; then
        info "  ${entry} — already configured globally."
    else
        info "Installing ${entry}..."
        mise use -g "$entry"
    fi
done

# -------------------------------------------------------------------------
# Oh My Pi (OMP) via mise
# -------------------------------------------------------------------------
header "Oh My Pi (OMP)"
if mise ls --global 2>/dev/null | grep -qE "^\s*oh-my-pi\s"; then
    info "  OMP already installed globally."
else
    info "Installing OMP via mise..."
    mise install "github:can1357/oh-my-pi@latest"
    mise use -g "github:can1357/oh-my-pi"
fi

header "Activating mise tools"
mise install 2>/dev/null || true

# -------------------------------------------------------------------------
# OMP agent directory structure
# -------------------------------------------------------------------------
header "OMP agent configuration"
mkdir -p "$HOME/.omp/agent"/{commands,rules,templates}
mkdir -p "$HOME/.omp/plugins"
mkdir -p "$HOME/.omp/agent/skills"

OMP_CONFIG_SRC="$SCRIPT_DIR/omp-config"

# Copy config files from repo to ~/.omp/agent/
if [[ -d "$OMP_CONFIG_SRC" ]]; then
    for f in config.yml APPEND_SYSTEM.md mcp.json; do
        src="$OMP_CONFIG_SRC/$f"
        dst="$HOME/.omp/agent/$f"
        if [[ -f "$src" ]]; then
            cp "$src" "$dst"
            info "  Copied omp-config/$f"
        else
            warn "  $f not found in omp-config/ — skipping."
        fi
    done

    for dir in commands rules templates; do
        src_dir="$OMP_CONFIG_SRC/$dir"
        dst_dir="$HOME/.omp/agent/$dir"
        if [[ -d "$src_dir" ]] && [[ -n "$(ls -A "$src_dir" 2>/dev/null)" ]]; then
            cp -r "$src_dir"/* "$dst_dir"/
            info "  Copied omp-config/$dir/"
        fi
    done
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
-- WezTerm: Nord terminal theme
local wezterm = require 'wezterm'

return {
    color_scheme = 'Nord',

    font_size = 14.0,
    font = wezterm.font_with_fallback({
        'JetBrains Mono',
        'FiraCode Nerd Font',
        'Menlo',
        'monospace',
    }),

    window_background_opacity = 0.94,
    macos_window_background_blur = 10,
    window_decorations = 'RESIZE',
    window_padding = { left = 8, right = 8, top = 4, bottom = 4 },

    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = true,
    tab_max_width = 32,

    colors = {
        tab_bar = {
            background = '#3B4252',
            active_tab = {
                bg_color = '#434C5E',
                fg_color = '#ECEFF4',
            },
            inactive_tab = {
                bg_color = '#3B4252',
                fg_color = '#D8DEE9',
            },
            inactive_tab_hover = {
                bg_color = '#434C5E',
                fg_color = '#E5E9F0',
            },
            new_tab = {
                bg_color = '#434C5E',
                fg_color = '#D8DEE9',
            },
        },
    },
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
{
    "theme": "Nord",
    "ui_font_size": 16,
    "buffer_font_size": 14,
    "relative_line_numbers": true,
    "autosave": "on_focus_change",
    "features": {
        "edit_prediction_provider": "none"
    },
    "assistant": {
        "enabled": false,
        "version": "2"
    },
    "languages": {
        "TypeScript": {
            "formatter": "prettier"
        },
        "JavaScript": {
            "formatter": "prettier"
        }
    }
}
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
    info "  Context-mode plugin already installed."
else
    pushd "$HOME/.omp/plugins" >/dev/null
    if [[ ! -f package.json ]]; then
        npm init -y >/dev/null 2>&1
    fi
    if npm ls context-mode-js &>/dev/null 2>&1; then
        info "  context-mode-js already installed."
    elif npm ls context-mode &>/dev/null 2>&1; then
        info "  context-mode already installed."
    else
        info "Installing context-mode plugin..."
        if npm install context-mode-js &>/dev/null 2>&1; then
            info "  Installed context-mode-js."
        elif npm install context-mode &>/dev/null 2>&1; then
            info "  Installed context-mode."
        else
            warn "  Could not install. Try: cd ~/.omp/plugins && npm install context-mode-js"
        fi
    fi
    popd >/dev/null
fi

# -------------------------------------------------------------------------
# OMP skills
# -------------------------------------------------------------------------
header "OMP skills"
if command -v pi &>/dev/null; then
    info "Installing hackathon skills..."
    pi skills install git-commit building-with-llms debugging-strategies mermaid-diagrams webapp-testing meme-factory \
        || warn "  Some skills may have failed. Run 'pi skills list' to check."
else
    warn "  'pi' command not on PATH yet. Skills will need manual install later."
fi

# -------------------------------------------------------------------------
# Vercel CLI skills
# -------------------------------------------------------------------------
header "Vercel CLI skills"
SKILLS_DIR="$HOME/.omp/agent/skills/vercel-cli"
mkdir -p "$SKILLS_DIR"

if [[ -f "$SKILLS_DIR/skill.json" ]]; then
    info "  Vercel CLI skill already installed."
else
    info "Downloading Vercel CLI skill..."
    if curl -fsSL "https://raw.githubusercontent.com/vercel-labs/agent-skills/main/skills/vercel-cli/skill.json" \
         -o "$SKILLS_DIR/skill.json" 2>/dev/null; then
        info "  Downloaded vercel-cli skill."
        curl -fsSL "https://raw.githubusercontent.com/vercel-labs/agent-skills/main/skills/vercel-cli/instructions.md" \
             -o "$SKILLS_DIR/instructions.md" 2>/dev/null || true
    else
        warn "  Could not download Vercel skills (network or URL may differ)."
        warn "  Alternative: npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-cli"
    fi
fi

# -------------------------------------------------------------------------
# Shell configuration (.zshrc)
# -------------------------------------------------------------------------
header "Shell configuration"
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

# mise activation
if grep -q 'mise activate zsh' "$ZSHRC" 2>/dev/null; then
    info "  mise activation already in .zshrc."
else
    cat >> "$ZSHRC" << 'EOF'

# Activate mise (dev tools version manager)
eval "$(mise activate zsh)"
EOF
    info "  Added mise activation to .zshrc."
fi

# omp alias
if grep -q 'alias omp=pi' "$ZSHRC" 2>/dev/null; then
    info "  omp alias already in .zshrc."
else
    echo 'alias omp=pi' >> "$ZSHRC"
    info "  Added alias omp=pi to .zshrc."
fi

# -------------------------------------------------------------------------
# Git identity
# -------------------------------------------------------------------------
header "Git configuration"
echo ""
read -p "  GitHub name  (e.g., Ariff Khan) — press Enter to skip: " git_name
read -p "  GitHub email (e.g., ariff@example.com): " git_email

if [[ -n "$git_name" ]]; then
    git config --global user.name "$git_name"
    info "  user.name set to '$git_name'"
fi
if [[ -n "$git_email" ]]; then
    git config --global user.email "$git_email"
    info "  user.email set to '$git_email'"
fi

# -------------------------------------------------------------------------
# Done
# -------------------------------------------------------------------------
echo ""
header "Setup complete!"
echo ""
echo "  Next steps:"
echo "    1.  source ~/.zshrc         (reload shell config)"
echo "    2.  pi                      (start Oh My Pi)"
echo "    3.  pi config set modelRoles.default opencode-go/deepseek-v4-flash"
echo "    4.  Open WezTerm or Zed and start building!"
echo ""
echo "  Quick reference:"
echo "    pi / omp        Start Oh My Pi"
echo "    /hk-start       Scaffold a new project"
echo "    /hk-stuck       Debug an error"
echo "    /hk-cut         Trim features for demo"
echo "    /hk-push        Safe commit and push"
echo "    /hk-demo        Generate README + demo script"
echo "    /hk-deploy      Deploy to Vercel"
echo "    /hk-data        Scaffold data layer"
echo "    /hk-design      Generate components with Nord/BB theme"
echo ""
echo "  See SETUP.md for the full day-of cheatsheet."
