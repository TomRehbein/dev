# ~/.shell_common.sh — shell-neutral login config shared by bash and zsh.
# Sourced from ~/.bash_profile (bash) and ~/.zprofile (zsh, macOS).
# Contains only POSIX-compatible env vars, PATH setup, tool inits and helper
# functions — NO shell-specific syntax (keybindings, completions live in the
# per-shell rc files). Keeping this single file avoids duplicating the login
# config across bash and zsh.

export XDG_CONFIG_HOME="$HOME/.config"
export GIT_EDITOR="nvim"
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"

export PERSONAL="$HOME/personal"
export WORK="$HOME/work"
export DEV_ENV_HOME="$PERSONAL/dev"

# ---- Homebrew (macOS / Apple Silicon) ----
# Put brew (and its installed tools) on PATH. Fixed prefix per PORT_PLAN.
# Guarded so this same file stays usable on Linux, where brew is absent.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ---- PATH helpers ----

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH="$PATH:$1"
    fi
}

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# User scripts and binaries
addToPathFront "$HOME/.local/bin"
addToPathFront "$HOME/.local/scripts"
addToPathFront "$HOME/.local/apps"

# opencode — installed to ~/.opencode/bin by the upstream installer
addToPathFront "$HOME/.opencode/bin"

# nvm node — prepend the active node version's bin
if [ -d "$NVM_DIR/versions/node" ]; then
    _nvm_node=$(ls "$NVM_DIR/versions/node" 2>/dev/null | sort -V | tail -1)
    [ -n "$_nvm_node" ] && addToPathFront "$NVM_DIR/versions/node/$_nvm_node/bin"
    unset _nvm_node
fi

# Language runtimes
addToPathFront "$HOME/.pyenv/bin"
addToPath      "$HOME/.cargo/bin"
addToPath      "$HOME/.npm-global/bin"

# Tools
addToPath "$BUN_INSTALL/bin"

# ---- Tool inits (run once at login) ----

if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
    eval "$(pyenv init -)"
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ---- Functions ----

git-clone-work() {
    read -rp "(work) SSH URL: " url
    [ -z "$url" ] && return 1
    read -rp "(work) Custom name (optional): " name
    ~/.local/scripts/git-cloner work "$url" "$name"
}

git-clone-personal() {
    read -rp "(personal) SSH URL: " url
    [ -z "$url" ] && return 1
    read -rp "(personal) Custom name (optional): " name
    ~/.local/scripts/git-cloner personal "$url" "$name"
}

# ---- Local overrides (not committed) ----

[ -f ~/.bash_profile.local ] && source ~/.bash_profile.local
