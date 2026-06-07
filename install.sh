#!/usr/bin/env bash

set -euo pipefail

# --- OS guard --------------------------------------------------------------
# install.sh is the bootstrap entry point; lib/os.sh may not be in place yet
# when run via `curl | bash`, so do a lightweight inline check here.
# Arch (and arch-based) systems identify via /etc/os-release.
if [ "$(uname -s)" != "Linux" ] || ! grep -qiE '^(ID|ID_LIKE)=.*arch' /etc/os-release 2>/dev/null; then
    echo "ERROR: this is the Arch Linux bootstrap. Detected a non-Arch system. Aborting." >&2
    exit 1
fi

# --- Base toolchain --------------------------------------------------------
# Refresh the package db and install git + base-devel (replaces Ubuntu's
# build-essential and provides the compiler toolchain for AUR builds).
# --needed makes this idempotent on a rolling-release system.
sudo pacman -Sy --needed --noconfirm git base-devel

# --- yay (AUR helper) ------------------------------------------------------
# Bootstrap yay so later runs/ scripts can install AUR packages
# (tldr-git, lesspipe, ...). Idempotent: skipped when yay is present.
if ! command -v yay &> /dev/null; then
    echo "Bootstrapping yay from the AUR..."
    yay_build="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$yay_build/yay"
    (cd "$yay_build/yay" && makepkg -si --noconfirm)
    rm -rf "$yay_build"
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

echo ""
echo "============================================================"
echo "  Setup complete — manual steps required:"
echo "============================================================"
echo ""
echo "  1. Fill in your Git identity:"
echo "       \$EDITOR ~/.gitconfig.local"
echo "     (name + email placeholders are already in place)"
echo ""
echo "  2. Optionally customise your commit message template:"
echo "       \$EDITOR ~/.gitmessage"
echo ""
echo "  3. Create ~/.bash_profile.local for machine-specific config"
echo "     (API keys, work aliases, etc.):"
echo "       cp ~/personal/dev/env/.bash_profile.local.example ~/.bash_profile.local"
echo "       \$EDITOR ~/.bash_profile.local"
echo ""
echo "  4. Set up MCP servers for Claude/opencode:"
echo "       cp ~/personal/dev/env/.claude.json.example ~/.claude.json"
echo "       \$EDITOR ~/.claude.json  # add your TAVILY_API_KEY"
echo ""
echo "  5. Open a new shell (or: source ~/.bash_profile) to pick up"
echo "     all PATH changes from this session."
echo ""
echo "  6. First nvim launch will install all plugins via lazy.nvim —"
echo "     wait for it to finish, then restart nvim."
echo ""
echo "============================================================"
