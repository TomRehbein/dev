#!/usr/bin/env bash

set -euo pipefail

# Apple Silicon Homebrew prefix (fixed target per PORT_PLAN).
BREW_PREFIX="/opt/homebrew"

# --- OS guard --------------------------------------------------------------
# install.sh is the bootstrap entry point; lib/os.sh may not be in place yet
# when run via `curl | bash`, so do a lightweight inline check here.
if [ "$(uname -s)" != "Darwin" ]; then
    echo "ERROR: this is the macOS bootstrap. Detected non-Darwin system. Aborting." >&2
    exit 1
fi

# --- Xcode Command Line Tools ----------------------------------------------
# Provides the compiler toolchain (replaces Ubuntu's build-essential) plus
# lldb and git. Idempotent: only triggers the installer when CLT is absent.
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools — follow the GUI prompt, then re-run this script."
    xcode-select --install || true
    echo "Waiting for Xcode Command Line Tools to finish installing..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi

# --- Homebrew --------------------------------------------------------------
if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Put brew on PATH for the remainder of this process.
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# git ships with the Xcode CLT, but ensure it is present before cloning.
if ! command -v git &>/dev/null; then
    brew install git
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
echo "     (zsh login shells read the same file via ~/.zprofile)"
echo ""
echo "  4. Set up MCP servers for Claude/opencode:"
echo "       cp ~/personal/dev/env/.claude.json.example ~/.claude.json"
echo "       \$EDITOR ~/.claude.json  # add your TAVILY_API_KEY"
echo ""
echo "  5. Open a new shell (or: source ~/.zprofile) to pick up"
echo "     all PATH changes from this session."
echo ""
echo "  6. First nvim launch will install all plugins via lazy.nvim —"
echo "     wait for it to finish, then restart nvim."
echo ""
echo "============================================================"
