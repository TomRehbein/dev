#!/usr/bin/env bash

set -e

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v git &> /dev/null; then
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
    git clone -b feature/macos-support https://github.com/TomRehbein/dev "$HOME/personal/dev"
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
echo "  3. Create ~/.zprofile.local for machine-specific config"
echo "     (API keys, work aliases, etc.):"
echo "       \$EDITOR ~/.zprofile.local"
echo ""
echo "  4. Set up MCP servers for Claude/opencode:"
echo "       cp ~/personal/dev/env/.claude.json.example ~/.claude.json"
echo "       \$EDITOR ~/.claude.json  # add your TAVILY_API_KEY"
echo ""
echo "  5. Open a new terminal (or: source ~/.zprofile) to pick up"
echo "     all PATH changes from this session."
echo ""
echo "  6. First nvim launch will install all plugins via lazy.nvim —"
echo "     wait for it to finish, then restart nvim."
echo ""
echo "============================================================"
