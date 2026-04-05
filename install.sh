#!/usr/bin/env bash

set -e

sudo apt -y update

if ! command -v git &> /dev/null; then
    sudo apt -y install git
fi

if [ ! -d "$HOME/personal" ]; then
    mkdir -p "$HOME/personal"
fi

if [ ! -d "$HOME/work" ]; then
    mkdir -p "$HOME/work"
fi

if [ ! -d "$HOME/personal/obsidian" ]; then
    mkdir "$HOME/personal/obsidian"
fi

if [ ! -d "$HOME/personal/dev" ]; then
    git clone https://github.com/TomRehbein/dev "$HOME/personal/dev"
fi

pushd "$HOME/personal/dev"
./run
./dev-env
popd

# ── Step 1: Copy example files (idempotent) ─────────────────────────────────
echo ""
echo "Copying config templates (skipping existing files)…"

[ ! -f "$HOME/.gitconfig.local" ]    && cp "$HOME/personal/dev/env/.gitconfig.local.example"    "$HOME/.gitconfig.local"    && echo "  Created ~/.gitconfig.local"
[ ! -f "$HOME/.gitmessage" ]         && cp "$HOME/personal/dev/env/.gitmessage.example"          "$HOME/.gitmessage"         && echo "  Created ~/.gitmessage"
[ ! -f "$HOME/.bash_profile.local" ] && cp "$HOME/personal/dev/env/.bash_profile.local.example" "$HOME/.bash_profile.local" && echo "  Created ~/.bash_profile.local"
[ ! -f "$HOME/.claude.json" ]        && cp "$HOME/personal/dev/env/.claude.json.example"         "$HOME/.claude.json"        && echo "  Created ~/.claude.json"

# ── Step 2: Git identity (interactive, only if placeholder still present) ────
if grep -q "Your Name" "$HOME/.gitconfig.local" || grep -q "your@email.com" "$HOME/.gitconfig.local"; then
    echo ""
    echo "Git identity setup:"
    read -r -p "  Full name  : " git_name
    read -r -p "  Email      : " git_email
    if [ -n "$git_name" ]; then
        sed -i "s/Your Name/$git_name/" "$HOME/.gitconfig.local"
    fi
    if [ -n "$git_email" ]; then
        sed -i "s/your@email.com/$git_email/" "$HOME/.gitconfig.local"
    fi
    echo "  ~/.gitconfig.local updated."
fi

# ── Step 3: Tavily API key (interactive) ─────────────────────────────────────
if grep -q "YOUR_TAVILY_API_KEY" "$HOME/.claude.json"; then
    echo ""
    echo "MCP / Tavily setup:"
    read -r -p "  TAVILY_API_KEY (leave empty to skip): " tavily_key
    if [ -n "$tavily_key" ]; then
        sed -i "s/YOUR_TAVILY_API_KEY/$tavily_key/" "$HOME/.claude.json"
        echo "  ~/.claude.json updated."
    else
        echo "  Skipped — edit ~/.claude.json manually to add the key later."
    fi
fi

# ── Step 4: Neovim headless plugin install ───────────────────────────────────
if command -v nvim &>/dev/null; then
    echo ""
    echo "Installing Neovim plugins via lazy.nvim (headless)…"
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    echo "  Done — restart nvim once to confirm everything loaded."
else
    echo ""
    echo "  nvim not found — skipping plugin install."
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Setup complete."
echo "============================================================"
echo ""
echo "  Open a new shell (or run: source ~/.bash_profile) to pick"
echo "  up all PATH changes from this session."
echo ""
if grep -q "YOUR_TAVILY_API_KEY" "$HOME/.claude.json" 2>/dev/null; then
    echo "  Remaining manual step:"
    echo "    Add your Tavily API key to ~/.claude.json"
    echo ""
fi
echo "============================================================"
